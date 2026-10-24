package mz.co.agrogest.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/** Cliente com os totais de compras, usado nas listagens e relatórios. */
public class ResumoCliente {

    private final Utilizador cliente;
    private final int numeroCompras;
    private final BigDecimal volume;
    private final LocalDateTime ultimaCompra;

    public ResumoCliente(Utilizador cliente, int numeroCompras, BigDecimal volume, LocalDateTime ultimaCompra) {
        this.cliente = cliente;
        this.numeroCompras = numeroCompras;
        this.volume = volume;
        this.ultimaCompra = ultimaCompra;
    }

    public Utilizador getCliente() { return cliente; }
    public int getNumeroCompras() { return numeroCompras; }
    public BigDecimal getVolume() { return volume; }
    public LocalDateTime getUltimaCompra() { return ultimaCompra; }
}
