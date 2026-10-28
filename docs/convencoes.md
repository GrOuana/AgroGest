# Convenções do projecto

## Código

- **Pacote base:** `mz.co.agrogest`, com os subpacotes `model`, `repo`, `service`, `servlet`, `servlet.admin`, `filter`, `listener` e `util`.
- **Nomes em português**, como no domínio: `Produto`, `reporStock`, `finalizarCompra`.
- **Sufixos:** `…Servlet` (controlador), `…Service` (regras de negócio), `…Filter`, `…Listener`.
- **Servlets** estendem `BaseServlet` e usam `vista()`, `redirect()`, `sucesso()`, `erro()` e os conversores de parâmetros (`inteiro`, `decimal`, `data`, `enumeracao`).
- **Formulários de administração** fazem POST para o próprio URL com `accao=criar|actualizar|remover|…`.
- **Validações e regras** ficam nos serviços e lançam `RegraNegocioException`. O servlet apanha a excepção e mostra a mensagem.
- **Dinheiro** é sempre `BigDecimal` (`util/Dinheiro`), nunca `double`.
- **JSP:** só EL e JSTL, sem scriptlets. Texto vindo do utilizador mostra-se com `<c:out>` ou `fn:escapeXml` (protege contra XSS). Valores formatam-se com as funções `f:` (`f:mt`, `f:data`, `f:dataHora`, `f:numero`).
- **Ficheiros** em UTF-8 e indentação com 4 espaços (Java) ou 2 (JSP, XML, CSS).

## CSS (`src/main/webapp/css/global.css`)

- **BEM:** `bloco__elemento--modificador`, por exemplo `.product-card`, `.product-card__price`, `.btn--primary`.
  - Um modificador aparece sempre junto da classe base: `class="btn btn--primary"`, nunca só `btn--primary`.
  - Não se estiliza por tag nem por encadeamento (`.card table td`). Cada elemento recebe a sua classe (`table__th`, `table__td`).
  - Excepção: os estilos base de elementos (`body`, `a`, `code`, `kbd`) no topo do ficheiro.
- **Design tokens:** cores, tipografia, espaçamento, raios, sombras e tempos vêm sempre de uma variável do `:root` (`var(--color-primary)`, `var(--space-4)`). Uma cor nova é um token novo. O modo escuro só redefine tokens.
- **Defensive CSS:**
  - os filhos de grid e flex levam `min-width: 0`;
  - as grelhas usam `minmax(0, 1fr)`;
  - o texto vindo do utilizador tem `overflow-wrap`;
  - as imagens têm `aspect-ratio` e `object-fit`;
  - as tabelas ficam dentro de `.table-wrap`, com scroll horizontal.
- **Sem JavaScript.**
  - Menu móvel: checkbox + label.
  - Confirmações: `<details class="confirm">`.
  - Impressão: Ctrl+P na versão de impressão.
- **Estados:** `:hover` e `:focus-visible` em tudo o que é clicável. As transições usam os tokens `--duration-*`, e `prefers-reduced-motion` desliga-as.

## Formulários (JSP)

- Cada campo segue esta estrutura: `<div class="form__field">` → `<label class="form__label" for="campo-NOME">` → `<input class="form__input" id="campo-NOME" name="NOME">` → `<p class="form__hint" id="ajuda-NOME">` → `<%@ include file="/WEB-INF/jsp/comum/erro-campo.jspf" %>`.
- Validação HTML5 (`required`, `type`, `pattern`, `min`, `max`, `step`, `maxlength`) **e** a mesma regra no servidor (`service/Validar`). Os padrões partilhados estão definidos uma vez em `Validar` (`TELEFONE_MZ`, `NOME_PESSOA`, `NOME_ENTIDADE`, `UNIDADE`, `EMAIL`).
- No atributo `pattern`, `-` e `/` dentro de `[...]` escrevem-se `\-` e `\/`, porque os browsers compilam o padrão com a flag `v`.
- Os erros do servidor levam o nome do campo: `new RegraNegocioException(mensagem, "telefone")`. O servlet chama `erro(req, e)`, e a JSP marca o campo com `form__input--invalid` e `aria-invalid="true"`.
- Os valores devolvidos ao formulário são sempre escapados: `value="${fn:escapeXml(param.nome)}"`.
- **Imports** com `jakarta.servlet.*`, nunca `javax.servlet.*`.

## Git

- **Ramo principal:** `main`. Deve compilar sempre (`mvn clean package`).
- **Ramos de trabalho:** `feat/<area>` (por exemplo `feat/admin-produtos`, `feat/loja-carrinho`), `fix/<problema>` e `docs/<tema>`.
- **Merge para `main`** pelo menos de dois em dois dias. Quem não escreveu o código revê-o antes.
- **Mensagens de commit** no imperativo, em português, com uma primeira linha curta:
  ```
  Adiciona reposição de stock aos produtos

  Valida quantidade positiva e usa o lock de produtos do DataStore.
  ```
- **Nunca entram no Git:** `target/`, `*.war`, `dados.ser*` e os ficheiros do Eclipse (`.project`, `.classpath`, `.settings/`). Ver o `.gitignore`.
- **Fins de linha:** `core.autocrlf=true` no Windows. O `.gitattributes` força LF nos `*.sh` e `*.service`.
