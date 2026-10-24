package mz.co.agrogest.servlet.admin;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import mz.co.agrogest.service.RelatorioService;
import mz.co.agrogest.servlet.BaseServlet;

@WebServlet({"/admin", "/admin/dashboard"})
public class DashboardServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("painel", servicos.relatorio().painel());
        req.setAttribute("limiteStock", RelatorioService.LIMITE_STOCK_BAIXO);
        vista(req, resp, "admin/dashboard");
    }
}
