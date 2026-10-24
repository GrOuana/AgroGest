package mz.co.agrogest.model;

/** Categoria de um produto do catálogo. */
public enum Categoria {
    SEMENTE("Semente"),
    FERTILIZANTE("Fertilizante"),
    MAQUINARIA("Maquinaria"),
    FERRAMENTA("Ferramenta");

    private final String descricao;

    Categoria(String descricao) {
        this.descricao = descricao;
    }

    public String getDescricao() {
        return descricao;
    }
}
