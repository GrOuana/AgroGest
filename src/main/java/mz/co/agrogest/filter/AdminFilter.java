package mz.co.agrogest.filter;

import java.io.IOException;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/** RN04: as rotas /admin/* são exclusivas do administrador — qualquer outro recebe HTTP 403. */
@WebFilter(filterName = "AdminFilter", urlPatterns = "/admin/*")
public class AdminFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        boolean admin = Sessao.utilizador(req).map(u -> u.isAdmin()).orElse(false);
        if (!admin) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Área reservada ao administrador.");
            return;
        }
        chain.doFilter(req, resp);
    }
}
