# Casos de teste

Os casos marcados com ✔ são verificados automaticamente por `bash scripts/testar.sh`. A última execução, a 28/10/2026, deu **80 OK, 0 falhas**.

Para testar à mão: arrancar com os dados de demonstração (ou **Persistência → Repor dados de demonstração**) e usar `admin@agro.mz / admin234` e os clientes `…@teste.mz / 1234`.

## Regras de negócio

| # | Caso | Passos | Resultado esperado | Auto |
|---|---|---|---|---|
| RN01 | Comprar mais do que o stock | Cliente põe 5000 sacos de Adubo no carrinho | "Stock insuficiente para «Adubo NPK 12-24-12»: pediu 5000 saco, disponível 108 saco." e o carrinho não muda | ✔ |
| RN01 | Stock baixa entre o carrinho e a compra | Cliente tem 2 enxadas no carrinho; o admin muda o stock para 1; o cliente confirma | Compra recusada com "produto indisponível … Nenhum stock foi descontado" | ✔ |
| RN02 | Tudo ou nada | No caso anterior, o carrinho também tinha 2 kg de milho | O stock do milho fica igual (o primeiro item não é descontado) | ✔ |
| RN02 | Concorrência, 1 unidade | Dois clientes em sessões diferentes, 1 enxada em stock, confirmam ao mesmo tempo | Só uma factura é emitida; o stock fica 0, nunca negativo | ✔ |
| RN02 | Concorrência, 20 × 10 | 20 clientes compram 1 kg em simultâneo, com 10 kg em stock | Exactamente 10 compras aprovadas; o stock fica 0 | ✔ |
| RN03 | Factura de outro cliente | João abre `/factura?id=1` (factura da Maria) | HTTP 403 | ✔ |
| RN03 | Admin vê todas | Admin abre `/factura?id=1` | 200, factura visível | ✔ |
| RN04 | Anónimo em `/admin/*` | Sem sessão, abrir `/admin/dashboard` e `/admin/produtos` | HTTP 403 | ✔ |
| RN04 | Cliente em `/admin/*` | Cliente autenticado abre `/admin/dashboard` | HTTP 403 | ✔ |
| RN05 | Rotas com sessão | Sem sessão, abrir `/catalogo` e `/minhas-compras` | Redirect para `/login`; depois de entrar, volta à página pedida | ✔ |
| RN05 | Logout | Sair e voltar a abrir `/catalogo` | Redirect para `/login` | ✔ |
| RN06 | IDs após reinício | Gravar, reiniciar o Tomcat, criar um fornecedor e fazer uma compra | IDs continuam a sequência (fornecedor 5, venda 17, FT-2026-13 no ensaio) | manual |

## Validações

