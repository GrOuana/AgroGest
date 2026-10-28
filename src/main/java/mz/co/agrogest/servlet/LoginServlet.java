package mz.co.agrogest.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import mz.co.agrogest.filter.Sessao;
import mz.co.agrogest.model.Utilizador;
import mz.co.agrogest.service.RegraNegocioException;

@WebServlet("/login")
public class LoginServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (utilizador(req) != null) {
            redirect(req, resp, "/");
            return;
        }
        vista(req, resp, "login");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            Utilizador u = servicos.auth().autenticar(texto(req, "email"), req.getParameter("password"));
            HttpSession s = req.getSession();
            String destino = (String) s.getAttribute(Sessao.DESTINO);
            s.removeAttribute(Sessao.DESTINO);
            // Novo ID de sessão após o login (evita fixação de sessão)
            req.changeSessionId();
            s.setAttribute(Sessao.UTILIZADOR, u);

            if (u.isAdmin()) {
                redirect(req, resp, "/admin/dashboard");
            } else if (destino != null && destino.startsWith("/") && !destino.startsWith("//")) {
                redirect(req, resp, destino);
            } else {
                redirect(req, resp, "/catalogo");
            }
        } catch (RegraNegocioException e) {
            erro(req, e);
            vista(req, resp, "login");
        }
    }
}
