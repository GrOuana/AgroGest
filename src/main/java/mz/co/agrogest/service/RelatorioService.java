package mz.co.agrogest.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import mz.co.agrogest.model.Fornecedor;
import mz.co.agrogest.model.Painel;
import mz.co.agrogest.model.Produto;
import mz.co.agrogest.model.ResumoCliente;
import mz.co.agrogest.model.Utilizador;
import mz.co.agrogest.model.Venda;
import mz.co.agrogest.repo.DataStore;

/**
 * Listagens ordenáveis e relatórios do administrador. Trabalha sobre cópias
 * das listas do DataStore, por isso ordenar não bloqueia as vendas.
 */
public class RelatorioService {

    public static final int LIMITE_STOCK_BAIXO = 10;

    private static final Comparator<String> TEXTO = String.CASE_INSENSITIVE_ORDER;

    private final DataStore store;

    public RelatorioService(DataStore store) {
        this.store = store;
    }

    public Painel painel() {
        List<Produto> produtos = store.listarProdutos();
        List<Venda> vendas = store.listarVendas();
        BigDecimal total = BigDecimal.ZERO;
        for (Venda v : vendas) {
            total = total.add(v.getTotal());
        }
        List<Produto> baixo = new ArrayList<>();
        for (Produto p : produtos) {
            if (p.getQuantidade() < LIMITE_STOCK_BAIXO) {
                baixo.add(p);
            }
        }
        baixo.sort(Comparator.comparingInt(Produto::getQuantidade));
        vendas.sort(Comparator.comparing(Venda::getData).reversed());
        List<Venda> ultimas = vendas.subList(0, Math.min(5, vendas.size()));
        return new Painel(store.listarFornecedores().size(), produtos.size(), store.listarClientes().size(),
                vendas.size(), store.listarCampanhas().size(), total, baixo, new ArrayList<>(ultimas));
    }

    // ------------------------------------------------------------- listagens

    /** ordem: nome | preco | stock | validade | fornecedor */
    public List<Produto> produtos(String ordem, boolean desc) {
        return ordenar(store.listarProdutos(), comparadorProduto(ordem), desc);
    }

    /** Produtos em armazém: só os que têm stock > 0. ordem: nome | preco | stock | valor */
    public List<Produto> armazem(String ordem, boolean desc) {
        List<Produto> lista = new ArrayList<>();
        for (Produto p : store.listarProdutos()) {
            if (p.getQuantidade() > 0) {
                lista.add(p);
            }
        }
        return ordenar(lista, comparadorProduto(ordem), desc);
    }

    /** ordem: nome | tipo | provincia */
    public List<Fornecedor> fornecedores(String ordem, boolean desc) {
        Comparator<Fornecedor> c;
        switch (valor(ordem)) {
            case "tipo": c = Comparator.comparing((Fornecedor f) -> f.getTipo().name()); break;
            case "provincia": c = Comparator.comparing(Fornecedor::getProvincia, TEXTO); break;
            default: c = Comparator.comparing(Fornecedor::getNome, TEXTO);
        }
        return ordenar(store.listarFornecedores(), c.thenComparing(Fornecedor::getNome, TEXTO), desc);
    }

    /** ordem: nome | data (registo) | compras | valor */
    public List<ResumoCliente> clientes(String ordem, boolean desc) {
        Comparator<ResumoCliente> c;
        switch (valor(ordem)) {
            case "data": c = Comparator.comparing(r -> r.getCliente().getDataRegisto()); break;
            case "compras": c = Comparator.comparingInt(ResumoCliente::getNumeroCompras); break;
            case "valor": c = Comparator.comparing(ResumoCliente::getVolume); break;
            default: c = porNome();
        }
        return ordenar(resumosDeClientes(), c.thenComparing(porNome()), desc);
    }

    /** ordem: data | valor | cliente | numero */
    public List<Venda> compras(String ordem, boolean desc) {
        Comparator<Venda> c;
        switch (valor(ordem)) {
            case "valor": c = Comparator.comparing(Venda::getTotal); break;
            case "cliente": c = Comparator.comparing(Venda::getClienteNome, TEXTO); break;
            case "numero": c = Comparator.comparingInt(Venda::getId); break;
            default: c = Comparator.comparing(Venda::getData);
        }
        return ordenar(store.listarVendas(), c.thenComparingInt(Venda::getId), desc);
    }

