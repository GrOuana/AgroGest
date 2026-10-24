package mz.co.agrogest.servlet.admin;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import mz.co.agrogest.model.Venda;
import mz.co.agrogest.servlet.BaseServlet;

/**
 * Compras detalhadas: cliente, endereço, telefone, produtos, quantidades,
 * valor unitário, subtotal, total e data. Ordenação: ?ordem=data|valor|cliente&dir=desc
 */
@WebServlet("/admin/compras")
public class ComprasServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String ordem = texto(req, "ordem");
        if (ordem == null || !ordem.matches("[a-z]{1,20}")) {
            ordem = "data";
        }
        // Por omissão as compras mais recentes primeiro
        boolean desc = req.getParameter("dir") == null || descendente(req);
        List<Venda> vendas = servicos.relatorio().compras(ordem, desc);
        BigDecimal total = BigDecimal.ZERO;
        for (Venda v : vendas) {
            total = total.add(v.getTotal());
        }
        req.setAttribute("vendas", vendas);
        req.setAttribute("totalGeral", total);
        req.setAttribute("ordem", ordem);
        req.setAttribute("dir", desc ? "desc" : "asc");
        vista(req, resp, "admin/compras");
    }
}
