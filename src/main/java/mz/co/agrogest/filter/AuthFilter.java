package mz.co.agrogest.filter;

import java.io.IOException;
import java.util.Optional;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import mz.co.agrogest.model.Utilizador;

/**
 * RN05: /catalogo, /carrinho/*, /compra, /factura e /minhas-compras exigem
 * sessão iniciada. Sem sessão, o utilizador é enviado para o login e volta
 * à página pedida depois de entrar.
 *
 * O carrinho, a compra e o histórico são do cliente: o administrador recebe 403.
 */
@WebFilter(filterName = "AuthFilter",
        urlPatterns = {"/catalogo", "/carrinho", "/carrinho/*", "/compra", "/factura", "/minhas-compras"})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        Optional<Utilizador> u = Sessao.utilizador(req);
        if (u.isEmpty()) {
            if ("GET".equals(req.getMethod())) {
                String destino = req.getServletPath() + (req.getQueryString() == null ? "" : "?" + req.getQueryString());
                req.getSession().setAttribute(Sessao.DESTINO, destino);
            }
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String caminho = req.getServletPath();
        boolean soCliente = caminho.startsWith("/carrinho") || caminho.equals("/compra")
                || caminho.equals("/minhas-compras");
        if (soCliente && !u.get().isCliente()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Área reservada a clientes.");
            return;
        }
        chain.doFilter(req, resp);
    }
}
