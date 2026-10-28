# Rotas do AgroGest

Todas as rotas são relativas a `/agrogest`. As JSP ficam em `WEB-INF/jsp/` e só são alcançadas por `forward` do servlet. Os POST com sucesso respondem com redirect (Post/Redirect/Get).

Perfis: **público** = sem sessão · **sessão** = qualquer utilizador autenticado (RN05) · **cliente** = só clientes (o admin recebe 403) · **admin** = só administrador (RN04, os outros recebem 403).

## Públicas e cliente

| URL | Método | Servlet | JSP | Perfil | Atributos no request |
|---|---|---|---|---|---|
| `/` | GET | `HomeServlet` | — (redirect para login, painel ou catálogo) | público | — |
| `/login` | GET, POST | `LoginServlet` | `login.jsp` | público | `erro` |
| `/logout` | POST (GET também) | `LogoutServlet` | — (redirect para `/login`) | público | — |
| `/registo` | GET, POST | `RegistoServlet` | `registo-cliente.jsp` | público | `erro`, `erroCampo` |
| `/tema` | POST `modo=claro\|escuro\|sistema`, `voltar` | `TemaServlet` | — (grava o cookie `agrogest_tema` e volta a `voltar`, se for um caminho interno) | público | — |
| `/creditos` | GET | `CreditosServlet` | `creditos.jsp` | público | — |
| `/catalogo?categoria=SEMENTE` | GET | `CatalogoServlet` | `cliente/catalogo.jsp` | sessão | `produtos`, `categorias`, `categoriaActual`, `noCarrinho` |
| `/carrinho` | GET | `CarrinhoServlet` | `cliente/carrinho.jsp` | cliente | `resumo` (`ResumoCarrinho`) |
| `/carrinho/adicionar` | POST `produtoId`, `quantidade`, `categoria` | `CarrinhoServlet` | — (redirect para o catálogo) | cliente | — |
| `/carrinho/actualizar` | POST `produtoId`, `quantidade` | `CarrinhoServlet` | — (redirect para `/carrinho`) | cliente | — |
| `/carrinho/remover` | POST `produtoId` | `CarrinhoServlet` | — | cliente | — |
| `/carrinho/esvaziar` | POST | `CarrinhoServlet` | — | cliente | — |
| `/compra` | GET | `CompraServlet` | `cliente/compra.jsp` | cliente | `resumo`, `cliente` |
| `/compra` | POST | `CompraServlet` | — (redirect para `/factura?id=`) | cliente | — |
| `/factura?id=N` | GET | `FacturaServlet` | `cliente/factura.jsp` | sessão (RN03: dono ou admin, senão 403) | `venda` |
| `/factura?id=N&imprimir=1` | GET | `FacturaServlet` | `cliente/factura-imprimir.jsp` | idem | `venda` |
| `/minhas-compras` | GET | `MinhasComprasServlet` | `cliente/minhas-compras.jsp` | cliente | `vendas` |

## Administrador (`/admin/*`, filtro `AdminFilter`)

| URL | Método | Servlet | JSP | Acções POST (`accao=`) |
|---|---|---|---|---|
| `/admin`, `/admin/dashboard` | GET | `DashboardServlet` | `admin/dashboard.jsp` | — |
| `/admin/fornecedores` | GET, POST | `FornecedoresServlet` | `admin/fornecedores.jsp` | `criar`, `remover` |
| `/admin/produtos` (`?editar=ID`) | GET, POST | `ProdutosServlet` | `admin/produtos.jsp` | `criar`, `actualizar`, `repor`, `remover` |
| `/admin/campanhas` | GET, POST | `CampanhasServlet` | `admin/campanhas.jsp` | `criar`, `fechar`, `reabrir`, `remover` |
| `/admin/cultivos` (`?campanhaId=ID`) | GET, POST | `CultivosServlet` | `admin/cultivos.jsp` | `criar`, `remover` |
| `/admin/colheitas` (`?cultivoId=ID`) | GET, POST | `ColheitasServlet` | `admin/colheitas.jsp` | `criar`, `remover` |
| `/admin/listagens?tipo=…&ordem=…&dir=asc\|desc` | GET | `ListagensServlet` | `admin/listagens.jsp` | — |
| `/admin/compras?ordem=data\|valor\|cliente\|numero&dir=…` | GET | `ComprasServlet` | `admin/compras.jsp` | — |
| `/admin/clientes` | POST `id` | `ClientesServlet` | — (redirect para a listagem de clientes) | activar / desactivar conta |
| `/admin/relatorios` | GET | `RelatoriosServlet` | `admin/relatorios.jsp` | — |
| `/admin/persistencia` | GET, POST | `PersistenciaServlet` | `admin/persistencia.jsp` | `gravar`, `eliminar`, `repor` |

### Ordenações das listagens

| `tipo` | valores de `ordem` |
|---|---|
| `produtos` | `nome`, `fornecedor`, `preco`, `stock`, `validade` |
| `armazem` (stock > 0) | `nome`, `fornecedor`, `preco`, `stock`, `valor` |
| `fornecedores` | `nome`, `tipo`, `provincia` |
| `clientes` | `nome`, `data` (registo), `compras`, `valor` (volume) |

## Erros

| Código | Página |
|---|---|
| 403 | `erro/403.jsp` — sem permissão (sem sessão em `/admin/*`, cliente em `/admin/*`, admin no carrinho, factura de outro cliente) |
| 404 | `erro/404.jsp` |
| 500 / excepção | `erro/500.jsp` (o detalhe fica no log do Tomcat) |

## Atributos de pedido comuns

| Nome | Tipo | Significado |
|---|---|---|
| `erro` | `String` | Mensagem de validação ou regra de negócio, mostrada no topo da página |
| `erroCampo` | `String` | Nome do campo que falhou (ex.: `telefone`). A JSP marca-o com `aria-invalid` e mostra a mensagem junto dele |

## Cookie

| Nome | Valores | Uso |
|---|---|---|
| `agrogest_tema` | `claro`, `escuro` (sem cookie = seguir o sistema) | Lido pelo `prelude.jspf`, que põe `data-theme="light\|dark\|auto"` no `<html>`. Dura 1 ano; HttpOnly; SameSite=Lax. Valores desconhecidos são ignorados |

## Atributos de sessão

| Nome | Tipo | Quem escreve |
|---|---|---|
| `utilizador` | `Utilizador` | `LoginServlet`, `RegistoServlet` |
| `carrinho` | `Carrinho` | `BaseServlet.carrinho()` |
| `destinoAposLogin` | `String` | `AuthFilter` (página pedida antes do login) |
| `flash`, `flashErro` | `String` | servlets após POST; mostrados e removidos pelo `cabecalho.jspf` |
