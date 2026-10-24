package mz.co.agrogest.listener;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.logging.Logger;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import mz.co.agrogest.repo.DataStore;
import mz.co.agrogest.service.DadosDemo;
import mz.co.agrogest.service.PersistenciaService;
import mz.co.agrogest.service.Servicos;

/**
 * Arranque e encerramento da aplicação:
 *  - no arranque repõe o estado de dados.ser, ou carrega os dados de demonstração;
 *  - garante a conta do administrador;
 *  - grava automaticamente de 5 em 5 minutos (protege contra um kill -9);
 *  - no encerramento limpo (systemctl stop / shutdown.bat) grava o estado.
 */
@WebListener
public class AppListener implements ServletContextListener {

    private static final Logger LOG = Logger.getLogger(AppListener.class.getName());
    private static final long INTERVALO_GRAVACAO_MIN = 5;

    private ScheduledExecutorService agendador;
    private PersistenciaService persistencia;

    @Override
    public void contextInitialized(ServletContextEvent evento) {
        ServletContext ctx = evento.getServletContext();
        DataStore store = new DataStore();
        persistencia = new PersistenciaService(store, ficheiroDeDados(ctx));
        Servicos servicos = new Servicos(store, persistencia);

        if (!persistencia.carregar()) {
            servicos.auth().garantirAdmin();
            new DadosDemo(servicos).carregar();
        }
        servicos.auth().garantirAdmin();
        ctx.setAttribute(Servicos.ATRIBUTO, servicos);
        LOG.info(() -> "AgroGest: " + persistencia.getEstadoArranque() + " (" + persistencia.getFicheiro() + ")");

        agendador = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "agrogest-gravacao-automatica");
            t.setDaemon(true);
            return t;
        });
        agendador.scheduleAtFixedRate(persistencia::gravarSemFalhar,
                INTERVALO_GRAVACAO_MIN, INTERVALO_GRAVACAO_MIN, TimeUnit.MINUTES);
    }

    @Override
    public void contextDestroyed(ServletContextEvent evento) {
        if (agendador != null) {
            agendador.shutdownNow();
        }
        if (persistencia != null) {
            persistencia.gravarSemFalhar();
            LOG.info("AgroGest: estado gravado ao encerrar.");
        }
    }

    /**
     * Local do ficheiro, por ordem de preferência:
     *  1. propriedade de sistema -Dagrogest.dados=/caminho/dados.ser
     *  2. context-param agrogest.dados no web.xml
     *  3. ${catalina.base}/data/agrogest/dados.ser (fora de webapps: sobrevive a um novo deploy)
     */
    private static Path ficheiroDeDados(ServletContext ctx) {
        String caminho = System.getProperty("agrogest.dados");
        if (caminho == null || caminho.isBlank()) {
            caminho = ctx.getInitParameter("agrogest.dados");
        }
        if (caminho != null && !caminho.isBlank()) {
            return Paths.get(caminho);
        }
        String base = System.getProperty("catalina.base", System.getProperty("user.home"));
        return Paths.get(base, "data", "agrogest", "dados.ser");
    }
}
