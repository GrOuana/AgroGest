package mz.co.agrogest.service;

import java.util.List;

/** RN01: a venda pede mais do que o stock disponível. Nenhum stock foi descontado. */
public class StockInsuficienteException extends RegraNegocioException {

    private static final long serialVersionUID = 1L;

    private final List<String> problemas;

    public StockInsuficienteException(List<String> problemas) {
        super("Compra não efectuada — produto indisponível: " + String.join("; ", problemas)
                + ". Nenhum stock foi descontado.");
        this.problemas = List.copyOf(problemas);
    }

    public List<String> getProblemas() {
        return problemas;
    }
}
