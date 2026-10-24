package mz.co.agrogest.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;

/** Colheita de um cultivo. O valor total é calculado pelo sistema (kg × preço/kg). */
public class Colheita implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private int cultivoId;
    private LocalDate data;
    private BigDecimal kg;
    private BigDecimal precoKg;
    private BigDecimal valorTotal;

    public Colheita() {
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getCultivoId() { return cultivoId; }
    public void setCultivoId(int cultivoId) { this.cultivoId = cultivoId; }

    public LocalDate getData() { return data; }
    public void setData(LocalDate data) { this.data = data; }

    public BigDecimal getKg() { return kg; }
    public void setKg(BigDecimal kg) { this.kg = kg; }

    public BigDecimal getPrecoKg() { return precoKg; }
    public void setPrecoKg(BigDecimal precoKg) { this.precoKg = precoKg; }

    public BigDecimal getValorTotal() { return valorTotal; }
    public void setValorTotal(BigDecimal valorTotal) { this.valorTotal = valorTotal; }
}
