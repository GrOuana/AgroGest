package mz.co.agrogest.servlet;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import mz.co.agrogest.filter.Sessao;
import mz.co.agrogest.model.Carrinho;
import mz.co.agrogest.model.Utilizador;
import mz.co.agrogest.service.RegraNegocioException;
import mz.co.agrogest.service.Servicos;

/**
 * Base dos controladores: obtém os serviços, encaminha para as JSP em
 * WEB-INF/jsp, faz redirect com mensagem (padrão Post/Redirect/Get) e
 * converte parâmetros do pedido. Os servlets não guardam dados.
 */
public abstract class BaseServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected transient Servicos servicos;

    @Override
    public void init() throws ServletException {
        servicos = Sessao.servicos(getServletContext());
        if (servicos == null) {
            throw new ServletException("Serviços do AgroGest não inicializados (AppListener).");
        }
    }

    // ---------------------------------------------------------------- vistas

    protected void vista(HttpServletRequest req, HttpServletResponse resp, String jsp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/jsp/" + jsp + ".jsp").forward(req, resp);
    }

    protected void redirect(HttpServletRequest req, HttpServletResponse resp, String caminho) throws IOException {
        resp.sendRedirect(req.getContextPath() + caminho);
    }

    protected void sucesso(HttpServletRequest req, String mensagem) {
        req.getSession().setAttribute(Sessao.FLASH, mensagem);
    }

    protected void erro(HttpServletRequest req, String mensagem) {
        req.setAttribute("erro", mensagem);
    }

    protected void erroAposRedirect(HttpServletRequest req, String mensagem) {
        req.getSession().setAttribute(Sessao.FLASH_ERRO, mensagem);
    }

    // ---------------------------------------------------------------- sessão

    protected Utilizador utilizador(HttpServletRequest req) {
        return Sessao.utilizador(req).orElse(null);
    }

    protected Carrinho carrinho(HttpServletRequest req) {
        HttpSession s = req.getSession();
        synchronized (s) {
            Carrinho c = (Carrinho) s.getAttribute(Sessao.CARRINHO);
            if (c == null) {
                c = new Carrinho();
                s.setAttribute(Sessao.CARRINHO, c);
            }
            return c;
        }
    }

    // ------------------------------------------------------------ parâmetros

    protected String texto(HttpServletRequest req, String nome) {
        String v = req.getParameter(nome);
        return v == null ? null : v.trim();
    }

    protected int inteiro(HttpServletRequest req, String nome, String campo) {
        String v = texto(req, nome);
        if (v == null || v.isEmpty()) {
            throw new RegraNegocioException("O campo «" + campo + "» é obrigatório.");
        }
        try {
            return Integer.parseInt(v);
        } catch (NumberFormatException e) {
            throw new RegraNegocioException("O campo «" + campo + "» tem de ser um número inteiro.");
        }
    }

    protected Integer inteiroOpcional(HttpServletRequest req, String nome) {
        String v = texto(req, nome);
        if (v == null || v.isEmpty()) {
            return null;
        }
        try {
            return Integer.valueOf(v);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    protected BigDecimal decimal(HttpServletRequest req, String nome, String campo) {
        String v = texto(req, nome);
        if (v == null || v.isEmpty()) {
            throw new RegraNegocioException("O campo «" + campo + "» é obrigatório.");
        }
        try {
            // Aceita 22,5 e 22.5
            return new BigDecimal(v.replace(" ", "").replace(',', '.'));
        } catch (NumberFormatException e) {
            throw new RegraNegocioException("O campo «" + campo + "» tem de ser um número.");
        }
    }

    protected LocalDate data(HttpServletRequest req, String nome, String campo) {
        LocalDate d = dataOpcional(req, nome, campo);
        if (d == null) {
            throw new RegraNegocioException("O campo «" + campo + "» é obrigatório.");
        }
        return d;
    }

    protected LocalDate dataOpcional(HttpServletRequest req, String nome, String campo) {
        String v = texto(req, nome);
        if (v == null || v.isEmpty()) {
            return null;
        }
        try {
            return LocalDate.parse(v);
        } catch (DateTimeParseException e) {
            throw new RegraNegocioException("O campo «" + campo + "» não tem uma data válida.");
        }
    }

    protected <E extends Enum<E>> E enumeracao(HttpServletRequest req, String nome, Class<E> tipo, String campo) {
        E e = enumeracaoOpcional(req, nome, tipo);
        if (e == null) {
            throw new RegraNegocioException("Escolha um valor válido para «" + campo + "».");
        }
        return e;
    }

    protected <E extends Enum<E>> E enumeracaoOpcional(HttpServletRequest req, String nome, Class<E> tipo) {
        String v = texto(req, nome);
        if (v == null || v.isEmpty()) {
            return null;
        }
        try {
            return Enum.valueOf(tipo, v);
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    /** Ordenação das listagens: ?ordem=nome&dir=desc */
    protected boolean descendente(HttpServletRequest req) {
        return "desc".equalsIgnoreCase(texto(req, "dir"));
    }
}
