package mz.co.agrogest.servlet.admin;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import mz.co.agrogest.model.Campanha;
import mz.co.agrogest.service.RegraNegocioException;
import mz.co.agrogest.servlet.BaseServlet;

/** Campanhas: criar, fechar, reabrir e remover (só sem cultivos). */
@WebServlet("/admin/campanhas")
public class CampanhasServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<Campanha> campanhas = servicos.producao().listarCampanhas();
        Map<Integer, Integer> cultivos = new HashMap<>();
        for (Campanha c : campanhas) {
            cultivos.put(c.getId(), servicos.producao().contarCultivos(c.getId()));
        }
        req.setAttribute("campanhas", campanhas);
        req.setAttribute("numCultivos", cultivos);
        vista(req, resp, "admin/campanhas");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            String accao = texto(req, "accao");
            switch (accao == null ? "" : accao) {
                case "criar": {
                    Campanha c = servicos.producao().criarCampanha(texto(req, "nome"),
                            data(req, "inicio", "Data de início"), data(req, "fim", "Data de fim"));
                    sucesso(req, "Campanha «" + c.getNome() + "» criada.");
                    break;
                }
                case "fechar":
                    sucesso(req, "Campanha «" + servicos.producao().fecharCampanha(inteiro(req, "id", "Campanha"))
                            .getNome() + "» fechada.");
                    break;
                case "reabrir":
                    sucesso(req, "Campanha «" + servicos.producao().reabrirCampanha(inteiro(req, "id", "Campanha"))
                            .getNome() + "» reaberta.");
                    break;
                case "remover":
                    servicos.producao().removerCampanha(inteiro(req, "id", "Campanha"));
                    sucesso(req, "Campanha removida.");
                    break;
                default:
                    throw new RegraNegocioException("Acção desconhecida.");
            }
            redirect(req, resp, "/admin/campanhas");
        } catch (RegraNegocioException e) {
            erro(req, e.getMessage());
            doGet(req, resp);
        }
    }
}