    // ------------------------------------------------------------ relatórios

    /** Clientes ordenados por nome (crescente). */
    public List<ResumoCliente> clientesPorNome() {
        List<ResumoCliente> lista = resumosDeClientes();
        lista.sort(porNome());
        return lista;
    }

    /** Clientes que compraram, do maior para o menor volume (valor total). */
    public List<ResumoCliente> clientesPorVolume() {
        List<ResumoCliente> lista = new ArrayList<>();
        for (ResumoCliente r : resumosDeClientes()) {
            if (r.getNumeroCompras() > 0) {
                lista.add(r);
            }
        }
        lista.sort(Comparator.comparing(ResumoCliente::getVolume).reversed().thenComparing(porNome()));
        return lista;
    }

    /** Ranking de assiduidade: número de compras; empate desfeito pelo volume. */
    public List<ResumoCliente> clientesMaisAssiduos() {
        List<ResumoCliente> lista = new ArrayList<>();
        for (ResumoCliente r : resumosDeClientes()) {
            if (r.getNumeroCompras() > 0) {
                lista.add(r);
            }
        }
        lista.sort(Comparator.comparingInt(ResumoCliente::getNumeroCompras).reversed()
                .thenComparing(Comparator.comparing(ResumoCliente::getVolume).reversed())
                .thenComparing(porNome()));
        return lista;
    }

    /** Extra: clientes registados que nunca compraram. */
    public List<ResumoCliente> clientesSemCompras() {
        List<ResumoCliente> lista = new ArrayList<>();
        for (ResumoCliente r : resumosDeClientes()) {
            if (r.getNumeroCompras() == 0) {
                lista.add(r);
            }
        }
        lista.sort(porNome());
        return lista;
    }

    // ------------------------------------------------------------- auxiliares

    private List<ResumoCliente> resumosDeClientes() {
        Map<Integer, Integer> compras = new HashMap<>();
        Map<Integer, BigDecimal> volume = new HashMap<>();
        Map<Integer, LocalDateTime> ultima = new HashMap<>();
        for (Venda v : store.listarVendas()) {
            compras.merge(v.getClienteId(), 1, Integer::sum);
            volume.merge(v.getClienteId(), v.getTotal(), BigDecimal::add);
            ultima.merge(v.getClienteId(), v.getData(), (a, b) -> a.isAfter(b) ? a : b);
        }
        List<ResumoCliente> lista = new ArrayList<>();
        for (Utilizador u : store.listarClientes()) {
            lista.add(new ResumoCliente(u, compras.getOrDefault(u.getId(), 0),
                    volume.getOrDefault(u.getId(), BigDecimal.ZERO), ultima.get(u.getId())));
        }
        return lista;
    }

    private static Comparator<ResumoCliente> porNome() {
        return Comparator.comparing(r -> r.getCliente().getNome(), TEXTO);
    }

    private static Comparator<Produto> comparadorProduto(String ordem) {
        Comparator<Produto> c;
        switch (valor(ordem)) {
            case "preco": c = Comparator.comparing(Produto::getPreco); break;
            case "stock": c = Comparator.comparingInt(Produto::getQuantidade); break;
            case "valor": c = Comparator.comparing(Produto::getValorEmStock); break;
            case "fornecedor": c = Comparator.comparing(Produto::getFornecedorNome, TEXTO); break;
            case "validade":
                c = Comparator.comparing(Produto::getValidade, Comparator.nullsLast(Comparator.naturalOrder()));
                break;
            default: c = Comparator.comparing(Produto::getNome, TEXTO);
        }
        return c.thenComparing(Produto::getNome, TEXTO);
    }

    private static <T> List<T> ordenar(List<T> lista, Comparator<T> c, boolean desc) {
        lista.sort(desc ? c.reversed() : c);
        return lista;
    }

    private static String valor(String ordem) {
        return ordem == null ? "" : ordem;
    }
}
