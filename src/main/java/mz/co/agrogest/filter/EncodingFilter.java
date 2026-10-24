package mz.co.agrogest.filter;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;

/** UTF-8 em todos os pedidos e respostas, para os acentos dos formulários chegarem intactos. */
@WebFilter(filterName = "EncodingFilter", urlPatterns = "/*")
public class EncodingFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain)
            throws IOException, ServletException {
        if (req.getCharacterEncoding() == null) {
            req.setCharacterEncoding(StandardCharsets.UTF_8.name());
        }
        resp.setCharacterEncoding(StandardCharsets.UTF_8.name());
        chain.doFilter(req, resp);
    }
}
