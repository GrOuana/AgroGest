package mz.co.agrogest.servlet.admin;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import mz.co.agrogest.model.Campanha;
import mz.co.agrogest.model.Colheita;
import mz.co.agrogest.model.Cultivo;
import mz.co.agrogest.service.RegraNegocioException;
import mz.co.agrogest.servlet.BaseServlet;
import mz.co.agrogest.util.Formatos;

/** Colheitas por cultivo: /admin/colheitas?cultivoId=1. O valor total é calculado no serviço. */
@WebServlet("/admin/colheitas")
public class ColheitasServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer cultivoId = inteiroOpcional(req, "cultivoId");
        List<Cultivo> cultivos = servicos.producao().listarCultivos(null);
        List<Colheita> colheitas = servicos.producao().listarColheitas(cultivoId);

        Map<Integer, Cultivo> cultivosPorId = new HashMap<>();
        for (Cultivo c : cultivos) {
            cultivosPorId.put(c.getId(), c);
        }
        Map<Integer, Campanha> campanhasPorId = new HashMap<>();
        for (Campanha c : servicos.producao().listarCampanhas()) {
            campanhasPorId.put(c.getId(), c);
        }
        BigDecimal kg = BigDecimal.ZERO;
        BigDecimal valor = BigDecimal.ZERO;
        for (Colheita c : colheitas) {
            kg = kg.add(c.getKg());
            valor = valor.add(c.getValorTotal());
        }
        req.setAttribute("cultivos", cultivos);
        req.setAttribute("cultivosPorId", cultivosPorId);
        req.setAttribute("campanhasPorId", campanhasPorId);
        req.setAttribute("cultivoActual", cultivoId == null ? null : cultivosPorId.get(cultivoId));
        req.setAttribute("colheitas", colheitas);
        req.setAttribute("totalKg", kg);
        req.setAttribute("totalValor", valor);
        vista(req, resp, "admin/colheitas");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer filtro = inteiroOpcional(req, "filtroCultivoId");
        try {
            String accao = texto(req, "accao");
            if ("criar".equals(accao)) {
                Colheita c = servicos.producao().registarColheita(inteiro(req, "cultivoId", "Cultivo"),
                        data(req, "data", "Data"), decimal(req, "kg", "Quantidade (kg)"),
                        decimal(req, "precoKg", "Preço por kg"));
                sucesso(req, "Colheita registada: " + Formatos.numero(c.getKg()) + " kg × "
                        + Formatos.mt(c.getPrecoKg()) + " = " + Formatos.mt(c.getValorTotal()) + ".");
            } else if ("remover".equals(accao)) {
                servicos.producao().removerColheita(inteiro(req, "id", "Colheita"));
                sucesso(req, "Colheita removida.");
            } else {
                throw new RegraNegocioException("Acção desconhecida.");
            }
            redirect(req, resp, "/admin/colheitas" + (filtro == null ? "" : "?cultivoId=" + filtro));
        } catch (RegraNegocioException e) {
            erro(req, e.getMessage());
            doGet(req, resp);
        }
    }
}
