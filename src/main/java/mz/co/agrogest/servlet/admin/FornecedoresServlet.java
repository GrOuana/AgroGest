package mz.co.agrogest.servlet.admin;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import mz.co.agrogest.model.Fornecedor;
import mz.co.agrogest.model.TipoFornecedor;
import mz.co.agrogest.service.RegraNegocioException;
import mz.co.agrogest.servlet.BaseServlet;

/** Criar, listar e remover fornecedores. POST com accao=criar|remover. */
@WebServlet("/admin/fornecedores")
public class FornecedoresServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("fornecedores", servicos.catalogo().listarFornecedores());
        req.setAttribute("tipos", TipoFornecedor.values());
        vista(req, resp, "admin/fornecedores");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            String accao = texto(req, "accao");
            if ("criar".equals(accao)) {
                Fornecedor f = servicos.catalogo().criarFornecedor(texto(req, "nome"),
                        enumeracao(req, "tipo", TipoFornecedor.class, "Tipo"),
                        texto(req, "contacto"), texto(req, "provincia"));
                sucesso(req, "Fornecedor «" + f.getNome() + "» criado.");
            } else if ("remover".equals(accao)) {
                servicos.catalogo().removerFornecedor(inteiro(req, "id", "Fornecedor"));
                sucesso(req, "Fornecedor removido.");
            } else {
                throw new RegraNegocioException("Acção desconhecida.");
            }
            redirect(req, resp, "/admin/fornecedores");
        } catch (RegraNegocioException e) {
            erro(req, e.getMessage());
            doGet(req, resp);
        }
    }
}
