package mz.co.agrogest.servlet.admin;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import mz.co.agrogest.servlet.BaseServlet;

/** Os quatro relatórios de clientes do enunciado. */
@WebServlet("/admin/relatorios")
public class RelatoriosServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("porNome", servicos.relatorio().clientesPorNome());
        req.setAttribute("porVolume", servicos.relatorio().clientesPorVolume());
        req.setAttribute("assiduos", servicos.relatorio().clientesMaisAssiduos());
        req.setAttribute("semCompras", servicos.relatorio().clientesSemCompras());
        vista(req, resp, "admin/relatorios");
    }
}
