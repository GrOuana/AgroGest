package mz.co.agrogest.model;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Linha de uma venda. Guarda cópia do nome e do preço do produto no momento
 * da compra, para a factura não mudar se o produto for alterado ou removido.
 */
public class VendaItem implements Serializable {

    private static final long serialVersionUID = 1L;

    private int produtoId;
    private String produtoNome;
    private String unidade;
    private int quantidade;
    private BigDecimal precoUnit;
    private BigDecimal subtotal;

    public VendaItem() {
    }

    public int getProdutoId() { return produtoId; }
    public void setProdutoId(int produtoId) { this.produtoId = produtoId; }

    public String getProdutoNome() { return produtoNome; }
    public void setProdutoNome(String produtoNome) { this.produtoNome = produtoNome; }

    public String getUnidade() { return unidade; }
    public void setUnidade(String unidade) { this.unidade = unidade; }

    public int getQuantidade() { return quantidade; }
    public void setQuantidade(int quantidade) { this.quantidade = quantidade; }

    public BigDecimal getPrecoUnit() { return precoUnit; }
    public void setPrecoUnit(BigDecimal precoUnit) { this.precoUnit = precoUnit; }

    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }
}
