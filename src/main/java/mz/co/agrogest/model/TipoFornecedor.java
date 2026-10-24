package mz.co.agrogest.model;

/** Tipo de fornecedor, conforme o enunciado. */
public enum TipoFornecedor {
    SEMENTES("Sementes"),
    MAQUINARIA("Maquinaria"),
    FERTILIZANTES("Fertilizantes");

    private final String descricao;

    TipoFornecedor(String descricao) {
        this.descricao = descricao;
    }

    public String getDescricao() {
        return descricao;
    }
}
