package mz.co.agrogest.service;

import java.util.Optional;

import mz.co.agrogest.model.Perfil;
import mz.co.agrogest.model.Utilizador;
import mz.co.agrogest.repo.DataStore;
import mz.co.agrogest.util.Hash;

/** Autenticação, auto-registo de clientes e conta fixa do administrador. */
public class AuthService {

    public static final String ADMIN_EMAIL = "admin@agro.mz";
    public static final String ADMIN_PASSWORD = "admin234";

    private final DataStore store;

    public AuthService(DataStore store) {
        this.store = store;
    }

    /** Cria a conta do administrador se ainda não existir (arranque do sistema). */
    public void garantirAdmin() {
        if (store.procurarUtilizadorPorEmail(ADMIN_EMAIL).isEmpty()) {
            Utilizador admin = new Utilizador("Administrador AgroGest", ADMIN_EMAIL, Hash.gerar(ADMIN_PASSWORD),
                    Perfil.ADMIN, "840000000", "Nampula");
            store.adicionarUtilizadorSeEmailLivre(admin);
        }
    }

    public Utilizador autenticar(String email, String password) {
        if (email == null || email.isBlank() || password == null || password.isEmpty()) {
            throw new RegraNegocioException("Indique o email e a palavra-passe.");
        }
        Optional<Utilizador> u = store.procurarUtilizadorPorEmail(email);
        // Mesma mensagem para email inexistente e palavra-passe errada
        if (u.isEmpty() || !Hash.verificar(password, u.get().getPassHash())) {
            throw new RegraNegocioException("Email ou palavra-passe incorrectos.");
        }
        if (!u.get().isAtivo()) {
            throw new RegraNegocioException("Esta conta está desactivada. Contacte o administrador.");
        }
        return u.get();
    }

    public Utilizador registarCliente(String nome, String email, String password, String confirmacao,
                                      String telefone, String endereco) {
        String n = Validar.nomePessoa(nome, "nome");
        String e = Validar.email(email, "email");
        if (password == null || password.length() < 4 || password.length() > 100) {
            throw new RegraNegocioException("A palavra-passe tem de ter entre 4 e 100 caracteres.", "password");
        }
        if (!password.equals(confirmacao)) {
            throw new RegraNegocioException("A confirmação não coincide com a palavra-passe.", "confirmacao");
        }
        String t = Validar.telefone(telefone, "telefone");
        String end = Validar.obrigatorio(endereco, "Endereço", "endereco");
        if (end.length() < 5) {
            throw new RegraNegocioException("Indique o endereço completo (rua ou bairro e cidade).", "endereco");
        }

        Utilizador u = new Utilizador(n, e, Hash.gerar(password), Perfil.CLIENTE, t, end);
        if (!store.adicionarUtilizadorSeEmailLivre(u)) {
            throw new RegraNegocioException("Já existe uma conta com o email «" + e + "».", "email");
        }
        return u;
    }

    /** Activa ou desactiva um cliente. Um cliente desactivado não consegue entrar. */
    public Utilizador alternarAtivo(int clienteId) {
        Utilizador u = store.procurarUtilizador(clienteId)
                .filter(Utilizador::isCliente)
                .orElseThrow(() -> new RegraNegocioException("Cliente não encontrado."));
        u.setAtivo(!u.isAtivo());
        return u;
    }

    /** Utilizador actual da sessão, se ainda existir e estiver activo. */
    public Optional<Utilizador> validarSessao(int utilizadorId) {
        return store.procurarUtilizador(utilizadorId).filter(Utilizador::isAtivo);
    }
}
