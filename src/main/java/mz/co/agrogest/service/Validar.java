package mz.co.agrogest.service;

import java.math.BigDecimal;
import java.util.regex.Pattern;

/** Validações comuns aos serviços. Lançam RegraNegocioException com mensagem em português. */
final class Validar {

    static final int QUANTIDADE_MAXIMA = 1_000_000;

    private static final Pattern EMAIL = Pattern.compile("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$");

    private Validar() {
    }

    static String obrigatorio(String valor, String campo) {
        if (valor == null || valor.isBlank()) {
            throw new RegraNegocioException("O campo «" + campo + "» é obrigatório.");
        }
        String v = valor.trim();
        if (v.length() > 200) {
            throw new RegraNegocioException("O campo «" + campo + "» é demasiado longo (máximo 200 caracteres).");
        }
        return v;
    }

    static String opcional(String valor) {
        if (valor == null || valor.isBlank()) {
            return null;
        }
        String v = valor.trim();
        return v.length() > 500 ? v.substring(0, 500) : v;
    }

    static String email(String valor) {
        String v = obrigatorio(valor, "Email").toLowerCase();
        if (!EMAIL.matcher(v).matches()) {
            throw new RegraNegocioException("O email «" + v + "» não é válido.");
        }
        return v;
    }

    static <T> T presente(T valor, String campo) {
        if (valor == null) {
            throw new RegraNegocioException("O campo «" + campo + "» é obrigatório.");
        }
        return valor;
    }

    static BigDecimal positivo(BigDecimal valor, String campo) {
        presente(valor, campo);
        if (valor.signum() <= 0) {
            throw new RegraNegocioException("O campo «" + campo + "» tem de ser maior que zero.");
        }
        return valor;
    }

    static int positivo(int valor, String campo) {
        if (valor <= 0) {
            throw new RegraNegocioException("O campo «" + campo + "» tem de ser maior que zero.");
        }
        return maximo(valor, campo);
    }

    static int naoNegativo(int valor, String campo) {
        if (valor < 0) {
            throw new RegraNegocioException("O campo «" + campo + "» não pode ser negativo.");
        }
        return maximo(valor, campo);
    }

    private static int maximo(int valor, String campo) {
        if (valor > QUANTIDADE_MAXIMA) {
            throw new RegraNegocioException("O campo «" + campo + "» não pode passar de " + QUANTIDADE_MAXIMA + ".");
        }
        return valor;
    }
}
