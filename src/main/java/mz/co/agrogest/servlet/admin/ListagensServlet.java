package mz.co.agrogest.servlet.admin;

import java.io.IOException;
import java.util.Set;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import mz.co.agrogest.servlet.BaseServlet;

/**
 * Listagens ordenáveis: /admin/listagens?tipo=produtos&ordem=preco&dir=desc
 * tipo = produtos | fornecedores | clientes | armazem. As compras detalhadas
 * estão em /admin/compras. A ordenação é feita no serviço; a JSP só mostra.
 */
@WebServlet("/admin/listagens")
public class ListagensServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;

    private static final Set<String> TIPOS = Set.of("produtos", "fornecedores", "clientes", "armazem");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String tipo = texto(req, "tipo");
        if (tipo == null || !TIPOS.contains(tipo)) {
            tipo = "produtos";
        }
        String ordem = texto(req, "ordem");
        if (ordem == null || !ordem.matches("[a-z]{1,20}")) {
            ordem = "nome";
        }
        boolean desc = descendente(req);

        switch (tipo) {
            case "fornecedores":
                req.setAttribute("itens", servicos.relatorio().fornecedores(ordem, desc));
                break;
            case "clientes":
                req.setAttribute("itens", servicos.relatorio().clientes(ordem, desc));
                break;
            case "armazem":
                req.setAttribute("itens", servicos.relatorio().armazem(ordem, desc));
                break;
            default:
                req.setAttribute("itens", servicos.relatorio().produtos(ordem, desc));
        }
        req.setAttribute("tipo", tipo);
        req.setAttribute("ordem", ordem);
        req.setAttribute("dir", desc ? "desc" : "asc");
        vista(req, resp, "admin/listagens");
    }
}
