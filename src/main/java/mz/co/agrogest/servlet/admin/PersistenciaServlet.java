package mz.co.agrogest.servlet.admin;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import mz.co.agrogest.filter.Sessao;
import mz.co.agrogest.model.Utilizador;
import mz.co.agrogest.service.AuthService;
import mz.co.agrogest.servlet.BaseServlet;

/**
 * Endpoint de persistência manual.
 *   POST accao=gravar     grava já o estado em dados.ser
 *   POST accao=eliminar   apaga dados.ser (e a cópia .bak)
 *   POST accao=repor      apaga a memória e volta aos dados de demonstração
 */
@WebServlet("/admin/persistencia")
public class PersistenciaServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("persistencia", servicos.persistencia());
        vista(req, resp, "admin/persistencia");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String accao = texto(req, "accao");
        try {
            if ("gravar".equals(accao)) {
                servicos.persistencia().gravar();
                sucesso(req, "Estado gravado em " + servicos.persistencia().getFicheiro() + ".");
            } else if ("eliminar".equals(accao)) {
                boolean apagou = servicos.persistencia().eliminar();
                sucesso(req, apagou ? "Ficheiro de dados eliminado. Os dados em memória mantêm-se até ao próximo arranque "
                        + "(e voltam a ser gravados ao encerrar, a não ser que reponha os dados de demonstração)."
                        : "Não havia ficheiro de dados para eliminar.");
            } else if ("repor".equals(accao)) {
                servicos.reporDadosDemonstracao();
                // A memória foi apagada: o administrador volta a ter sessão com a conta recriada
                Utilizador admin = servicos.auth().autenticar(AuthService.ADMIN_EMAIL, AuthService.ADMIN_PASSWORD);
                req.getSession().setAttribute(Sessao.UTILIZADOR, admin);
                sucesso(req, "Dados de demonstração repostos. Grave para os guardar em ficheiro.");
            } else {
                erroAposRedirect(req, "Acção desconhecida.");
            }
        } catch (IOException e) {
            erroAposRedirect(req, "Falha de escrita no ficheiro: " + e.getMessage());
        }
        redirect(req, resp, "/admin/persistencia");
    }
}
