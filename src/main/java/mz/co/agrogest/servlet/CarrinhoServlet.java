package mz.co.agrogest.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import mz.co.agrogest.model.Carrinho;
import mz.co.agrogest.service.RegraNegocioException;

/**
 * Carrinho em sessão.
 *   GET  /carrinho              ver linhas e totais
 *   POST /carrinho/adicionar    produtoId, quantidade
 *   POST /carrinho/actualizar   produtoId, quantidade
 *   POST /carrinho/remover      produtoId
 *   POST /carrinho/esvaziar
 */
@WebServlet({"/carrinho", "/carrinho/*"})
public class CarrinhoServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("resumo", servicos.carrinho().resumo(carrinho(req)));
        vista(req, resp, "cliente/carrinho");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String accao = req.getPathInfo() == null ? "" : req.getPathInfo();
        Carrinho carrinho = carrinho(req);
        String voltar = "/carrinho";
        try {
            switch (accao) {
                case "/adicionar": {
                    int id = inteiro(req, "produtoId", "Produto");
                    int qtd = inteiro(req, "quantidade", "Quantidade");
                    servicos.carrinho().adicionar(carrinho, id, qtd);
                    String nome = servicos.catalogo().procurarProduto(id).map(p -> p.getNome()).orElse("Produto");
                    sucesso(req, "«" + nome + "» adicionado ao carrinho (" + qtd + ").");
                    voltar = destinoCatalogo(req);
                    break;
                }
                case "/actualizar":
                    servicos.carrinho().actualizar(carrinho, inteiro(req, "produtoId", "Produto"),
                            inteiro(req, "quantidade", "Quantidade"));
                    sucesso(req, "Quantidade actualizada.");
                    break;
                case "/remover":
                    servicos.carrinho().remover(carrinho, inteiro(req, "produtoId", "Produto"));
                    sucesso(req, "Produto removido do carrinho.");
                    break;
                case "/esvaziar":
                    servicos.carrinho().esvaziar(carrinho);
                    sucesso(req, "O carrinho foi esvaziado.");
                    break;
                default:
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
            }
        } catch (RegraNegocioException e) {
            erroAposRedirect(req, e.getMessage());
            if ("/adicionar".equals(accao)) {
                voltar = destinoCatalogo(req);
            }
        }
        redirect(req, resp, voltar);
    }

    /** Volta ao catálogo com o mesmo filtro de categoria, se o formulário o indicar. */
    private String destinoCatalogo(HttpServletRequest req) {
        String categoria = texto(req, "categoria");
        if (categoria != null && categoria.matches("[A-Z]+")) {
            return "/catalogo?categoria=" + categoria;
        }
        return "/catalogo";
    }
}