| Caso | Resultado esperado | Auto |
|---|---|---|
| Registo com email já existente (mesmo com maiúsculas: `JOAO@teste.mz`) | "Já existe uma conta com o email …" | ✔ |
| Telefone `881234567` (prefixo 88 não existe) | "«Telefone» inválido: 9 dígitos a começar por 82…87"; campo com `aria-invalid="true"` e mensagem junto dele | ✔ |
| Telefone com 7 dígitos | "«Telefone» inválido" | ✔ |
| Telefone escrito com espaços (`84 123 4567`) | Aceite e guardado como `841234567`; mostrado como `+258 84 123 4567` | ✔ |
| Nome de cliente com números (`Ana2 Teste`) | "«Nome» inválido: use só letras e espaços, sem números." | ✔ |
| Email sem domínio (`val4@semponto`) | "O email … não é válido" | ✔ |
| Fornecedor com números no nome (`Agro2000`) ou contacto inválido (`123`) | "«Nome» inválido" / "«Telefone» inválido" | ✔ |
| Preço com 3 casas decimais (`10.555`) ou com letras (`abc`) | "aceita no máximo 2 casas decimais" / "tem de ser um número" | ✔ |
| Unidade com números (`5kg`) | "«Unidade» inválido" | ✔ |
| Foto `javascript:alert(1)` | "A foto tem de ser um endereço http(s):// ou um caminho img/…" | ✔ |
| Produto novo com validade no passado | "A «validade» não pode estar no passado." | ✔ |
| XSS: nome `<script>alert(1)</script>` devolvido ao formulário | Aparece escapado (`&lt;script&gt;`), nunca executa | ✔ |
| Validação no browser (HTML5) | Os `pattern` foram compilados com a flag `v`, como no browser, e testados com 25 casos (válidos e inválidos) | ✔ |
| Registo com palavra-passe < 4 caracteres ou confirmação diferente | Mensagem e formulário preenchido de novo | manual |
| Login com palavra-passe errada | "Email ou palavra-passe incorrectos." | ✔ |
| Conta de cliente desactivada pelo admin tenta entrar | "Esta conta está desactivada." | manual |
| Quantidade 0 ou negativa no carrinho | "O campo «Quantidade» tem de ser maior que zero." | ✔ |
| Repor stock com 0 ou negativo | "… tem de ser maior que zero." | ✔ |
| Produto com preço negativo | "O campo «Preço» tem de ser maior que zero." | ✔ |
| Remover fornecedor com produtos | "Não é possível remover … tem produtos associados." | ✔ |
| Campanha com fim antes do início | "A data de fim não pode ser anterior à data de início." | ✔ |
| Remover campanha com cultivos | "Não é possível remover «Campanha 2026/2027»: tem 1 cultivo associado." | ✔ |
| Remover cultivo com colheitas | "Não é possível remover o cultivo …: tem 1 colheita associada." | ✔ |
| Registar cultivo em campanha fechada | "A campanha … está fechada." | ✔ |
| Plantio fora do período da campanha | "A data de plantio tem de estar dentro do período da campanha." | manual |
| Colheita antes do plantio | "A colheita não pode ser anterior à data de plantio." | manual |
| Valor da colheita | 3200 kg × 22 MT = **70.400,00 MT** | ✔ |
| Totais do carrinho e da factura | 3 kg Milho (85) + 1 saco Adubo (1850) → subtotal 2.105,00 · IVA 336,80 · total **2.441,80 MT** | ✔ |
| Número da primeira factura da demonstração | **FT-2026-1** | ✔ |
| Acentos em formulários | "José Maçã" guardado e mostrado correctamente (UTF-8) | ✔ manual |
| JSP por URL directo (`/WEB-INF/jsp/admin/dashboard.jsp`) | 404 | ✔ |

## Interface: tema e imagens

| Caso | Resultado esperado | Auto |
|---|---|---|
| Primeira visita, sem escolha | `<html data-theme="auto">`: segue o tema do sistema operativo | ✔ |
| Clicar ☾ (escuro) numa página | Volta à mesma página, já em `data-theme="dark"`; cookie `agrogest_tema=escuro` HttpOnly; o botão fica activo (`aria-pressed="true"`) | ✔ |
| Clicar ☀ (claro) com o sistema em escuro | `data-theme="light"`: claro, mesmo com o sistema em escuro | ✔ |
| Clicar 🖥 (sistema) | Apaga o cookie; volta a `data-theme="auto"` | ✔ |
| `voltar=https://exemplo.com/…` (tentativa de redirecionamento aberto) | Ignorado: vai para a raiz da aplicação | ✔ |
| Cookie com valor inventado (`<script>`) | Ignorado: `data-theme="auto"` | ✔ |
| Fotografias, logótipo e página `/creditos` | Servidos pela aplicação (funcionam sem internet); `/creditos` lista autores e licenças | ✔ |

## Persistência e falhas

| Caso | Resultado esperado | Verificado |
|---|---|---|
| Reiniciar o Tomcat com paragem limpa | Log "estado gravado ao encerrar" e depois "Dados repostos de dados.ser"; contagens iguais | ✔ 24/10 |
| `dados.ser` corrompido | Arranca com "dados repostos da cópia dados.ser.bak"; o ficheiro mau fica como `dados.ser.corrompido-…` | ✔ 24/10 |
| Sem ficheiro de dados | Carrega os dados de demonstração | ✔ 24/10 |
| Persistência → Gravar agora | Ficheiro actualizado (tamanho e data visíveis no ecrã) | ✔ |
| Persistência → Repor dados de demonstração | Painel volta a 3 fornecedores, 3 produtos, 5 clientes, 4 vendas, 1 campanha | ✔ |
