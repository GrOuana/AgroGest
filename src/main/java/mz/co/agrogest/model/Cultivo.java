package mz.co.agrogest.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;

public class Cultivo implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private int campanhaId;
    private String cultura;
    private String variedade;
    private BigDecimal hectares;
    private LocalDate plantio;

    public Cultivo() {
    }

    public Cultivo(int campanhaId, String cultura, String variedade, BigDecimal hectares, LocalDate plantio) {
        this.campanhaId = campanhaId;
        this.cultura = cultura;
        this.variedade = variedade;
        this.hectares = hectares;
        this.plantio = plantio;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getCampanhaId() { return campanhaId; }
    public void setCampanhaId(int campanhaId) { this.campanhaId = campanhaId; }

    public String getCultura() { return cultura; }
    public void setCultura(String cultura) { this.cultura = cultura; }

    public String getVariedade() { return variedade; }
    public void setVariedade(String variedade) { this.variedade = variedade; }

    public BigDecimal getHectares() { return hectares; }
    public void setHectares(BigDecimal hectares) { this.hectares = hectares; }

    public LocalDate getPlantio() { return plantio; }
    public void setPlantio(LocalDate plantio) { this.plantio = plantio; }
}
