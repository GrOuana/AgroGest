package mz.co.agrogest.model;

import java.math.BigDecimal;
import java.util.List;

/** Linhas do carrinho com subtotal, IVA e total calculados no serviço. */
public class ResumoCarrinho {

    private final List<LinhaCarrinho> linhas;
    private final BigDecimal subtotal;
    private final BigDecimal iva;
    private final BigDecimal total;

    public ResumoCarrinho(List<LinhaCarrinho> linhas, BigDecimal subtotal, BigDecimal iva, BigDecimal total) {
        this.linhas = linhas;
        this.subtotal = subtotal;
        this.iva = iva;
        this.total = total;
    }

    public boolean isVazio() {
        return linhas.isEmpty();
    }

    public boolean isStockSuficiente() {
        for (LinhaCarrinho l : linhas) {
            if (!l.isStockSuficiente()) {
                return false;
            }
        }
        return true;
    }

    public List<LinhaCarrinho> getLinhas() { return linhas; }
    public BigDecimal getSubtotal() { return subtotal; }
    public BigDecimal getIva() { return iva; }
    public BigDecimal getTotal() { return total; }
}
