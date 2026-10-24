package mz.co.agrogest.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/** Histórico de compras do cliente autenticado (só as suas — RN03). */
@WebServlet("/minhas-compras")
public class MinhasComprasServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("vendas", servicos.venda().historicoDoCliente(utilizador(req).getId()));
        vista(req, resp, "cliente/minhas-compras");
    }
}
