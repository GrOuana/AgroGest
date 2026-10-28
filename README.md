# AgroGest — Sistema de Gestão Agrícola

Trabalho prático de **Sistemas Distribuídos** (Engenharia Informática, 2026).

O AgroGest junta numa só aplicação web a **loja** e o **caderno de campo** de um agricultor da província de Nampula:

- o **administrador** gere fornecedores, produtos, campanhas, cultivos e colheitas, vê listagens ordenadas, compras detalhadas e relatórios de clientes, e grava ou repõe o estado em ficheiro;
- o **cliente** regista-se, consulta o catálogo filtrado por categoria, usa um carrinho guardado na sessão, finaliza a compra e recebe uma factura `FT-ano-N` com IVA de 16% que pode imprimir.

É uma aplicação **Jakarta EE**: Servlets como controladores, JSP + JSTL como vista e POJOs como domínio. **Não usa base de dados**: todos os dados vivem em listas em memória partilhadas pelas threads do Tomcat e são serializados para ficheiro.

| | |
|---|---|
| Linguagem | Java 17 |
| Servidor | Apache Tomcat 10.1 (porta **8081**) |
| Vista | JSP + JSTL 3.0 + EL + HTML5 semântico + CSS3 próprio (`global.css`, BEM, sem frameworks e sem JavaScript) |
| Controladores | Jakarta Servlets 6.0 (`@WebServlet`) |
| Filtros / listener | `@WebFilter`, `@WebListener` |
| Persistência | `Collections.synchronizedList` + serialização Java (`ObjectOutputStream`) |
| Build | Apache Maven 3.9, empacotamento WAR |
| Operação | `systemd` (Linux / WSL2) |

---

## Índice

