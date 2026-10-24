package mz.co.agrogest.util;

import java.math.BigDecimal;
import java.math.RoundingMode;

/** Cálculos monetários em BigDecimal, sempre com 2 casas e HALF_UP. */
public final class Dinheiro {

    public static final BigDecimal TAXA_IVA = new BigDecimal("0.16");

    private Dinheiro() {
    }

    public static BigDecimal arredondar(BigDecimal valor) {
        return valor.setScale(2, RoundingMode.HALF_UP);
    }

    public static BigDecimal multiplicar(BigDecimal valor, BigDecimal quantidade) {
        return arredondar(valor.multiply(quantidade));
    }

    public static BigDecimal multiplicar(BigDecimal valor, int quantidade) {
        return multiplicar(valor, BigDecimal.valueOf(quantidade));
    }

    public static BigDecimal iva(BigDecimal subtotal) {
        return arredondar(subtotal.multiply(TAXA_IVA));
    }
}
