package mz.co.agrogest.model;

import java.math.BigDecimal;

/** Linha do carrinho já calculada, pronta para a JSP mostrar. */
public class LinhaCarrinho {

    private final Produto produto;
    private final int quantidade;
    private final BigDecimal subtotal;

    public LinhaCarrinho(Produto produto, int quantidade, BigDecimal subtotal) {
        this.produto = produto;
        this.quantidade = quantidade;
        this.subtotal = subtotal;
    }

    public boolean isStockSuficiente() {
        return quantidade <= produto.getQuantidade();
    }

    public Produto getProduto() { return produto; }
    public int getQuantidade() { return quantidade; }
    public BigDecimal getSubtotal() { return subtotal; }
}
