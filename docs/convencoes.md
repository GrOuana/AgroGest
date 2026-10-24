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
