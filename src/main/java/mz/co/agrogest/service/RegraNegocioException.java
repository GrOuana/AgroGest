package mz.co.agrogest.service;

/**
 * Violação de uma regra de negócio ou validação, com mensagem para o utilizador.
 * Quando o erro é de um campo concreto, {@link #getCampo()} devolve o nome do
 * parâmetro do formulário (ex.: "telefone"), para a JSP o assinalar.
 */
public class RegraNegocioException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    private final String campo;

    public RegraNegocioException(String mensagem) {
        this(mensagem, null);
    }

    public RegraNegocioException(String mensagem, String campo) {
        super(mensagem);
        this.campo = campo;
    }

    public String getCampo() {
        return campo;
    }
}
