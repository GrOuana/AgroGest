# Contrato: modelo de domínio, DataStore e serviços

Esta é a referência para programar contra o núcleo: campos dos POJOs, métodos do repositório e dos serviços.

## POJOs (`mz.co.agrogest.model`, todos `Serializable`)

| Classe | Campos |
|---|---|
| `Utilizador` | `int id`, `String nome`, `String email` (único), `String passHash`, `Perfil perfil` (ADMIN/CLIENTE), `boolean ativo`, `String telefone`, `String endereco`, `LocalDate dataRegisto` |
| `Fornecedor` | `int id`, `String nome`, `TipoFornecedor tipo` (SEMENTES/MAQUINARIA/FERTILIZANTES), `String contacto`, `String provincia` |
| `Produto` | `int id`, `String nome`, `Categoria categoria` (SEMENTE/FERTILIZANTE/MAQUINARIA/FERRAMENTA), `int fornecedorId`, `String fornecedorNome`, `BigDecimal preco`, `int quantidade` (stock), `String unidade`, `String descricao`, `String fotoUrl`, `LocalDate validade` (opcional) · derivados: `isEmStock()`, `isExpirado()`, `getValorEmStock()` |
| `Campanha` | `int id`, `String nome`, `LocalDate inicio`, `LocalDate fim`, `boolean fechada` · `contem(LocalDate)` |
| `Cultivo` | `int id`, `int campanhaId`, `String cultura`, `String variedade`, `BigDecimal hectares`, `LocalDate plantio` |
| `Colheita` | `int id`, `int cultivoId`, `LocalDate data`, `BigDecimal kg`, `BigDecimal precoKg`, `BigDecimal valorTotal` (calculado: kg × precoKg) |
| `Venda` | `int id`, `String numeroFactura` (FT-ano-N), `int clienteId`, cópia de `clienteNome/Email/Telefone/Endereco`, `LocalDateTime data`, `List<VendaItem> itens`, `BigDecimal subtotal`, `iva`, `total` |
| `VendaItem` | `int produtoId`, `String produtoNome`, `String unidade`, `int quantidade`, `BigDecimal precoUnit`, `BigDecimal subtotal` |
| `Carrinho` (sessão) | `Map<Integer produtoId, Integer quantidade>`; métodos `synchronized` |

Objectos de vista (não persistidos): `LinhaCarrinho`, `ResumoCarrinho`, `ResumoCliente`, `Painel`.

## `repo.DataStore`

Listas `Collections.synchronizedList`, um `AtomicInteger` por entidade e um contador de facturas por ano. As listagens devolvem **cópias**.

| Entidade | Métodos |
|---|---|
| Utilizadores | `listarUtilizadores()`, `listarClientes()`, `procurarUtilizador(id)`, `procurarUtilizadorPorEmail(email)`, `adicionarUtilizadorSeEmailLivre(u) → boolean` |
| Fornecedores | `listarFornecedores()`, `procurarFornecedor(id)`, `adicionarFornecedor(f)`, `removerFornecedor(id)` |
| Produtos | `listarProdutos()`, `procurarProduto(id)`, `adicionarProduto(p)`, `removerProduto(id)`, `existeProdutoDoFornecedor(fid)` |
| Campanhas | `listarCampanhas()`, `procurarCampanha(id)`, `adicionarCampanha(c)`, `removerCampanha(id)` |
| Cultivos | `listarCultivos()`, `listarCultivosDaCampanha(cid)`, `procurarCultivo(id)`, `adicionarCultivo(c)`, `removerCultivo(id)` |
| Colheitas | `listarColheitas()`, `listarColheitasDoCultivo(cid)`, `adicionarColheita(c)`, `removerColheita(id)` |
| Vendas | `listarVendas()`, `listarVendasDoCliente(cid)`, `procurarVenda(id)`, `adicionarVenda(v)`, `proximoNumeroFactura(ano)` |
| Locks | `lockUtilizadores()`, `lockProdutos()`, `lockCultivos()`, `lockColheitas()` |
| Persistência | `exportar() → byte[]`, `importar(byte[])`, `limpar()` |

Os métodos `adicionar…` atribuem o ID com `AtomicInteger.getAndIncrement()`.

## Serviços (`mz.co.agrogest.service`)

Todos lançam `RegraNegocioException` (mensagem para o utilizador) quando uma regra falha. Estão agrupados em `Servicos`, guardado no `ServletContext` pelo `AppListener`.

| Serviço | Métodos principais |
|---|---|
| `AuthService` | `garantirAdmin()`, `autenticar(email, pass)`, `registarCliente(nome, email, pass, confirmacao, telefone, endereco)`, `alternarAtivo(clienteId)`, `validarSessao(id)` |
| `CatalogoService` | `listarFornecedores()`, `criarFornecedor(…)`, `removerFornecedor(id)`, `listarProdutos()`, `catalogo(categoria)`, `procurarProduto(id)`, `criarProduto(…)`, `actualizarProduto(id, …)`, `reporStock(id, qtd)`, `removerProduto(id)` |
| `ProducaoService` | `listarCampanhas()`, `criarCampanha(nome, inicio, fim)`, `fecharCampanha(id)`, `reabrirCampanha(id)`, `removerCampanha(id)`, `listarCultivos(campanhaId?)`, `registarCultivo(…)`, `removerCultivo(id)`, `listarColheitas(cultivoId?)`, `registarColheita(cultivoId, data, kg, precoKg)`, `removerColheita(id)` |
| `CarrinhoService` | `adicionar(carrinho, produtoId, qtd)`, `actualizar(…)`, `remover(…)`, `esvaziar(…)`, `resumo(carrinho) → ResumoCarrinho` |
| `VendaService` | `finalizarCompra(clienteId, itens) → Venda` (atómico, lança `StockInsuficienteException`), `procurar(id)`, `podeVer(utilizador, venda)`, `historicoDoCliente(id)` |
| `RelatorioService` | `painel()`, `produtos/armazem/fornecedores/clientes/compras(ordem, desc)`, `clientesPorNome()`, `clientesPorVolume()`, `clientesMaisAssiduos()`, `clientesSemCompras()` |
| `PersistenciaService` | `gravar()`, `gravarSemFalhar()`, `carregar() → boolean`, `eliminar()`, mais getters de estado |
| `DadosDemo` | `carregar()` — dados de demonstração do enunciado |
