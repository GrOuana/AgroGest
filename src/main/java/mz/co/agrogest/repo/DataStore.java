package mz.co.agrogest.repo;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.function.Predicate;
import java.util.function.ToIntFunction;

import mz.co.agrogest.model.Campanha;
import mz.co.agrogest.model.Colheita;
import mz.co.agrogest.model.Cultivo;
import mz.co.agrogest.model.Fornecedor;
import mz.co.agrogest.model.Perfil;
import mz.co.agrogest.model.Produto;
import mz.co.agrogest.model.Utilizador;
import mz.co.agrogest.model.Venda;

/**
 * Repositório em memória partilhado por todas as threads do Tomcat.
 *
 * Cada lista é uma Collections.synchronizedList: protege as operações
 * isoladas (add, remove). Percorrer uma lista é feito dentro de
 * synchronized(lista), senão há ConcurrentModificationException.
 * Sequências do tipo "verificar e depois alterar" (vender, remover com
 * dependências) são protegidas nos serviços com os locks expostos aqui.
 *
 * Ordem de aquisição de locks, para evitar deadlocks: produtos → vendas.
 */
public class DataStore {

    private final List<Utilizador> utilizadores = Collections.synchronizedList(new ArrayList<>());
    private final List<Fornecedor> fornecedores = Collections.synchronizedList(new ArrayList<>());
    private final List<Produto> produtos = Collections.synchronizedList(new ArrayList<>());
    private final List<Campanha> campanhas = Collections.synchronizedList(new ArrayList<>());
    private final List<Cultivo> cultivos = Collections.synchronizedList(new ArrayList<>());
    private final List<Colheita> colheitas = Collections.synchronizedList(new ArrayList<>());
    private final List<Venda> vendas = Collections.synchronizedList(new ArrayList<>());

    // RN06: IDs sequenciais gerados por AtomicInteger, nunca por lista.size() + 1.
    private final AtomicInteger seqUtilizador = new AtomicInteger(1);
    private final AtomicInteger seqFornecedor = new AtomicInteger(1);
    private final AtomicInteger seqProduto = new AtomicInteger(1);
    private final AtomicInteger seqCampanha = new AtomicInteger(1);
    private final AtomicInteger seqCultivo = new AtomicInteger(1);
    private final AtomicInteger seqColheita = new AtomicInteger(1);
    private final AtomicInteger seqVenda = new AtomicInteger(1);
    private final Map<Integer, AtomicInteger> seqFactura = new ConcurrentHashMap<>();

    // ---------------------------------------------------------------- locks

    public Object lockUtilizadores() { return utilizadores; }
    public Object lockProdutos() { return produtos; }
    public Object lockCultivos() { return cultivos; }
    public Object lockColheitas() { return colheitas; }

    // --------------------------------------------------------- utilizadores

    public List<Utilizador> listarUtilizadores() {
        return copia(utilizadores);
    }

    public List<Utilizador> listarClientes() {
        return filtrar(utilizadores, u -> u.getPerfil() == Perfil.CLIENTE);
    }

    public Optional<Utilizador> procurarUtilizador(int id) {
        return procurar(utilizadores, u -> u.getId() == id);
    }

    public Optional<Utilizador> procurarUtilizadorPorEmail(String email) {
        if (email == null) {
            return Optional.empty();
        }
        String e = email.trim();
        return procurar(utilizadores, u -> u.getEmail().equalsIgnoreCase(e));
    }

    /**
     * Adiciona o utilizador só se o email ainda não existir. A verificação e a
     * inserção correm sob o mesmo lock, por isso dois registos simultâneos com
     * o mesmo email não passam os dois.
     */
    public boolean adicionarUtilizadorSeEmailLivre(Utilizador u) {
        synchronized (utilizadores) {
            for (Utilizador x : utilizadores) {
                if (x.getEmail().equalsIgnoreCase(u.getEmail())) {
                    return false;
                }
            }
            u.setId(seqUtilizador.getAndIncrement());
            utilizadores.add(u);
            return true;
        }
    }

    // ---------------------------------------------------------- fornecedores

    public List<Fornecedor> listarFornecedores() {
        return copia(fornecedores);
    }

    public Optional<Fornecedor> procurarFornecedor(int id) {
        return procurar(fornecedores, f -> f.getId() == id);
    }

    public Fornecedor adicionarFornecedor(Fornecedor f) {
        f.setId(seqFornecedor.getAndIncrement());
        fornecedores.add(f);
        return f;
    }

