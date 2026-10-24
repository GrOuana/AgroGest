package mz.co.agrogest.model;

/** Perfil de acesso de um utilizador. */
public enum Perfil {
    ADMIN("Administrador"),
    CLIENTE("Cliente");

    private final String descricao;

    Perfil(String descricao) {
        this.descricao = descricao;
    }

    public String getDescricao() {
        return descricao;
    }
}
