package mz.co.agrogest.service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;

import mz.co.agrogest.model.Campanha;
import mz.co.agrogest.model.Colheita;
import mz.co.agrogest.model.Cultivo;
import mz.co.agrogest.repo.DataStore;
import mz.co.agrogest.util.Dinheiro;
import mz.co.agrogest.util.Formatos;

/**
 * Caderno de campo: campanhas, cultivos e colheitas.
 * Ordem de locks: colheitas → cultivos → campanhas.
 */
public class ProducaoService {

    private final DataStore store;

    public ProducaoService(DataStore store) {
        this.store = store;
    }

    // ------------------------------------------------------------- campanhas

    public List<Campanha> listarCampanhas() {
        List<Campanha> lista = store.listarCampanhas();
        lista.sort(Comparator.comparing(Campanha::getInicio).reversed());
        return lista;
    }

    public Optional<Campanha> procurarCampanha(int id) {
        return store.procurarCampanha(id);
    }

    public Campanha criarCampanha(String nome, LocalDate inicio, LocalDate fim) {
        String n = Validar.obrigatorio(nome, "Nome");
        Validar.presente(inicio, "Data de início");
        Validar.presente(fim, "Data de fim");
        if (fim.isBefore(inicio)) {
            throw new RegraNegocioException("A data de fim não pode ser anterior à data de início.");
        }
        return store.adicionarCampanha(new Campanha(n, inicio, fim));
    }

    public Campanha fecharCampanha(int id) {
        Campanha c = campanhaExistente(id);
        c.setFechada(true);
        return c;
    }

    public Campanha reabrirCampanha(int id) {
        Campanha c = campanhaExistente(id);
        c.setFechada(false);
        return c;
    }

    public void removerCampanha(int id) {
        synchronized (store.lockCultivos()) {
            Campanha c = campanhaExistente(id);
            int n = store.listarCultivosDaCampanha(id).size();
            if (n > 0) {
                throw new RegraNegocioException("Não é possível remover «" + c.getNome() + "»: tem " + n
                        + (n == 1 ? " cultivo associado." : " cultivos associados."));
            }
            store.removerCampanha(id);
        }
    }

    public int contarCultivos(int campanhaId) {
        return store.listarCultivosDaCampanha(campanhaId).size();
    }

    // -------------------------------------------------------------- cultivos

    public List<Cultivo> listarCultivos(Integer campanhaId) {
        List<Cultivo> lista = campanhaId == null ? store.listarCultivos() : store.listarCultivosDaCampanha(campanhaId);
        lista.sort(Comparator.comparing(Cultivo::getPlantio).reversed());
        return lista;
    }

    public Optional<Cultivo> procurarCultivo(int id) {
        return store.procurarCultivo(id);
    }

    public Cultivo registarCultivo(int campanhaId, String cultura, String variedade, BigDecimal hectares,
                                   LocalDate plantio) {
        String c = Validar.obrigatorio(cultura, "Cultura");
        String v = Validar.obrigatorio(variedade, "Variedade");
        Validar.positivo(hectares, "Hectares");
        Validar.presente(plantio, "Data de plantio");
        synchronized (store.lockCultivos()) {
            Campanha campanha = campanhaExistente(campanhaId);
            if (campanha.isFechada()) {
                throw new RegraNegocioException("A campanha «" + campanha.getNome()
                        + "» está fechada. Reabra-a para registar cultivos.");
            }
            if (!campanha.contem(plantio)) {
                throw new RegraNegocioException("A data de plantio tem de estar dentro do período da campanha.");
            }
            return store.adicionarCultivo(new Cultivo(campanhaId, c, v, hectares, plantio));
        }
    }

    public void removerCultivo(int id) {
        synchronized (store.lockColheitas()) {
            Cultivo c = cultivoExistente(id);
            int n = store.listarColheitasDoCultivo(id).size();
            if (n > 0) {
                throw new RegraNegocioException("Não é possível remover o cultivo «" + c.getCultura() + "»: tem " + n
                        + (n == 1 ? " colheita associada." : " colheitas associadas."));
            }
            store.removerCultivo(id);
        }
    }

    public int contarColheitas(int cultivoId) {
        return store.listarColheitasDoCultivo(cultivoId).size();
    }

    // ------------------------------------------------------------- colheitas

    public List<Colheita> listarColheitas(Integer cultivoId) {
        List<Colheita> lista = cultivoId == null ? store.listarColheitas() : store.listarColheitasDoCultivo(cultivoId);
        lista.sort(Comparator.comparing(Colheita::getData).reversed());
        return lista;
    }

    public Colheita registarColheita(int cultivoId, LocalDate data, BigDecimal kg, BigDecimal precoKg) {
        Validar.presente(data, "Data");
        Validar.positivo(kg, "Quantidade (kg)");
        Validar.positivo(precoKg, "Preço por kg");
        synchronized (store.lockColheitas()) {
            Cultivo cultivo = cultivoExistente(cultivoId);
            Campanha campanha = campanhaExistente(cultivo.getCampanhaId());
            if (campanha.isFechada()) {
                throw new RegraNegocioException("A campanha «" + campanha.getNome()
                        + "» está fechada. Reabra-a para registar colheitas.");
            }
            if (data.isBefore(cultivo.getPlantio())) {
                throw new RegraNegocioException("A colheita não pode ser anterior à data de plantio ("
                        + Formatos.data(cultivo.getPlantio()) + ").");
            }
            Colheita c = new Colheita();
            c.setCultivoId(cultivoId);
            c.setData(data);
            c.setKg(kg);
            c.setPrecoKg(Dinheiro.arredondar(precoKg));
            // O sistema calcula o valor total: kg × preço por kg
            c.setValorTotal(Dinheiro.multiplicar(c.getPrecoKg(), kg));
            return store.adicionarColheita(c);
        }
    }

    public void removerColheita(int id) {
        if (!store.removerColheita(id)) {
            throw new RegraNegocioException("Colheita não encontrada.");
        }
    }

    /** Valor total das colheitas de um cultivo. */
    public BigDecimal valorColhido(int cultivoId) {
        BigDecimal soma = BigDecimal.ZERO;
        for (Colheita c : store.listarColheitasDoCultivo(cultivoId)) {
            soma = soma.add(c.getValorTotal());
        }
        return soma;
    }

    // ------------------------------------------------------------- auxiliares

    private Campanha campanhaExistente(int id) {
        return store.procurarCampanha(id)
                .orElseThrow(() -> new RegraNegocioException("Campanha não encontrada."));
    }

    private Cultivo cultivoExistente(int id) {
        return store.procurarCultivo(id)
                .orElseThrow(() -> new RegraNegocioException("Cultivo não encontrado."));
    }
}
