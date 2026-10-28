package mz.co.agrogest.util;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Formatação para as vistas, exposta às JSP como funções EL (ver
 * WEB-INF/agrogest.tld): ${f:mt(valor)}, ${f:data(d)}, ${f:dataHora(d)}.
 */
public final class Formatos {

    private static final DateTimeFormatter DATA = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final DateTimeFormatter DATA_HORA = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private static final DateTimeFormatter ISO = DateTimeFormatter.ISO_LOCAL_DATE;

    private Formatos() {
    }

    private static DecimalFormat formato(String padrao) {
        DecimalFormatSymbols s = new DecimalFormatSymbols();
        s.setGroupingSeparator('.');
        s.setDecimalSeparator(',');
        return new DecimalFormat(padrao, s);
    }

    /** 70400 → "70.400,00 MT" */
    public static String mt(BigDecimal valor) {
        if (valor == null) {
            return "";
        }
        return formato("#,##0.00").format(valor) + " MT";
    }

    /** 8.5 → "8,5"; 3200 → "3.200" */
    public static String numero(BigDecimal valor) {
        if (valor == null) {
            return "";
        }
        return formato("#,##0.##").format(valor);
    }

    public static String data(LocalDate data) {
        return data == null ? "" : DATA.format(data);
    }

    public static String dataHora(LocalDateTime data) {
        return data == null ? "" : DATA_HORA.format(data);
    }

    /** 841234567 → "+258 84 123 4567"; outros formatos (dados antigos) ficam como estão. */
    public static String telefone(String numero) {
        if (numero == null) {
            return "";
        }
        if (numero.matches("^8[2-7]\\d{7}$")) {
            return "+258 " + numero.substring(0, 2) + " " + numero.substring(2, 5) + " " + numero.substring(5);
        }
        return numero;
    }

    /** Valor para um <input type="date">. */
    public static String iso(LocalDate data) {
        return data == null ? "" : ISO.format(data);
    }

    /** Endereço da foto: URL absoluto tal como está, caminho relativo dentro da aplicação. */
    public static String foto(String contexto, String url) {
        if (url == null || url.isBlank()) {
            return contexto + "/img/produtos/sem-foto.svg";
        }
        if (url.startsWith("http://") || url.startsWith("https://")) {
            return url;
        }
        return contexto + "/" + (url.startsWith("/") ? url.substring(1) : url);
    }
}
