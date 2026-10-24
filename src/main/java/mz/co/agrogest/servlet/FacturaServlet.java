package mz.co.agrogest.servlet;

import java.io.IOException;
import java.util.Optional;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import mz.co.agrogest.model.Venda;

/**
 * Factura de uma venda: /factura?id=7 (com &imprimir=1 para a versão de impressão).
 * RN03: o cliente só vê as suas; o administrador vê todas.
 */
@WebServlet("/factura")
public class FacturaServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer id = inteiroOpcional(req, "id");
        Optional<Venda> venda = id == null ? Optional.empty() : servicos.venda().procurar(id);
        if (venda.isEmpty()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Factura não encontrada.");
            return;
        }
        if (!servicos.venda().podeVer(utilizador(req), venda.get())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Esta factura pertence a outro cliente.");
            return;
        }
        req.setAttribute("venda", venda.get());
        boolean imprimir = "1".equals(req.getParameter("imprimir"));
        vista(req, resp, imprimir ? "cliente/factura-imprimir" : "cliente/factura");
    }
}
