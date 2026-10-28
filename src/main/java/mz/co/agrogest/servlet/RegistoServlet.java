package mz.co.agrogest.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import mz.co.agrogest.filter.Sessao;
import mz.co.agrogest.model.Utilizador;
import mz.co.agrogest.service.RegraNegocioException;

/** Auto-registo de clientes. Depois de registado, o cliente entra directamente. */
@WebServlet("/registo")
public class RegistoServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        vista(req, resp, "registo-cliente");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            Utilizador u = servicos.auth().registarCliente(texto(req, "nome"), texto(req, "email"),
                    req.getParameter("password"), req.getParameter("confirmacao"),
                    texto(req, "telefone"), texto(req, "endereco"));
            req.getSession();
            req.changeSessionId();
            req.getSession().setAttribute(Sessao.UTILIZADOR, u);
            sucesso(req, "Bem-vindo(a), " + u.getNome() + "! A sua conta foi criada.");
            redirect(req, resp, "/catalogo");
        } catch (RegraNegocioException e) {
            erro(req, e);
            vista(req, resp, "registo-cliente");
        }
    }
}