    public boolean removerFornecedor(int id) {
        return fornecedores.removeIf(f -> f.getId() == id);
    }

    // -------------------------------------------------------------- produtos

    public List<Produto> listarProdutos() {
        return copia(produtos);
    }

    public Optional<Produto> procurarProduto(int id) {
        return procurar(produtos, p -> p.getId() == id);
    }

    public Produto adicionarProduto(Produto p) {
        p.setId(seqProduto.getAndIncrement());
        produtos.add(p);
        return p;
    }

    public boolean removerProduto(int id) {
        return produtos.removeIf(p -> p.getId() == id);
    }

    public boolean existeProdutoDoFornecedor(int fornecedorId) {
        return procurar(produtos, p -> p.getFornecedorId() == fornecedorId).isPresent();
    }

    // ------------------------------------------------------------- campanhas

    public List<Campanha> listarCampanhas() {
        return copia(campanhas);
    }

    public Optional<Campanha> procurarCampanha(int id) {
        return procurar(campanhas, c -> c.getId() == id);
    }

    public Campanha adicionarCampanha(Campanha c) {
        c.setId(seqCampanha.getAndIncrement());
        campanhas.add(c);
        return c;
    }

    public boolean removerCampanha(int id) {
        return campanhas.removeIf(c -> c.getId() == id);
    }

    // -------------------------------------------------------------- cultivos

    public List<Cultivo> listarCultivos() {
        return copia(cultivos);
    }

    public List<Cultivo> listarCultivosDaCampanha(int campanhaId) {
        return filtrar(cultivos, c -> c.getCampanhaId() == campanhaId);
    }

    public Optional<Cultivo> procurarCultivo(int id) {
        return procurar(cultivos, c -> c.getId() == id);
    }

    public Cultivo adicionarCultivo(Cultivo c) {
        c.setId(seqCultivo.getAndIncrement());
        cultivos.add(c);
        return c;
    }

    public boolean removerCultivo(int id) {
        return cultivos.removeIf(c -> c.getId() == id);
    }

    // ------------------------------------------------------------- colheitas

    public List<Colheita> listarColheitas() {
        return copia(colheitas);
    }

    public List<Colheita> listarColheitasDoCultivo(int cultivoId) {
        return filtrar(colheitas, c -> c.getCultivoId() == cultivoId);
    }

    public Colheita adicionarColheita(Colheita c) {
        c.setId(seqColheita.getAndIncrement());
        colheitas.add(c);
        return c;
    }

    public boolean removerColheita(int id) {
        return colheitas.removeIf(c -> c.getId() == id);
    }

    // ---------------------------------------------------------------- vendas

    public List<Venda> listarVendas() {
        return copia(vendas);
    }

    public List<Venda> listarVendasDoCliente(int clienteId) {
        return filtrar(vendas, v -> v.getClienteId() == clienteId);
    }

    public Optional<Venda> procurarVenda(int id) {
        return procurar(vendas, v -> v.getId() == id);
    }

    public Venda adicionarVenda(Venda v) {
        v.setId(seqVenda.getAndIncrement());
        vendas.add(v);
        return v;
    }

    /** Número sequencial de factura dentro do ano: 1, 2, 3… */
    public int proximoNumeroFactura(int ano) {
        return seqFactura.computeIfAbsent(ano, a -> new AtomicInteger(1)).getAndIncrement();
    }

    // ----------------------------------------------------------- persistência

    /**
     * Serializa o estado completo para bytes. Corre com os locks de produtos e
     * vendas, para nenhuma venda ficar a meio no ficheiro (stock descontado sem
     * a venda registada, ou o contrário).
     */
    public byte[] exportar() throws IOException {
        synchronized (produtos) {
            synchronized (vendas) {
                Snapshot s = new Snapshot();
                s.utilizadores = copia(utilizadores);
                s.fornecedores = copia(fornecedores);
                s.produtos = new ArrayList<>(produtos);
                s.campanhas = copia(campanhas);
                s.cultivos = copia(cultivos);
                s.colheitas = copia(colheitas);
                s.vendas = new ArrayList<>(vendas);
                s.sequencias.put("utilizador", seqUtilizador.get());
                s.sequencias.put("fornecedor", seqFornecedor.get());
                s.sequencias.put("produto", seqProduto.get());
                s.sequencias.put("campanha", seqCampanha.get());
                s.sequencias.put("cultivo", seqCultivo.get());
                s.sequencias.put("colheita", seqColheita.get());
                s.sequencias.put("venda", seqVenda.get());
                seqFactura.forEach((ano, seq) -> s.sequenciasFactura.put(ano, seq.get()));

                ByteArrayOutputStream bytes = new ByteArrayOutputStream();
                try (ObjectOutputStream out = new ObjectOutputStream(bytes)) {
                    out.writeObject(s);
                }
                return bytes.toByteArray();
            }
        }
    }

