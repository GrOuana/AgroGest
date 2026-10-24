package mz.co.agrogest.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import mz.co.agrogest.model.Categoria;

/** Catálogo público (com sessão), filtrado por categoria: /catalogo?categoria=SEMENTE */
@WebServlet("/catalogo")
public class CatalogoServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Categoria categoria = enumeracaoOpcional(req, "categoria", Categoria.class);
        req.setAttribute("categorias", Categoria.values());
        req.setAttribute("categoriaActual", categoria);
        req.setAttribute("produtos", servicos.catalogo().catalogo(categoria));
        if (utilizador(req).isCliente()) {
            req.setAttribute("noCarrinho", carrinho(req).getItens());
        }
        vista(req, resp, "cliente/catalogo");
    }
}
