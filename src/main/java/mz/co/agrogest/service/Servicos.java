package mz.co.agrogest.service;

import mz.co.agrogest.repo.DataStore;

/**
 * Agrupa os serviços da aplicação. Criado uma vez pelo AppListener e guardado
 * no ServletContext; os servlets obtêm-no no init().
 */
public class Servicos {

    public static final String ATRIBUTO = "agrogest.servicos";

    private final DataStore store;
    private final AuthService auth;
    private final CatalogoService catalogo;
    private final ProducaoService producao;
    private final CarrinhoService carrinho;
    private final VendaService venda;
    private final RelatorioService relatorio;
    private final PersistenciaService persistencia;

    public Servicos(DataStore store, PersistenciaService persistencia) {
        this.store = store;
        this.persistencia = persistencia;
        this.auth = new AuthService(store);
        this.catalogo = new CatalogoService(store);
        this.producao = new ProducaoService(store);
        this.carrinho = new CarrinhoService(store);
        this.venda = new VendaService(store);
        this.relatorio = new RelatorioService(store);
    }

    /** Apaga tudo da memória e volta aos dados de demonstração. */
    public void reporDadosDemonstracao() {
        store.limpar();
        auth.garantirAdmin();
        new DadosDemo(this).carregar();
    }

    public AuthService auth() { return auth; }
    public CatalogoService catalogo() { return catalogo; }
    public ProducaoService producao() { return producao; }
    public CarrinhoService carrinho() { return carrinho; }
    public VendaService venda() { return venda; }
    public RelatorioService relatorio() { return relatorio; }
    public PersistenciaService persistencia() { return persistencia; }
}
