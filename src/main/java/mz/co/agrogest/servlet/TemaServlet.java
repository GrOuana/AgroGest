package mz.co.agrogest.servlet;

import java.io.IOException;
import java.util.Set;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Escolha do tema (claro, escuro ou o do sistema) sem JavaScript.
 *
 * O formulário do cabeçalho faz POST /tema com modo=claro|escuro|sistema e
 * voltar=página actual. A escolha fica num cookie de um ano, lido pelas JSP
 * (prelude.jspf), que marcam <html data-theme="...">; o CSS faz o resto.
 */
@WebServlet("/tema")
public class TemaServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;

    public static final String COOKIE = "agrogest_tema";
    private static final Set<String> MODOS = Set.of("claro", "escuro");
    private static final int UM_ANO = 365 * 24 * 60 * 60;

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String modo = texto(req, "modo");
        Cookie c;
        if (modo != null && MODOS.contains(modo)) {
            c = new Cookie(COOKIE, modo);
            c.setMaxAge(UM_ANO);
        } else {
            // "sistema" (ou valor desconhecido): apagar a escolha e seguir o sistema operativo
            c = new Cookie(COOKIE, "");
            c.setMaxAge(0);
        }
        c.setPath(req.getContextPath().isEmpty() ? "/" : req.getContextPath());
        c.setHttpOnly(true);
        c.setAttribute("SameSite", "Lax");
        resp.addCookie(c);
        resp.sendRedirect(destino(req));
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        redirect(req, resp, "/");
    }

    /**
     * Volta à página onde o utilizador estava, mas só se for um caminho desta
     * aplicação (evita redirecionamentos abertos para outros sites).
     */
    private String destino(HttpServletRequest req) {
        String ctx = req.getContextPath();
        String voltar = req.getParameter("voltar");
        if (voltar != null && voltar.startsWith(ctx + "/") && !voltar.startsWith("//")
                && !voltar.contains("://") && voltar.matches("[\\w\\-./?=&%]*")) {
            return voltar;
        }
        return ctx + "/";
    }
}
