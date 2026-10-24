package mz.co.agrogest.filter;

import java.util.Optional;

import jakarta.servlet.ServletContext;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import mz.co.agrogest.model.Utilizador;
import mz.co.agrogest.service.Servicos;

/** Nomes dos atributos de sessão e leitura do utilizador autenticado. */
public final class Sessao {

    public static final String UTILIZADOR = "utilizador";
    public static final String CARRINHO = "carrinho";
    public static final String DESTINO = "destinoAposLogin";
    public static final String FLASH = "flash";
    public static final String FLASH_ERRO = "flashErro";

    private Sessao() {
    }

    /**
     * Utilizador da sessão, confirmado no DataStore (pode ter sido desactivado
     * ou apagado ao repor os dados). Usa getSession(false): não cria sessões
     * a visitantes anónimos.
     */
    public static Optional<Utilizador> utilizador(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        if (s == null) {
            return Optional.empty();
        }
        Object u = s.getAttribute(UTILIZADOR);
        if (!(u instanceof Utilizador)) {
            return Optional.empty();
        }
        Servicos servicos = servicos(req.getServletContext());
        Optional<Utilizador> actual = servicos.auth().validarSessao(((Utilizador) u).getId())
                .filter(x -> x.getEmail().equalsIgnoreCase(((Utilizador) u).getEmail()));
        if (actual.isEmpty()) {
            s.removeAttribute(UTILIZADOR);
            return Optional.empty();
        }
        if (actual.get() != u) {
            // Sessão reposta pelo Tomcat após reinício: passar a usar o objecto do DataStore
            s.setAttribute(UTILIZADOR, actual.get());
        }
        return actual;
    }

    public static Servicos servicos(ServletContext ctx) {
        return (Servicos) ctx.getAttribute(Servicos.ATRIBUTO);
    }
}