    /** Substitui o estado em memória pelo conteúdo serializado. */
    public void importar(byte[] dados) throws IOException, ClassNotFoundException {
        Snapshot s;
        try (ObjectInputStream in = new ObjectInputStream(new ByteArrayInputStream(dados))) {
            s = (Snapshot) in.readObject();
        }
        synchronized (produtos) {
            synchronized (vendas) {
                substituir(utilizadores, s.utilizadores);
                substituir(fornecedores, s.fornecedores);
                substituir(produtos, s.produtos);
                substituir(campanhas, s.campanhas);
                substituir(cultivos, s.cultivos);
                substituir(colheitas, s.colheitas);
                substituir(vendas, s.vendas);

                // Repor cada contador em max(valor gravado, maior ID + 1): os IDs
                // nunca se repetem depois de reiniciar o Tomcat.
                repor(seqUtilizador, s, "utilizador", s.utilizadores, Utilizador::getId);
                repor(seqFornecedor, s, "fornecedor", s.fornecedores, Fornecedor::getId);
                repor(seqProduto, s, "produto", s.produtos, Produto::getId);
                repor(seqCampanha, s, "campanha", s.campanhas, Campanha::getId);
                repor(seqCultivo, s, "cultivo", s.cultivos, Cultivo::getId);
                repor(seqColheita, s, "colheita", s.colheitas, Colheita::getId);
                repor(seqVenda, s, "venda", s.vendas, Venda::getId);

                seqFactura.clear();
                s.sequenciasFactura.forEach((ano, prox) -> seqFactura.put(ano, new AtomicInteger(prox)));
                for (Venda v : s.vendas) {
                    garantirFacturaAcimaDe(v.getNumeroFactura());
                }
            }
        }
    }

    /** Apaga tudo da memória (usado antes de repor os dados de demonstração). */
    public void limpar() {
        synchronized (produtos) {
            synchronized (vendas) {
                utilizadores.clear();
                fornecedores.clear();
                produtos.clear();
                campanhas.clear();
                cultivos.clear();
                colheitas.clear();
                vendas.clear();
                for (AtomicInteger seq : List.of(seqUtilizador, seqFornecedor, seqProduto, seqCampanha,
                        seqCultivo, seqColheita, seqVenda)) {
                    seq.set(1);
                }
                seqFactura.clear();
            }
        }
    }

    // ------------------------------------------------------------- auxiliares

    private void garantirFacturaAcimaDe(String numero) {
        // Formato FT-2026-7
        if (numero == null) {
            return;
        }
        String[] partes = numero.split("-");
        if (partes.length != 3) {
            return;
        }
        try {
            int ano = Integer.parseInt(partes[1]);
            int n = Integer.parseInt(partes[2]);
            seqFactura.computeIfAbsent(ano, a -> new AtomicInteger(1))
                      .accumulateAndGet(n + 1, Math::max);
        } catch (NumberFormatException ignorado) {
            // número em formato inesperado: não afecta a sequência
        }
    }

    private static <T> void repor(AtomicInteger seq, Snapshot s, String nome, List<T> lista, ToIntFunction<T> id) {
        int maior = 0;
        for (T t : lista) {
            maior = Math.max(maior, id.applyAsInt(t));
        }
        int gravado = s.sequencias.getOrDefault(nome, 1);
        seq.set(Math.max(gravado, maior + 1));
    }

    private static <T> void substituir(List<T> destino, List<T> origem) {
        synchronized (destino) {
            destino.clear();
            destino.addAll(origem);
        }
    }

    private static <T> List<T> copia(List<T> lista) {
        synchronized (lista) {
            return new ArrayList<>(lista);
        }
    }

    private static <T> List<T> filtrar(List<T> lista, Predicate<T> condicao) {
        List<T> resultado = new ArrayList<>();
        synchronized (lista) {
            for (T t : lista) {
                if (condicao.test(t)) {
                    resultado.add(t);
                }
            }
        }
        return resultado;
    }

    private static <T> Optional<T> procurar(List<T> lista, Predicate<T> condicao) {
        synchronized (lista) {
            for (T t : lista) {
                if (condicao.test(t)) {
                    return Optional.of(t);
                }
            }
        }
        return Optional.empty();
    }
}
