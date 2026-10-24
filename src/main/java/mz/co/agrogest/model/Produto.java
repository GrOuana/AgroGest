package mz.co.agrogest.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Produto à venda. A quantidade (stock) só é alterada sob o lock da lista de
 * produtos do DataStore — ver VendaService e CatalogoService.
 */
public class Produto implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private String nome;
    private Categoria categoria;
    private int fornecedorId;
    private String fornecedorNome;
    private BigDecimal preco;
    private int quantidade;
    private String unidade;
    private String descricao;
    private String fotoUrl;
    private LocalDate validade;

    public Produto() {
    }

    public boolean isEmStock() {
        return quantidade > 0;
    }

    public boolean isExpirado() {
        return validade != null && validade.isBefore(LocalDate.now());
    }

    public BigDecimal getValorEmStock() {
        return preco == null ? BigDecimal.ZERO : preco.multiply(BigDecimal.valueOf(quantidade));
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }

    public Categoria getCategoria() { return categoria; }
    public void setCategoria(Categoria categoria) { this.categoria = categoria; }

    public int getFornecedorId() { return fornecedorId; }
    public void setFornecedorId(int fornecedorId) { this.fornecedorId = fornecedorId; }

    public String getFornecedorNome() { return fornecedorNome; }
    public void setFornecedorNome(String fornecedorNome) { this.fornecedorNome = fornecedorNome; }

    public BigDecimal getPreco() { return preco; }
    public void setPreco(BigDecimal preco) { this.preco = preco; }

    public int getQuantidade() { return quantidade; }
    public void setQuantidade(int quantidade) { this.quantidade = quantidade; }

    public String getUnidade() { return unidade; }
    public void setUnidade(String unidade) { this.unidade = unidade; }

    public String getDescricao() { return descricao; }
    public void setDescricao(String descricao) { this.descricao = descricao; }

    public String getFotoUrl() { return fotoUrl; }
    public void setFotoUrl(String fotoUrl) { this.fotoUrl = fotoUrl; }

    public LocalDate getValidade() { return validade; }
    public void setValidade(LocalDate validade) { this.validade = validade; }
}
