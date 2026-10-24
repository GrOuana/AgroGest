package mz.co.agrogest.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import mz.co.agrogest.model.Carrinho;
import mz.co.agrogest.model.ResumoCarrinho;
import mz.co.agrogest.model.Venda;
import mz.co.agrogest.service.RegraNegocioException;

/**
 * Checkout.
 *   GET  /compra   página de confirmação com os totais
 *   POST /compra   confirma: VendaService desconta o stock e emite a factura
 */
@WebServlet("/compra")
public class CompraServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        ResumoCarrinho resumo = servicos.carrinho().resumo(carrinho(req));
        if (resumo.isVazio()) {
            erroAposRedirect(req, "O carrinho está vazio. Adicione produtos antes de finalizar a compra.");
            redirect(req, resp, "/catalogo");
            return;
        }
        req.setAttribute("resumo", resumo);
        req.setAttribute("cliente", utilizador(req));
        vista(req, resp, "cliente/compra");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Carrinho carrinho = carrinho(req);
        try {
            Venda venda;
            // Lock do carrinho: um duplo clique em «Confirmar» não gera duas vendas —
            // o segundo pedido espera e encontra o carrinho já vazio.
            synchronized (carrinho) {
                venda = servicos.venda().finalizarCompra(utilizador(req).getId(), carrinho.getItens());
                carrinho.esvaziar();
            }
            sucesso(req, "Compra concluída. Factura " + venda.getNumeroFactura() + " emitida.");
            redirect(req, resp, "/factura?id=" + venda.getId());
        } catch (RegraNegocioException e) {
            // RN01/RN02: nada foi descontado; o cliente volta ao carrinho com o aviso
            erroAposRedirect(req, e.getMessage());
            redirect(req, resp, "/carrinho");
        }
    }
}
