package mz.co.agrogest.service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;

import mz.co.agrogest.model.Categoria;
import mz.co.agrogest.model.Fornecedor;
import mz.co.agrogest.model.Produto;
import mz.co.agrogest.model.TipoFornecedor;
import mz.co.agrogest.repo.DataStore;
import mz.co.agrogest.util.Dinheiro;

/** Fornecedores e produtos: criação, alteração, reposição de stock e remoção. */
public class CatalogoService {

    private final DataStore store;

    public CatalogoService(DataStore store) {
        this.store = store;
    }

    // ---------------------------------------------------------- fornecedores

    public List<Fornecedor> listarFornecedores() {
        List<Fornecedor> lista = store.listarFornecedores();
        lista.sort(Comparator.comparing(Fornecedor::getNome, String.CASE_INSENSITIVE_ORDER));
        return lista;
    }

    public Optional<Fornecedor> procurarFornecedor(int id) {
        return store.procurarFornecedor(id);
    }

    public Fornecedor criarFornecedor(String nome, TipoFornecedor tipo, String contacto, String provincia) {
        Fornecedor f = new Fornecedor(
                Validar.obrigatorio(nome, "Nome"),
                Validar.presente(tipo, "Tipo"),
                Validar.obrigatorio(contacto, "Contacto"),
                Validar.obrigatorio(provincia, "Província"));
        return store.adicionarFornecedor(f);
    }

    public void removerFornecedor(int id) {
        // Verificar e remover sob o lock dos produtos: ninguém associa um produto
        // a este fornecedor entre a verificação e a remoção.
        synchronized (store.lockProdutos()) {
            Fornecedor f = store.procurarFornecedor(id)
                    .orElseThrow(() -> new RegraNegocioException("Fornecedor não encontrado."));
            if (store.existeProdutoDoFornecedor(id)) {
                throw new RegraNegocioException("Não é possível remover «" + f.getNome()
                        + "»: tem produtos associados. Remova ou altere primeiro esses produtos.");
            }
            store.removerFornecedor(id);
        }
    }

    // -------------------------------------------------------------- produtos

    public Optional<Produto> procurarProduto(int id) {
        return store.procurarProduto(id);
    }

    public List<Produto> listarProdutos() {
        List<Produto> lista = store.listarProdutos();
        lista.sort(Comparator.comparing(Produto::getNome, String.CASE_INSENSITIVE_ORDER));
        return lista;
    }

    /** Catálogo do cliente: produtos ordenados por nome, opcionalmente de uma categoria. */
    public List<Produto> catalogo(Categoria categoria) {
        List<Produto> resultado = new ArrayList<>();
        for (Produto p : listarProdutos()) {
            if (categoria == null || p.getCategoria() == categoria) {
                resultado.add(p);
            }
        }
        return resultado;
    }

    public Produto criarProduto(String nome, Categoria categoria, int fornecedorId, BigDecimal preco,
                                int quantidade, String unidade, String descricao, String fotoUrl,
                                LocalDate validade) {
        Produto p = new Produto();
        preencher(p, nome, categoria, preco, unidade, descricao, fotoUrl, validade);
        p.setQuantidade(Validar.naoNegativo(quantidade, "Quantidade"));
        synchronized (store.lockProdutos()) {
            Fornecedor f = fornecedorExistente(fornecedorId);
            p.setFornecedorId(f.getId());
            p.setFornecedorNome(f.getNome());
            return store.adicionarProduto(p);
        }
    }

    public Produto actualizarProduto(int id, String nome, Categoria categoria, int fornecedorId, BigDecimal preco,
                                     int quantidade, String unidade, String descricao, String fotoUrl,
                                     LocalDate validade) {
        Validar.naoNegativo(quantidade, "Quantidade");
        // Validar para um objecto temporário: se falhar, o produto real fica intacto
        Produto novo = new Produto();
        preencher(novo, nome, categoria, preco, unidade, descricao, fotoUrl, validade);
        synchronized (store.lockProdutos()) {
            Produto p = produtoExistente(id);
            Fornecedor f = fornecedorExistente(fornecedorId);
            p.setNome(novo.getNome());
            p.setCategoria(novo.getCategoria());
            p.setPreco(novo.getPreco());
            p.setUnidade(novo.getUnidade());
            p.setDescricao(novo.getDescricao());
            p.setFotoUrl(novo.getFotoUrl());
            p.setValidade(novo.getValidade());
            p.setFornecedorId(f.getId());
            p.setFornecedorNome(f.getNome());
            p.setQuantidade(quantidade);
            return p;
        }
    }

    /** Repor stock: soma a quantidade indicada (tem de ser positiva). */
    public Produto reporStock(int id, int quantidade) {
        Validar.positivo(quantidade, "Quantidade a repor");
        synchronized (store.lockProdutos()) {
            Produto p = produtoExistente(id);
            if ((long) p.getQuantidade() + quantidade > Validar.QUANTIDADE_MAXIMA) {
                throw new RegraNegocioException("O stock não pode passar de " + Validar.QUANTIDADE_MAXIMA + ".");
            }
            p.setQuantidade(p.getQuantidade() + quantidade);
            return p;
        }
    }

    public void removerProduto(int id) {
        synchronized (store.lockProdutos()) {
            produtoExistente(id);
            store.removerProduto(id);
        }
    }

    // ------------------------------------------------------------- auxiliares

    private void preencher(Produto p, String nome, Categoria categoria, BigDecimal preco, String unidade,
                           String descricao, String fotoUrl, LocalDate validade) {
        p.setNome(Validar.obrigatorio(nome, "Nome"));
        p.setCategoria(Validar.presente(categoria, "Categoria"));
        p.setPreco(Dinheiro.arredondar(Validar.positivo(preco, "Preço")));
        p.setUnidade(Validar.obrigatorio(unidade, "Unidade"));
        p.setDescricao(Validar.opcional(descricao));
        p.setFotoUrl(Validar.opcional(fotoUrl));
        p.setValidade(validade);
    }

    private Produto produtoExistente(int id) {
        return store.procurarProduto(id)
                .orElseThrow(() -> new RegraNegocioException("Produto não encontrado."));
    }

    private Fornecedor fornecedorExistente(int id) {
        return store.procurarFornecedor(id)
                .orElseThrow(() -> new RegraNegocioException("Escolha um fornecedor válido."));
    }
}
