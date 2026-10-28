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
import mz.co.agrogest.model.Cultivo;
import mz.co.agrogest.service.RegraNegocioException;
import mz.co.agrogest.servlet.BaseServlet;

/** Cultivos por campanha: /admin/cultivos?campanhaId=1. Não se removem cultivos com colheitas. */
@WebServlet("/admin/cultivos")
public class CultivosServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer campanhaId = inteiroOpcional(req, "campanhaId");
        List<Campanha> campanhas = servicos.producao().listarCampanhas();
        List<Cultivo> cultivos = servicos.producao().listarCultivos(campanhaId);

        Map<Integer, Campanha> porId = new HashMap<>();
        for (Campanha c : campanhas) {
            porId.put(c.getId(), c);
        }
        Map<Integer, Integer> colheitas = new HashMap<>();
        for (Cultivo c : cultivos) {
            colheitas.put(c.getId(), servicos.producao().contarColheitas(c.getId()));
        }
        req.setAttribute("campanhas", campanhas);
        req.setAttribute("campanhasPorId", porId);
        req.setAttribute("campanhaActual", campanhaId == null ? null : porId.get(campanhaId));
        req.setAttribute("cultivos", cultivos);
        req.setAttribute("numColheitas", colheitas);
        vista(req, resp, "admin/cultivos");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer filtro = inteiroOpcional(req, "filtroCampanhaId");
        try {
            String accao = texto(req, "accao");
            if ("criar".equals(accao)) {
                Cultivo c = servicos.producao().registarCultivo(inteiro(req, "campanhaId", "Campanha"),
                        texto(req, "cultura"), texto(req, "variedade"), decimal(req, "hectares", "Hectares"),
                        data(req, "plantio", "Data de plantio"));
                sucesso(req, "Cultivo «" + c.getCultura() + " — " + c.getVariedade() + "» registado.");
            } else if ("remover".equals(accao)) {
                servicos.producao().removerCultivo(inteiro(req, "id", "Cultivo"));
                sucesso(req, "Cultivo removido.");
            } else {
                throw new RegraNegocioException("Acção desconhecida.");
            }
            redirect(req, resp, "/admin/cultivos" + (filtro == null ? "" : "?campanhaId=" + filtro));
        } catch (RegraNegocioException e) {
            erro(req, e);
            doGet(req, resp);
        }
    }
}
