# Casos de teste

Os casos marcados com ✔ são verificados automaticamente por `bash scripts/testar.sh`. A última execução, a 24/10/2026, deu **56 OK, 0 falhas**.

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

## Persistência e falhas

| Caso | Resultado esperado | Verificado |
|---|---|---|
| Reiniciar o Tomcat com paragem limpa | Log "estado gravado ao encerrar" e depois "Dados repostos de dados.ser"; contagens iguais | ✔ 24/10 |
| `dados.ser` corrompido | Arranca com "dados repostos da cópia dados.ser.bak"; o ficheiro mau fica como `dados.ser.corrompido-…` | ✔ 24/10 |
| Sem ficheiro de dados | Carrega os dados de demonstração | ✔ 24/10 |
| Persistência → Gravar agora | Ficheiro actualizado (tamanho e data visíveis no ecrã) | ✔ |
| Persistência → Repor dados de demonstração | Painel volta a 3 fornecedores, 3 produtos, 5 clientes, 4 vendas, 1 campanha | ✔ |
