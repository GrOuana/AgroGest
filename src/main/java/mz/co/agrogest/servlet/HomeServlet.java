package mz.co.agrogest.servlet;

import java.io.IOException;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import mz.co.agrogest.model.Utilizador;

/** Raiz da aplicação: encaminha para o login, o painel ou o catálogo. */
@WebServlet("")
public class HomeServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Utilizador u = utilizador(req);
        if (u == null) {
            redirect(req, resp, "/login");
        } else if (u.isAdmin()) {
            redirect(req, resp, "/admin/dashboard");
        } else {
            redirect(req, resp, "/catalogo");
        }
    }
}
