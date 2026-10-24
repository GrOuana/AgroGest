package mz.co.agrogest.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import mz.co.agrogest.model.Produto;
import mz.co.agrogest.model.Utilizador;
import mz.co.agrogest.model.Venda;
import mz.co.agrogest.model.VendaItem;
import mz.co.agrogest.repo.DataStore;
import mz.co.agrogest.util.Dinheiro;

/**
 * Transacção de venda sem base de dados.
 *
 * RN01 — não se vende mais do que o stock disponível.
 * RN02 — o stock de todos os itens é descontado atomicamente: ou todos, ou nenhum.
 *
 * As duas fases (verificar tudo, depois descontar tudo) correm dentro do mesmo
 * bloco synchronized sobre a lista de produtos. Nenhuma outra thread pode
 * alterar stock entre a verificação e o desconto, por isso duas compras
 * simultâneas da última unidade não passam as duas.
 */
public class VendaService {

    private final DataStore store;

    public VendaService(DataStore store) {
        this.store = store;
    }

    public Venda finalizarCompra(int clienteId, Map<Integer, Integer> itens) {
        return registarVenda(clienteId, itens, LocalDateTime.now());
    }

    /** Também usado pelos dados de demonstração, com datas no passado. */
    Venda registarVenda(int clienteId, Map<Integer, Integer> itens, LocalDateTime data) {
        if (itens == null || itens.isEmpty()) {
            throw new RegraNegocioException("O carrinho está vazio.");
        }
        Utilizador cliente = store.procurarUtilizador(clienteId)
                .filter(Utilizador::isCliente)
                .orElseThrow(() -> new RegraNegocioException("Só clientes registados podem comprar."));

        synchronized (store.lockProdutos()) {
            // Fase 1: verificar todos os itens sem alterar nada
            List<String> problemas = new ArrayList<>();
            List<Produto> produtos = new ArrayList<>();
            for (Map.Entry<Integer, Integer> e : itens.entrySet()) {
                int quantidade = e.getValue();
                Optional<Produto> op = store.procurarProduto(e.getKey());
                if (op.isEmpty()) {
                    problemas.add("produto #" + e.getKey() + " já não existe no catálogo");
                    continue;
                }
                Produto p = op.get();
                produtos.add(p);
                if (quantidade <= 0) {
                    problemas.add(p.getNome() + ": quantidade inválida");
                } else if (p.getValidade() != null && data.toLocalDate().isAfter(p.getValidade())) {
                    problemas.add(p.getNome() + ": fora da validade");
                } else if (quantidade > p.getQuantidade()) {
                    problemas.add(p.getNome() + ": pediu " + quantidade + " " + p.getUnidade()
                            + ", disponível " + p.getQuantidade());
                }
            }
            if (!problemas.isEmpty()) {
                throw new StockInsuficienteException(problemas);
            }

            // Fase 2: tudo verificado — descontar todos e registar a venda
            Venda venda = new Venda();
            venda.setClienteId(cliente.getId());
            venda.setClienteNome(cliente.getNome());
            venda.setClienteEmail(cliente.getEmail());
            venda.setClienteTelefone(cliente.getTelefone());
            venda.setClienteEndereco(cliente.getEndereco());
            venda.setData(data);

            BigDecimal subtotal = BigDecimal.ZERO;
            for (Produto p : produtos) {
                int quantidade = itens.get(p.getId());
                p.setQuantidade(p.getQuantidade() - quantidade);

                VendaItem item = new VendaItem();
                item.setProdutoId(p.getId());
                item.setProdutoNome(p.getNome());
                item.setUnidade(p.getUnidade());
                item.setQuantidade(quantidade);
                item.setPrecoUnit(p.getPreco());
                item.setSubtotal(Dinheiro.multiplicar(p.getPreco(), quantidade));
                venda.getItens().add(item);
                subtotal = subtotal.add(item.getSubtotal());
            }
            BigDecimal iva = Dinheiro.iva(subtotal);
            venda.setSubtotal(subtotal);
            venda.setIva(iva);
            venda.setTotal(subtotal.add(iva));

            int ano = data.getYear();
            venda.setNumeroFactura("FT-" + ano + "-" + store.proximoNumeroFactura(ano));
            return store.adicionarVenda(venda);
        }
    }

    public Optional<Venda> procurar(int vendaId) {
        return store.procurarVenda(vendaId);
    }

    /** RN03: o cliente só vê as suas facturas; o administrador vê todas. */
    public boolean podeVer(Utilizador u, Venda v) {
        return u != null && (u.isAdmin() || v.getClienteId() == u.getId());
    }

    public List<Venda> historicoDoCliente(int clienteId) {
        List<Venda> lista = store.listarVendasDoCliente(clienteId);
        lista.sort(Comparator.comparing(Venda::getData).reversed());
        return lista;
    }
}