1. [Credenciais de teste](#1-credenciais-de-teste)
2. [Instalação e deploy](#2-instalação-e-deploy)
3. [Arquitectura](#3-arquitectura)
4. [Regras de negócio e onde estão no código](#4-regras-de-negócio-e-onde-estão-no-código)
5. [Concorrência e transacção de venda](#5-concorrência-e-transacção-de-venda)
6. [Persistência e tolerância a falhas](#6-persistência-e-tolerância-a-falhas)
7. [Interface e validação](#7-interface-e-validação)
8. [Testes](#8-testes)
9. [Resolução de problemas](#9-resolução-de-problemas)
10. [Documentação adicional](#10-documentação-adicional)

---

## 1. Credenciais de teste

| Perfil | Email | Palavra-passe |
|---|---|---|
| Administrador (conta fixa, criada no arranque) | `admin@agro.mz` | `admin234` |
| Cliente de demonstração | `maria@teste.mz` | `1234` |
| Cliente de demonstração | `carlos@teste.mz` | `1234` |
| Cliente de demonstração | `ana@teste.mz` | `1234` |
| Cliente de demonstração (sem compras) | `pedro@teste.mz` | `1234` |
| Cliente de demonstração (sem compras) | `fatima@teste.mz` | `1234` |

No primeiro arranque, sem ficheiro de dados, o sistema carrega os **dados de demonstração** do enunciado: 3 fornecedores, 3 produtos, 5 clientes, 4 vendas e 1 campanha. As 4 vendas de demonstração são de 2025 (`FT-2025-1` a `FT-2025-4`), por isso a primeira compra feita na demonstração recebe a factura **`FT-2026-1`**, como no exemplo do enunciado.

Para voltar a esse estado na defesa: **Persistência → Repor dados de demonstração**.

As palavras-passe guardam-se só como hash PBKDF2-SHA256 com sal (`util/Hash.java`), nunca em texto.

---

## 2. Instalação e deploy

### 2.1 Requisitos

| Ferramenta | Versão | Verificar |
|---|---|---|
| JDK | 17 (Eclipse Temurin) | `java -version` e `javac -version` |
| Maven | 3.9.x | `mvn -v` (tem de mostrar Java 17) |
| Tomcat | 10.1.x | `http://localhost:8081` |

O passo a passo da instalação do ambiente no Windows está em [`docs/instalacao.md`](docs/instalacao.md).

### 2.2 Compilar o WAR

```bash
mvn clean package
```

O resultado é `target/agrogest.war`. O `finalName` do `pom.xml` fixa este nome, por isso a aplicação responde sempre em `/agrogest`.

### 2.3 Publicar no Tomcat (Windows)

**Opção A — script** (compila, pára o Tomcat, publica e volta a arrancar):

```powershell
.\scripts\publicar.ps1                     # usa $env:CATALINA_HOME ou C:\tomcat
.\scripts\publicar.ps1 -Tomcat C:\dev\apache-tomcat-10.1.60
```

**Opção B — manual:**

```powershell
mvn clean package
copy target\agrogest.war C:\tomcat\webapps\
C:\tomcat\bin\startup.bat
```

**Opção C — Eclipse:** File → Import → Maven → *Existing Maven Projects*, depois botão direito no projecto → Run As → *Run on Server* (Tomcat v10.1, *Use Tomcat installation*, porta 8081).

Abrir **http://localhost:8081/agrogest**.

O Tomcat tem de estar configurado na porta 8081. Em `conf/server.xml`, o `Connector` HTTP deve ter `port="8081"`.

### 2.4 Deploy em Linux com systemd (WSL2 ou servidor Ubuntu)

O enunciado pede que o serviço seja gerido com `systemd`. No Windows isso faz-se com o **WSL2**:

```powershell
# PowerShell de administrador, uma vez
wsl --install -d Ubuntu
```

Dentro do Ubuntu, active o systemd: o ficheiro `/etc/wsl.conf` tem de conter

```ini
[boot]
systemd=true
```

Depois corra `wsl --shutdown` no Windows e volte a abrir o Ubuntu. Já com o repositório e o WAR compilado:

```bash
sudo bash deploy/instalar-linux.sh
```

O script instala o OpenJDK 17 e o Tomcat 10.1 em `/opt/tomcat`, muda a porta para 8081, cria o utilizador de sistema `tomcat`, publica o WAR e instala a unidade [`deploy/tomcat.service`](deploy/tomcat.service).

Comandos de operação (os que se mostram na defesa):

```bash
sudo systemctl status tomcat
sudo systemctl restart tomcat        # grava dados.ser ao parar e repõe ao arrancar
sudo systemctl stop tomcat
journalctl -u tomcat -n 50
```

A unidade usa `Type=forking` com `CATALINA_PID`. Assim o `systemctl stop` pára o Tomcat de forma limpa, o que dispara `AppListener.contextDestroyed` e grava o estado. Um `kill -9` não grava nada, e é por isso que existem a gravação automática de 5 em 5 minutos e o endpoint de gravação manual.

### 2.5 Onde ficam os dados

Por omissão: `${catalina.base}/data/agrogest/dados.ser`, fora de `webapps`, para sobreviver a um novo deploy.

- Windows: `C:\tomcat\data\agrogest\dados.ser`
- Linux (serviço): `/opt/tomcat/data/agrogest/dados.ser`

O local pode ser mudado com `-Dagrogest.dados=/caminho/dados.ser` (em `CATALINA_OPTS`) ou com o `context-param` `agrogest.dados` no `web.xml`.

---

## 3. Arquitectura

```
 Browser (cliente)
      │  HTTP :8081
      ▼
┌──────────────────────────── Apache Tomcat 10.1 ─────────────────────────────┐
│ FILTROS     EncodingFilter (UTF-8) · AuthFilter (sessão) · AdminFilter (403)│
├─────────────────────────────────────────────────────────────────────────────┤
│ SERVLETS    Login · Registo · Catálogo · Carrinho · Compra · Factura ·      │
│ (controlo)  MinhasCompras · admin/* (CRUDs, Listagens, Compras, Relatórios, │
│             Persistência)                                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│ SERVICES    AuthService · CatalogoService · ProducaoService ·               │
│ (regras)    CarrinhoService · VendaService (synchronized, tudo-ou-nada) ·   │
│             RelatorioService · PersistenciaService                          │
├─────────────────────────────────────────────────────────────────────────────┤
│ REPO        DataStore — listas synchronizedList + AtomicInteger para IDs    │
│             Snapshot → dados.ser (ObjectOutputStream, escrita atómica)      │
├─────────────────────────────────────────────────────────────────────────────┤
│ VIEWS       JSP em WEB-INF/jsp (só EL + JSTL) · CSS próprio                 │
└─────────────────────────────────────────────────────────────────────────────┘
  AppListener: no arranque repõe dados.ser ou os dados de demonstração;
               ao encerrar grava; de 5 em 5 minutos grava automaticamente.
```

### Pacotes

```
src/main/java/mz/co/agrogest/
  model/      POJOs Serializable: Utilizador, Fornecedor, Produto, Campanha, Cultivo,
              Colheita, Venda, VendaItem, Carrinho; enums Perfil, TipoFornecedor,
              Categoria; objectos de vista LinhaCarrinho, ResumoCarrinho, ResumoCliente, Painel
  repo/       DataStore (listas em memória), Snapshot (estado serializado)
  service/    regras de negócio — não conhecem HTTP
  servlet/    controladores do cliente + BaseServlet
  servlet/admin/  controladores do administrador
  filter/     EncodingFilter, AuthFilter, AdminFilter, Sessao
  listener/   AppListener (arranque, encerramento, gravação automática)
  util/       Hash (PBKDF2), Dinheiro (BigDecimal, IVA), Formatos (funções EL)
src/main/webapp/
  WEB-INF/web.xml          codificação, sessão, JSP, páginas de erro
  WEB-INF/agrogest.tld     funções EL de formatação (f:mt, f:data…)
  WEB-INF/jsp/             todas as JSP, só alcançáveis por forward
     comum/ admin/ cliente/ erro/
  css/global.css           folha de estilos própria: tokens, modo escuro, BEM, responsiva
  fonts/                   Inter, servida localmente — funciona sem internet
  licencas/                textos das licenças da fonte (OFL) e do ícone (CC-BY)
  img/                     logótipo (Twemoji 🌱) e fotografias reais dos produtos (Wikimedia Commons)
```

### Regras que mantêm o MVC limpo

- **O servlet não guarda dados.** Lê os parâmetros, chama um serviço, põe o resultado no `request` e faz `forward` para a JSP. Depois de um POST com sucesso faz `redirect` (padrão Post/Redirect/Get), para um F5 não repetir a operação.
- **O serviço não conhece HTTP.** Recebe valores Java, valida-os e lança `RegraNegocioException` com uma mensagem em português.
- **A JSP não decide nada.** Só mostra, com EL e JSTL, o que o servlet pôs no `request` ou na `session`. Não há scriptlets (`<% %>`) nem lógica de negócio nas vistas. Os totais, o IVA e a ordenação chegam já calculados.
- **As JSP ficam todas dentro de `WEB-INF/jsp`.** Um URL directo para uma JSP dá 404 e não salta os filtros.
- **O controlo de acesso está nos filtros**, não em `if` espalhados pelos servlets.
- **Não há JavaScript no frontend.** A ordenação, o filtro por categoria e os totais do carrinho são novos pedidos ao servidor. O menu de telemóvel e as confirmações de remoção usam só HTML e CSS (`<input type="checkbox">` e `<details>`), e a factura imprime-se com Ctrl+P a partir da versão de impressão.

### Modelo de domínio

```
Utilizador (id, nome, email, passHash, perfil, ativo, telefone, endereço)
   │ 1
   │ N
Venda (nº factura, data, subtotal, IVA, total) ── 1:N ── VendaItem (produtoId, qtd, preçoUnit, subtotal) ── N:1 ── Produto
                                                                                                         (nome, categoria, preço,
                                                                                                          stock, validade…)
                                                                                                              │ N
                                                                                                              │ 1
                                                                                                         Fornecedor (nome, tipo,
                                                                                                          contacto, província)

Campanha (nome, início, fim, fechada) ── 1:N ── Cultivo (cultura, variedade, hectares, plantio) ── 1:N ── Colheita (data, kg, preçoKg, valorTotal)
```

A `Venda` e o `VendaItem` guardam uma cópia dos dados do cliente e do produto no momento da compra. A factura não muda se o produto for alterado ou removido depois.

A lista completa de URLs está em [`docs/rotas.md`](docs/rotas.md) e os campos e métodos em [`docs/contrato.md`](docs/contrato.md).

---

## 4. Regras de negócio e onde estão no código

| Regra | Onde |
|---|---|
| **RN01** — não vender mais do que o stock; o sistema avisa da indisponibilidade | `VendaService.registarVenda` (fase 1), `StockInsuficienteException`; aviso antecipado em `CarrinhoService` |
| **RN02** — a venda desconta o stock de todos os itens atomicamente (tudo ou nada) | `VendaService.registarVenda`: verificar tudo e depois descontar tudo dentro de `synchronized (store.lockProdutos())` |
| **RN03** — o cliente só vê as suas facturas; o admin vê todas | `VendaService.podeVer`, `FacturaServlet` (403), `MinhasComprasServlet` |
| **RN04** — `/admin/*` exclusivo do administrador (HTTP 403) | `filter/AdminFilter` |
| **RN05** — `/catalogo`, `/carrinho/*`, `/compra`, `/factura`, `/minhas-compras` exigem sessão | `filter/AuthFilter` (sem sessão → login; carrinho e compra só para clientes) |
| **RN06** — IDs sequenciais e únicos por `AtomicInteger` | `repo/DataStore` (um `AtomicInteger` por entidade; reposto em `maxId + 1` ao carregar) |
| Email único no registo (sem distinguir maiúsculas) | `DataStore.adicionarUtilizadorSeEmailLivre` (verificar e inserir sob o mesmo lock) |
| Não remover campanhas com cultivos | `ProducaoService.removerCampanha` |
| Não remover cultivos com colheitas | `ProducaoService.removerCultivo` |
| Valor da colheita calculado pelo sistema (kg × preço/kg) | `ProducaoService.registarColheita` |
| Factura `FT-ano-N`, subtotal, IVA 16% e total | `VendaService`, `DataStore.proximoNumeroFactura`, `util/Dinheiro` |
| Quantidades ≤ 0 recusadas no carrinho e na reposição de stock | `CarrinhoService`, `CatalogoService.reporStock`, `Validar` |
| Telefone moçambicano (9 dígitos, 82–87), nomes só com letras, email válido, preços positivos com 2 casas | `service/Validar` (servidor) + atributos `pattern`/`min`/`step` (browser) — ver [secção 7](#7-interface-e-validação) |
| Nenhuma palavra-passe em texto puro | `util/Hash` (PBKDF2WithHmacSHA256, 65 536 iterações, sal de 16 bytes) |
| Extra: não remover fornecedor com produtos; não registar cultivos/colheitas em campanha fechada; plantio dentro do período da campanha; produto fora da validade não se vende | `CatalogoService`, `ProducaoService`, `CarrinhoService`, `VendaService` |

Todos os valores monetários usam `BigDecimal` com `setScale(2, HALF_UP)`, para o total nunca dar `319,99999`.

---

## 5. Concorrência e transacção de venda

Os dados são partilhados por todas as threads do Tomcat, por isso há concorrência real.

- Cada lista do `DataStore` é uma `Collections.synchronizedList`. Isso protege cada operação isolada (`add`, `removeIf`), mas **não** protege uma sequência "verificar e depois alterar".
- Percorrer uma lista (para listar, filtrar ou ordenar) faz-se sempre dentro de `synchronized (lista)`, a partir de uma cópia. Assim não há `ConcurrentModificationException`, e a ordenação não bloqueia as vendas.
- **A venda** (`VendaService`) corre inteira dentro de `synchronized (store.lockProdutos())`:
  1. verifica todos os itens (o produto existe, a quantidade é positiva, está dentro da validade, há stock suficiente) sem alterar nada;
  2. se algum falha, lança `StockInsuficienteException` e nada é descontado;
  3. se todos passam, desconta todos, gera o número de factura e regista a venda.

  A reposição e a edição de stock pelo administrador usam o mesmo lock. Por isso nenhuma thread altera o stock entre a verificação e o desconto.
- O checkout também segura o lock do carrinho da sessão: um duplo clique em "Confirmar compra" não gera duas vendas.
- Ordem de aquisição de locks (evita deadlocks): `carrinho → produtos → vendas` e `colheitas → cultivos → campanhas`.

**O teste da defesa:** dois separadores com sessões diferentes, o mesmo produto com 1 unidade em stock, e comprar nos dois quase ao mesmo tempo. Só uma compra passa, e a outra recebe o aviso de indisponibilidade. O `scripts/testar.sh` faz isto automaticamente, incluindo 20 compras simultâneas para 10 unidades em stock: são aprovadas exactamente 10 e o stock fica em 0.

---

## 6. Persistência e tolerância a falhas

`PersistenciaService` serializa um `Snapshot` com todas as listas e sequências.

**Escrita atómica:**
1. escreve tudo em `dados.ser.tmp` e força a escrita em disco (`FileDescriptor.sync`);
2. copia a versão anterior para `dados.ser.bak`;
3. troca `dados.ser.tmp` por `dados.ser` com `Files.move(…, ATOMIC_MOVE)`.

Se o processo morrer a meio, o `dados.ser` anterior continua inteiro.

**Leitura tolerante:** se `dados.ser` estiver corrompido, é guardado à parte como `dados.ser.corrompido-<data>` e o arranque usa o `dados.ser.bak`. Sem nenhum dos dois, carrega os dados de demonstração. A aplicação arranca sempre.

**Consistência:** o snapshot é tirado com os locks de produtos e vendas. Nunca se grava uma venda a meio (stock descontado sem a venda registada).

**Sequências:** ao carregar, cada `AtomicInteger` é reposto em `max(valor gravado, maior ID + 1)`, e a numeração das facturas continua. Não há IDs repetidos depois de reiniciar.

**Quando se grava:**
- automaticamente ao encerrar o Tomcat (`contextDestroyed`);
- automaticamente de 5 em 5 minutos;
- manualmente em **Persistência → Gravar agora**.

O mesmo ecrã permite **eliminar o ficheiro** e **repor os dados de demonstração**.

---

## 7. Interface e validação

### Design system (`css/global.css`)

A folha de estilos é escrita de raiz, sem Bootstrap, Tailwind ou qualquer framework, e organiza-se assim:

- **Design tokens no `:root`.** Cores (verde esmeralda `--color-primary` para as acções e neutros para o resto), tipografia (Inter, escala `--text-*`), espaçamento (escala de 4 px), raios, sombras e tempos de transição. Nenhuma cor está escrita directamente num componente.
- **Modo claro, escuro ou automático**, à escolha do utilizador:
  - **Onde está:** um selector ☀ / ☾ / 🖥 na barra superior (cliente) e no fundo da barra lateral (administrador).
  - **Sem JavaScript:** os três botões fazem POST para `/tema` (`TemaServlet`), que guarda a escolha num cookie de um ano (`agrogest_tema`, HttpOnly, SameSite=Lax) e volta à mesma página, mas só se for um caminho interno.
  - **Na página:** a JSP marca `<html data-theme="light|dark|auto">`.
  - **No CSS:** `auto` (por omissão) segue o sistema operativo com `@media (prefers-color-scheme: dark)`, e `light`/`dark` forçam o tema. Só os tokens mudam, os componentes ficam iguais.
- **Imagens reais**, guardadas no WAR, para funcionarem sem internet:
  - fotografias dos produtos do Wikimedia Commons, com licenças livres (CC BY / CC BY-SA);
  - o ícone 🌱 do Twemoji (CC-BY 4.0) no logótipo.

  Autores e licenças: página `/creditos` (ligada no rodapé) e [`docs/creditos-imagens.md`](docs/creditos-imagens.md). A AgroGest é fictícia e não tem logótipo próprio, por isso usa-se um ícone livre e não a marca de outra empresa.
- **BEM** (`bloco__elemento--modificador`) em todas as classes, por exemplo `.product-card__price` e `.btn--primary`. Não há selectores encadeados que dependam da estrutura do HTML.
- **Layouts:**
  - o administrador usa **CSS Grid** (`.app`: barra lateral + conteúdo), que no telemóvel passa a uma faixa de navegação horizontal;
  - o catálogo usa **Flexbox** (`.product-grid`, cartões com `flex: 1 1 15.5rem`).
- **Defensive CSS:**
  - `min-width: 0` nos filhos de grid e flex;
  - `minmax(0, 1fr)` nas grelhas;
  - `overflow-wrap` nos textos vindos dos utilizadores;
  - descrições cortadas em 3 linhas (`line-clamp`);
  - imagens com `aspect-ratio` + `object-fit` e foto de recurso;
  - tabelas com scroll horizontal;
  - `flex-wrap` nos grupos de botões.

  Foi testado com um produto de nome com 60 caracteres sem espaços (`docs/img/45-*.png`, `46-*.png`).
- **Micro-interacções:**
  - transições suaves e `box-shadow` no `:hover` dos botões, cartões e indicadores;
  - anel de foco esmeralda no `:focus` dos campos;
  - animação de entrada dos avisos.

  Tudo é desligado quando o sistema pede `prefers-reduced-motion`.
- **Fonte Inter** incluída no WAR (`fonts/`, licença SIL OFL). A demonstração não depende da internet.

### Acessibilidade

- **Estrutura da página:** HTML semântico (`header`, `nav`, `main`, `aside`, `section`, `article`, `address`, `time`, `dl`), um `h1` por página e títulos sem saltos.
- **Teclado:** ligação "Saltar para o conteúdo" e `:focus-visible` em todos os elementos interactivos.
- **Navegação:** `aria-current="page"` no menu e `aria-sort` nos cabeçalhos ordenáveis.
- **Campos:** todos têm `<label>`. As ajudas ligam-se por `aria-describedby` e os erros marcam o campo com `aria-invalid="true"`. Os avisos usam `role="alert"`/`role="status"`.
- **Tabelas:** `<th scope>`, e texto escondido (`.visually-hidden`) nos botões repetidos, como "Remover «Adubo NPK»".
- **Auditoria automática:** 26 páginas geradas, 0 problemas (labels, `alt`, IDs duplicados, referências ARIA, botões sem texto, hierarquia de títulos).

### Validação em duas camadas

| Campo | No browser (HTML5) | No servidor (`service/Validar`) |
|---|---|---|
| Telefone (cliente e fornecedor) | `type="tel" pattern="^8[2-7]\d{7}$"` + `title` com o formato | `TELEFONE_MZ` (aceita espaços ao escrever, guarda só os 9 dígitos) |
| Nome de cliente | `pattern` só com letras, espaços, `'` e `-` | `NOME_PESSOA` + mínimo de 2 letras |
| Nome de fornecedor, província, cultura | letras e `. , & ' -`, sem números (permite "Sementes do Sul, Lda") | `NOME_ENTIDADE` |
| Email | `type="email"` + `pattern` com domínio | `EMAIL` + unicidade sob lock |
| Preço, preço/kg | `type="number" min="0.01" step="0.01"` | positivo, ≤ 100 milhões, no máximo 2 casas decimais |
| Quantidades, stock | `type="number" min="0\|1" step="1"` | inteiro, ≥ 0 ou > 0, ≤ 1 000 000 |
| Unidade | `pattern` só letras | `UNIDADE` |
| Foto | `pattern` `https://…` ou `img/…` | idem (recusa `javascript:`) |
| Validade | `type="date"` | não pode estar no passado (ao criar) |

A validação do browser dá resposta imediata (`:user-invalid` pinta o campo de vermelho depois de o utilizador lhe mexer). A do servidor é a que garante a integridade dos dados, porque a do browser pode ser contornada.

Quando o servidor recusa, `BaseServlet.erro(req, e)` faz duas coisas:
- põe `request.setAttribute("erro", …)` com a mensagem;
- põe `request.setAttribute("erroCampo", …)` com o nome do campo.

A JSP assinala então esse campo com `form__input--invalid` e `aria-invalid="true"`, e mostra a mensagem junto dele (`comum/erro-campo.jspf`). O formulário volta preenchido com o que foi escrito, sempre escapado contra XSS.

---

## 8. Testes

Com a aplicação acabada de arrancar, ou depois de **Repor dados de demonstração**:

```bash
bash scripts/testar.sh
```

São 80 verificações automáticas com `curl`:
- controlo de acesso (403 e redirecionamento para o login);
- percurso completo do administrador e do cliente do enunciado;
- validações no servidor: telefone, nome com números, email, preço com 3 casas ou com letras, unidade, URL `javascript:`, validade no passado;
- escape de XSS;
- selector de tema: cookie, `data-theme`, regresso à página e recusa de redirecionamentos para fora do site;
- imagens e página de créditos públicas;
- RN01–RN06;
- atomicidade (o primeiro item não é descontado quando o segundo falha);
- concorrência (2 e 20 compras em simultâneo).

Os casos de teste estão descritos em [`docs/testes.md`](docs/testes.md).

Teste manual de persistência: fazer uma compra → reiniciar o Tomcat (`shutdown.bat` + `startup.bat`, ou `systemctl restart tomcat`) → os dados continuam e a próxima factura segue a numeração.

---

## 9. Resolução de problemas

| Sintoma | Causa e solução |
|---|---|
| A janela do `startup.bat` abre e fecha | `JAVA_HOME` não aponta para o JDK 17. Ver `logs\catalina.<data>.log`. |
| 404 em `/agrogest` | O WAR não está em `webapps`, ou o Tomcat ainda está a fazer o deploy. Ver `logs\catalina.<data>.log`. |
| Alterações não aparecem | Apagar `webapps\agrogest` e `work\Catalina\localhost\agrogest` e voltar a publicar (o `scripts\publicar.ps1` já faz isto). |
| Porta 8081 ocupada | `netstat -ano \| findstr :8081` para ver o processo. |
| Acentos trocados | Os ficheiros do projecto estão em UTF-8; no Eclipse, Window → Preferences → General → Workspace → Text file encoding = UTF-8. |
| Quero começar de novo | Persistência → Eliminar ficheiro + Repor dados de demonstração, ou apagar `data\agrogest\` com o Tomcat parado. |

---

## 10. Documentação adicional

| Documento | Conteúdo |
|---|---|
| [`docs/Manual-AgroGest.pdf`](docs/Manual-AgroGest.pdf) | Manual de utilização, passo a passo com capturas, para administrador e cliente |
| [`docs/instalacao.md`](docs/instalacao.md) | Instalação do ambiente no Windows (JDK, Maven, Tomcat, Eclipse, Git) |
| [`docs/contrato.md`](docs/contrato.md) | Campos de cada POJO e métodos do `DataStore` e dos serviços |
| [`docs/rotas.md`](docs/rotas.md) | URL → servlet → JSP → perfil exigido |
| [`docs/convencoes.md`](docs/convencoes.md) | Pacotes, nomes, ramos Git e mensagens de commit |
| [`docs/testes.md`](docs/testes.md) | Casos de teste das regras de negócio e validações |
| [`docs/creditos-imagens.md`](docs/creditos-imagens.md) | Autores e licenças das fotografias, do ícone do logótipo e da fonte |
