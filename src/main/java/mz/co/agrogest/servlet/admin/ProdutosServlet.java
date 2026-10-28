package mz.co.agrogest.servlet.admin;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import mz.co.agrogest.model.Categoria;
import mz.co.agrogest.model.Produto;
import mz.co.agrogest.service.RegraNegocioException;
import mz.co.agrogest.servlet.BaseServlet;

/**
 * Produtos: criar, listar, actualizar, repor stock e remover.
 *   GET  /admin/produtos              lista + formulário de criação
 *   GET  /admin/produtos?editar=ID    formulário de edição
 *   POST accao=criar|actualizar|repor|remover
 */
@WebServlet("/admin/produtos")
public class ProdutosServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("produtos", servicos.catalogo().listarProdutos());
        req.setAttribute("fornecedores", servicos.catalogo().listarFornecedores());
        req.setAttribute("categorias", Categoria.values());
        Integer editar = inteiroOpcional(req, "editar");
        if (editar != null && req.getAttribute("produtoEditar") == null) {
            servicos.catalogo().procurarProduto(editar).ifPresent(p -> req.setAttribute("produtoEditar", p));
        }
        vista(req, resp, "admin/produtos");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String accao = texto(req, "accao");
        try {
            switch (accao == null ? "" : accao) {
                case "criar": {
                    Produto p = servicos.catalogo().criarProduto(texto(req, "nome"),
                            enumeracao(req, "categoria", Categoria.class, "Categoria"),
                            inteiro(req, "fornecedorId", "Fornecedor"), decimal(req, "preco", "Preço"),
                            inteiro(req, "quantidade", "Quantidade"), texto(req, "unidade"),
                            texto(req, "descricao"), texto(req, "fotoUrl"),
                            dataOpcional(req, "validade", "Validade"));
                    sucesso(req, "Produto «" + p.getNome() + "» criado.");
                    break;
                }
                case "actualizar": {
                    Produto p = servicos.catalogo().actualizarProduto(inteiro(req, "id", "Produto"),
                            texto(req, "nome"), enumeracao(req, "categoria", Categoria.class, "Categoria"),
                            inteiro(req, "fornecedorId", "Fornecedor"), decimal(req, "preco", "Preço"),
                            inteiro(req, "quantidade", "Quantidade"), texto(req, "unidade"),
                            texto(req, "descricao"), texto(req, "fotoUrl"),
                            dataOpcional(req, "validade", "Validade"));
                    sucesso(req, "Produto «" + p.getNome() + "» actualizado.");
                    break;
                }
                case "repor": {
                    int qtd = inteiro(req, "quantidade", "Quantidade a repor");
                    Produto p = servicos.catalogo().reporStock(inteiro(req, "id", "Produto"), qtd);
                    sucesso(req, "Stock de «" + p.getNome() + "» reposto: +" + qtd + " (agora "
                            + p.getQuantidade() + " " + p.getUnidade() + ").");
                    break;
                }
                case "remover":
                    servicos.catalogo().removerProduto(inteiro(req, "id", "Produto"));
                    sucesso(req, "Produto removido.");
                    break;
                default:
                    throw new RegraNegocioException("Acção desconhecida.");
            }
            redirect(req, resp, "/admin/produtos");
        } catch (RegraNegocioException e) {
            erro(req, e);
            Integer id = inteiroOpcional(req, "id");
            if ("actualizar".equals(accao) && id != null) {
                // Voltar ao formulário de edição com os valores que o utilizador escreveu
                servicos.catalogo().procurarProduto(id).ifPresent(p -> req.setAttribute("produtoEditar", p));
                req.setAttribute("emEdicao", true);
            }
            doGet(req, resp);
        }
    }
}
