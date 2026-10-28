package mz.co.agrogest.service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.regex.Pattern;

/**
 * Validações do servidor. São as mesmas regras dos atributos HTML5 dos
 * formulários (pattern, min, maxlength), repetidas aqui porque a validação do
 * browser pode ser contornada. Cada erro indica o campo do formulário.
 */
public final class Validar {

    static final int QUANTIDADE_MAXIMA = 1_000_000;
    static final BigDecimal VALOR_MAXIMO = new BigDecimal("100000000");

    /** Letras (com acentos portugueses), sem ×/÷ que estão no intervalo À-ÿ. */
    private static final String LETRAS = "A-Za-zÀ-ÖØ-öø-ÿ";

    /** Telemóvel moçambicano: 9 dígitos, 82–87 (Tmcel, Vodacom, Movitel). */
    public static final Pattern TELEFONE_MZ = Pattern.compile("^8[2-7]\\d{7}$");
    /** Nome de pessoa: só letras, espaços, hífen e apóstrofo. */
    public static final Pattern NOME_PESSOA = Pattern.compile("^[" + LETRAS + "][" + LETRAS + " '\\-]*$");
    /** Nome de empresa ou local: letras e pontuação de nomes comerciais, sem números. */
    public static final Pattern NOME_ENTIDADE = Pattern.compile("^[" + LETRAS + "][" + LETRAS + " .,&'\\-]*$");
    /** Unidade de medida: só letras (kg, saco, unidade, litro). */
    public static final Pattern UNIDADE = Pattern.compile("^[" + LETRAS + "]{1,20}$");
    public static final Pattern EMAIL = Pattern.compile("^[^@\\s]+@[^@\\s]+\\.[^@\\s]{2,}$");

    private Validar() {
    }

    // ----------------------------------------------------------------- texto

    static String obrigatorio(String valor, String rotulo, String campo) {
        return obrigatorio(valor, rotulo, campo, 200);
    }

    static String obrigatorio(String valor, String rotulo, String campo, int maximo) {
        if (valor == null || valor.isBlank()) {
            throw new RegraNegocioException("O campo «" + rotulo + "» é obrigatório.", campo);
        }
        String v = valor.trim().replaceAll("\\s+", " ");
        if (v.length() > maximo) {
            throw new RegraNegocioException("O campo «" + rotulo + "» tem no máximo " + maximo + " caracteres.", campo);
        }
        return v;
    }

    static String opcional(String valor, int maximo) {
        if (valor == null || valor.isBlank()) {
            return null;
        }
        String v = valor.trim();
        return v.length() > maximo ? v.substring(0, maximo) : v;
    }

    static String padrao(String valor, Pattern padrao, String rotulo, String campo, String explicacao) {
        String v = obrigatorio(valor, rotulo, campo);
        if (!padrao.matcher(v).matches()) {
            throw new RegraNegocioException("«" + rotulo + "» inválido: " + explicacao, campo);
        }
        return v;
    }

    static String nomePessoa(String valor, String campo) {
        String v = padrao(valor, NOME_PESSOA, "Nome", campo, "use só letras e espaços, sem números.");
        if (v.replace(" ", "").length() < 2) {
            throw new RegraNegocioException("O nome tem de ter pelo menos 2 letras.", campo);
        }
        return v;
    }

    static String nomeEntidade(String valor, String rotulo, String campo) {
        return padrao(valor, NOME_ENTIDADE, rotulo, campo, "use letras, espaços e . , & ' -, sem números.");
    }

    static String telefone(String valor, String campo) {
        // Aceita espaços ao escrever ("84 123 4567"), mas guarda só os 9 dígitos
        String v = valor == null ? null : valor.replace(" ", "");
        return padrao(v, TELEFONE_MZ, "Telefone", campo,
                "9 dígitos a começar por 82, 83, 84, 85, 86 ou 87 (ex.: 841234567).");
    }

    static String email(String valor, String campo) {
        String v = obrigatorio(valor, "Email", campo, 120).toLowerCase();
        if (!EMAIL.matcher(v).matches()) {
            throw new RegraNegocioException("O email «" + v + "» não é válido (ex.: nome@dominio.mz).", campo);
        }
        return v;
    }

    /** URL da foto: vazio, endereço http(s) ou caminho dentro da aplicação (img/…). */
    static String fotoUrl(String valor, String campo) {
        String v = opcional(valor, 500);
        if (v != null && !(v.startsWith("https://") || v.startsWith("http://") || v.matches("^img/[\\w./-]+$"))) {
            throw new RegraNegocioException("A foto tem de ser um endereço http(s):// ou um caminho img/….", campo);
        }
        return v;
    }

    // --------------------------------------------------------------- valores

    static <T> T presente(T valor, String rotulo, String campo) {
        if (valor == null) {
            throw new RegraNegocioException("O campo «" + rotulo + "» é obrigatório.", campo);
        }
        return valor;
    }

    static BigDecimal positivo(BigDecimal valor, String rotulo, String campo) {
        presente(valor, rotulo, campo);
        if (valor.signum() <= 0) {
            throw new RegraNegocioException("O campo «" + rotulo + "» tem de ser maior que zero.", campo);
        }
        if (valor.compareTo(VALOR_MAXIMO) > 0) {
            throw new RegraNegocioException("O campo «" + rotulo + "» é demasiado alto.", campo);
        }
        return valor;
    }

    /** Valor monetário: positivo e com no máximo 2 casas decimais. */
    static BigDecimal dinheiro(BigDecimal valor, String rotulo, String campo) {
        positivo(valor, rotulo, campo);
        if (valor.stripTrailingZeros().scale() > 2) {
            throw new RegraNegocioException("O campo «" + rotulo + "» aceita no máximo 2 casas decimais.", campo);
        }
        return valor;
    }

    static int positivo(int valor, String rotulo, String campo) {
        if (valor <= 0) {
            throw new RegraNegocioException("O campo «" + rotulo + "» tem de ser maior que zero.", campo);
        }
        return maximo(valor, rotulo, campo);
    }

    static int naoNegativo(int valor, String rotulo, String campo) {
        if (valor < 0) {
            throw new RegraNegocioException("O campo «" + rotulo + "» não pode ser negativo.", campo);
        }
        return maximo(valor, rotulo, campo);
    }

    private static int maximo(int valor, String rotulo, String campo) {
        if (valor > QUANTIDADE_MAXIMA) {
            throw new RegraNegocioException("O campo «" + rotulo + "» não pode passar de " + QUANTIDADE_MAXIMA + ".", campo);
        }
        return valor;
    }

    static LocalDate naoPassada(LocalDate data, String rotulo, String campo) {
        if (data != null && data.isBefore(LocalDate.now())) {
            throw new RegraNegocioException("A «" + rotulo + "» não pode estar no passado.", campo);
        }
        return data;
    }
}
