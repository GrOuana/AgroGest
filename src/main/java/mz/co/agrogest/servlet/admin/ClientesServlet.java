package mz.co.agrogest.servlet.admin;

import java.io.IOException;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import mz.co.agrogest.model.Utilizador;
import mz.co.agrogest.service.RegraNegocioException;
import mz.co.agrogest.servlet.BaseServlet;

/** Gestão de clientes: activar / desactivar a conta (POST accao=alternar, id). */
@WebServlet("/admin/clientes")
public class ClientesServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        redirect(req, resp, "/admin/listagens?tipo=clientes");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            Utilizador u = servicos.auth().alternarAtivo(inteiro(req, "id", "Cliente"));
            sucesso(req, "Conta de " + u.getNome() + (u.isAtivo() ? " activada." : " desactivada."));
        } catch (RegraNegocioException e) {
            erroAposRedirect(req, e.getMessage());
        }
        redirect(req, resp, "/admin/listagens?tipo=clientes");
    }
}
