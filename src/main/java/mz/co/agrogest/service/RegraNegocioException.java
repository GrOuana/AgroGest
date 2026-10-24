package mz.co.agrogest.service;

/** Violação de uma regra de negócio ou validação, com mensagem para o utilizador. */
public class RegraNegocioException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    public RegraNegocioException(String mensagem) {
        super(mensagem);
    }
}
