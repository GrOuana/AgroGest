#!/bin/bash
# Teste ponta-a-ponta do AgroGest (Git Bash ou Linux, precisa de curl).
# Corre contra uma aplicação acabada de arrancar ou com os dados de demonstração repostos.
# Uso: bash scripts/testar.sh [URL-base]   (por omissão http://localhost:8081/agrogest)
# Os textos com acentos vão já codificados em UTF-8 (%C3%A3…): o Git Bash não os envia em UTF-8.
B=${1:-http://localhost:8081/agrogest}
T=$(mktemp -d)
ok=0; falhas=0
pass() { echo "  OK   $1"; ok=$((ok+1)); }
fail() { echo "  FALHA $1"; falhas=$((falhas+1)); }
chk() { if eval "$2"; then pass "$1"; else fail "$1"; fi; }

code() { curl -s -o /dev/null -w "%{http_code}" "$@"; }
get() { local j=$1; shift; curl -s -b $T/$j -c $T/$j "$@"; }
post() { local j=$1; local url=$2; shift 2; curl -s -o $T/ultima.html -w "%{http_code} %{redirect_url}" -b $T/$j -c $T/$j -X POST "$B$url" "$@"; }
login() { post $1 /login --data-urlencode "email=$2" --data-urlencode "password=$3" >/dev/null; }

echo "== Controlo de acesso"
chk "anónimo /admin/dashboard → 403" '[ "$(code $B/admin/dashboard)" = 403 ]'
chk "anónimo /admin/produtos → 403" '[ "$(code $B/admin/produtos)" = 403 ]'
chk "anónimo /catalogo → redirect login" '[ "$(curl -s -o /dev/null -w "%{redirect_url}" $B/catalogo)" = "$B/login" ]'
chk "anónimo /minhas-compras → redirect login" '[ "$(curl -s -o /dev/null -w "%{redirect_url}" $B/minhas-compras)" = "$B/login" ]'
chk "JSP directa inacessível (404)" '[ "$(code $B/WEB-INF/jsp/admin/dashboard.jsp)" = 404 ]'
chk "CSS público" '[ "$(code $B/css/estilo.css)" = 200 ]'

echo "== Administrador"
r=$(post adm /login --data-urlencode "email=admin@agro.mz" --data-urlencode "password=errada")
chk "password errada recusada" 'grep -q "incorrectos" $T/ultima.html'
r=$(post adm /login --data-urlencode "email=admin@agro.mz" --data-urlencode "password=admin234")
chk "login admin → painel" '[[ "$r" == *"/admin/dashboard" ]]'
get adm $B/admin/dashboard > $T/painel.html
chk "painel: 3 fornecedores" 'grep -q "indicador-valor\">3</span><span>fornecedores" $T/painel.html'
chk "painel: 5 clientes / 4 vendas / 1 campanha" 'grep -q ">5</span><span>clientes" $T/painel.html && grep -q ">4</span><span>vendas" $T/painel.html && grep -q ">1</span><span>campanha<" $T/painel.html'

post adm /admin/fornecedores -d accao=criar --data-urlencode "nome=Sementes do Sul, Lda" -d tipo=SEMENTES --data-urlencode "contacto=+258 84 555 1234" -d provincia=Maputo >/dev/null
get adm $B/admin/fornecedores > $T/f.html
chk "fornecedor Sementes do Sul criado (acentos/vírgula)" 'grep -q "Sementes do Sul, Lda" $T/f.html'

# O novo fornecedor «Sementes do Sul» fica com o id 4 (os de demonstração são 1–3)
VAL=$(date -d "+8 months" +%Y-%m-%d)
post adm /admin/produtos -d accao=criar -d "nome=Semente%20Feij%C3%A3o%20nhemba" -d categoria=SEMENTE -d fornecedorId=4 -d preco=320 -d quantidade=400 -d unidade=kg -d validade=$VAL -d fotoUrl=img/produtos/feijao.svg -d "descricao=Feij%C3%A3o%20nhemba" >/dev/null
get adm $B/admin/produtos > $T/p.html
chk "produto Feijão nhemba criado" 'grep -q "Semente Feijão nhemba" $T/p.html'

r=$(post adm /admin/produtos -d accao=criar -d nome=X -d categoria=SEMENTE -d fornecedorId=4 -d preco=-5 -d quantidade=1 -d unidade=kg)
chk "preço negativo recusado" 'grep -q "maior que zero" $T/ultima.html'
r=$(post adm /admin/produtos -d accao=repor -d id=1 -d quantidade=0)
chk "repor stock com 0 recusado" 'grep -q "maior que zero" $T/ultima.html'
r=$(post adm /admin/produtos -d accao=repor -d id=1 -d quantidade=-3)
chk "repor stock negativo recusado" 'grep -q "maior que zero" $T/ultima.html'
r=$(post adm /admin/fornecedores -d accao=remover -d id=1)
chk "não remove fornecedor com produtos" 'grep -q "tem produtos associados" $T/ultima.html'

post adm /admin/campanhas -d accao=criar --data-urlencode "nome=Campanha 2026/2027" -d inicio=2026-10-01 -d fim=2027-06-30 >/dev/null
r=$(post adm /admin/campanhas -d accao=criar -d nome=Errada -d inicio=2026-10-01 -d fim=2026-01-01)
chk "campanha com fim antes do início recusada" 'grep -q "anterior à data de início" $T/ultima.html'
post adm /admin/cultivos -d accao=criar -d campanhaId=2 -d "cultura=Feij%C3%A3o%20nhemba" -d variedade=Macia -d hectares=8 -d plantio=2026-11-15 >/dev/null
get adm "$B/admin/cultivos?campanhaId=2" > $T/c.html
chk "cultivo Feijão nhemba / Macia / 8 ha" 'grep -q "Macia" $T/c.html && grep -q "8 ha" $T/c.html'
r=$(post adm /admin/cultivos -d accao=criar -d campanhaId=1 -d cultura=X -d variedade=Y -d hectares=1 -d plantio=2026-01-10)
chk "não regista cultivo em campanha fechada" 'grep -q "está fechada" $T/ultima.html'
post adm /admin/colheitas -d accao=criar -d cultivoId=2 -d data=2027-03-20 -d kg=3200 -d precoKg=22 >/dev/null
get adm $B/admin/colheitas > $T/co.html
chk "colheita 3200 kg × 22 = 70.400,00 MT" 'grep -q "70.400,00 MT" $T/co.html'
r=$(post adm /admin/campanhas -d accao=remover -d id=2)
chk "não remove campanha com cultivos" 'grep -q "cultivo associado" $T/ultima.html'
r=$(post adm /admin/cultivos -d accao=remover -d id=2)
chk "não remove cultivo com colheitas" 'grep -q "colheita associada" $T/ultima.html'

for p in "listagens?tipo=produtos&ordem=preco&dir=desc" "listagens?tipo=fornecedores&ordem=provincia" "listagens?tipo=clientes&ordem=valor&dir=desc" "listagens?tipo=armazem&ordem=valor" "compras?ordem=valor&dir=desc" relatorios persistencia; do
  c=$(curl -s -o $T/x.html -w "%{http_code}" -b $T/adm "$B/admin/$p")
  chk "GET /admin/$p → 200 sem excepção" '[ "$c" = 200 ] && ! grep -qiE "exception|erro inesperado" $T/x.html'
done
get adm "$B/admin/listagens?tipo=produtos&ordem=preco&dir=desc" > $T/l.html
chk "listagem ordenada por preço desc: Adubo primeiro" '[ "$(grep -o "<td><strong>[^<]*" $T/l.html | head -1)" = "<td><strong>Adubo NPK 12-24-12" ]'
get adm $B/admin/relatorios > $T/r.html
chk "relatório: Pedro e Fátima sem compras" 'grep -q "Pedro Cossa" $T/r.html && grep -q "Fátima Abdul" $T/r.html'

echo "== Cliente"
r=$(post jo /registo -d "nome=Jo%C3%A3o%20Silva" -d email=joao@teste.mz -d password=1234 -d confirmacao=1234 --data-urlencode "telefone=+258 84 765 4321" --data-urlencode "endereco=Av. Eduardo Mondlane, Nampula")
chk "registo do João → catálogo" '[[ "$r" == *"/catalogo" ]]'
r=$(post dup /registo -d nome=Outro -d email=JOAO@teste.mz -d password=1234 -d confirmacao=1234 -d telefone=1 -d endereco=x)
chk "email repetido recusado (maiúsculas)" 'grep -q "Já existe uma conta" $T/ultima.html'
get jo $B/catalogo > $T/cat.html
chk "catálogo mostra Feijão nhemba e fotos" 'grep -q "Semente Feijão nhemba" $T/cat.html && grep -q "img/produtos/milho.svg" $T/cat.html'
get jo "$B/catalogo?categoria=FERTILIZANTE" > $T/cat2.html
chk "filtro por categoria" 'grep -q "Adubo NPK" $T/cat2.html && ! grep -q "Semente de Milho" $T/cat2.html'
chk "cliente /admin/dashboard → 403" '[ "$(code -b $T/jo $B/admin/dashboard)" = 403 ]'
r=$(post jo /carrinho/adicionar -d produtoId=1 -d quantidade=0)
get jo $B/carrinho > $T/car.html
chk "quantidade 0 no carrinho recusada" 'grep -q "maior que zero" $T/car.html || grep -q "maior que zero" $T/ultima.html'
post jo /carrinho/adicionar -d produtoId=1 -d quantidade=3 >/dev/null
post jo /carrinho/adicionar -d produtoId=2 -d quantidade=1 >/dev/null
r=$(post jo /carrinho/adicionar -d produtoId=2 -d quantidade=99999)
get jo $B/catalogo > $T/cat3.html
chk "mais que o stock no carrinho → aviso" 'grep -q "Stock insuficiente" $T/cat3.html'
post jo /carrinho/actualizar -d produtoId=1 -d quantidade=5 >/dev/null
post jo /carrinho/actualizar -d produtoId=1 -d quantidade=3 >/dev/null
get jo $B/carrinho > $T/car.html
# 3 × 85 + 1 × 1850 = 2105; IVA 336,80; total 2441,80
chk "carrinho: subtotal 2.105,00 / IVA 336,80 / total 2.441,80" 'grep -q "2.105,00 MT" $T/car.html && grep -q "336,80 MT" $T/car.html && grep -q "2.441,80 MT" $T/car.html'
chk "GET /compra (confirmação)" '[ "$(code -b $T/jo $B/compra)" = 200 ]'
r=$(post jo /compra)
FURL=${r#* }
chk "compra → factura" '[[ "$FURL" == *"/factura?id="* ]]'
get jo "$FURL" > $T/fac.html
chk "factura FT-2026-1 com IVA e total" 'grep -q "FT-2026-1<" $T/fac.html && grep -q "2.441,80 MT" $T/fac.html && grep -q "João Silva" $T/fac.html'
get jo "$FURL&imprimir=1" > $T/imp.html
chk "versão de impressão" 'grep -q "Ctrl" $T/imp.html && grep -q "FT-2026-1" $T/imp.html'
chk "carrinho vazio depois da compra" 'get jo $B/carrinho | grep -q "carrinho está vazio"'
get adm "$B/admin/produtos" > $T/p2.html
chk "stock do milho: 350 → 347" 'grep -A6 "Semente de Milho Matuba" $T/p2.html | grep -q ">347<"'
chk "minhas compras lista FT-2026-1" 'get jo $B/minhas-compras | grep -q "FT-2026-1"'
chk "RN03: João não vê factura da Maria (id 1) → 403" '[ "$(code -b $T/jo "$B/factura?id=1")" = 403 ]'
chk "RN03: admin vê qualquer factura" '[ "$(code -b $T/adm "$B/factura?id=1")" = 200 ]'
chk "admin não acede ao carrinho → 403" '[ "$(code -b $T/adm $B/carrinho)" = 403 ]'

echo "== RN02 atomicidade (tudo ou nada)"
login ma maria@teste.mz 1234
post ma /carrinho/adicionar -d produtoId=1 -d quantidade=2 >/dev/null
post ma /carrinho/adicionar -d produtoId=3 -d quantidade=2 >/dev/null
# Admin baixa o stock da enxada para 1 depois de a Maria pôr 2 no carrinho
post adm /admin/produtos -d accao=actualizar -d id=3 -d nome="Enxada de cabo longo" -d categoria=FERRAMENTA -d fornecedorId=3 -d preco=450 -d quantidade=1 -d unidade=unidade >/dev/null
r=$(post ma /compra)
get ma $B/carrinho > $T/ma.html
chk "compra recusada com aviso de indisponibilidade" 'grep -q "Nenhum stock foi descontado" $T/ma.html'
get adm "$B/admin/produtos" > $T/p3.html
chk "milho não foi descontado (continua 347)" 'grep -A6 "Semente de Milho Matuba" $T/p3.html | grep -q ">347<"'

echo "== Concorrência: 2 sessões, 1 unidade em stock"
login c1 carlos@teste.mz 1234
login c2 ana@teste.mz 1234
post c1 /carrinho/adicionar -d produtoId=3 -d quantidade=1 >/dev/null
post c2 /carrinho/adicionar -d produtoId=3 -d quantidade=1 >/dev/null
curl -s -o /dev/null -w "%{redirect_url}\n" -b $T/c1 -X POST $B/compra > $T/r1 &
curl -s -o /dev/null -w "%{redirect_url}\n" -b $T/c2 -X POST $B/compra > $T/r2 &
wait
n=$(cat $T/r1 $T/r2 | grep -c "/factura?id=")
chk "só uma das duas compras passa ($n facturas)" '[ "$n" = 1 ]'
get adm "$B/admin/produtos" > $T/p4.html
chk "stock da enxada fica 0 (nunca negativo)" 'grep -A6 "Enxada de cabo longo" $T/p4.html | grep -q ">0<"'

echo "== Concorrência: 20 compras simultâneas de 1 kg com 10 em stock"
post adm /admin/produtos -d accao=criar -d "nome=Teste%20concorr%C3%AAncia" -d categoria=SEMENTE -d fornecedorId=1 -d preco=10 -d quantidade=10 -d unidade=kg >/dev/null
PID=$(get adm $B/admin/produtos | grep -o 'id="produto-[0-9]*"' | grep -o '[0-9]*' | sort -n | tail -1)
for i in $(seq 1 20); do
  post "k$i" /registo -d nome="Cliente $i" -d email="k$i@teste.mz" -d password=1234 -d confirmacao=1234 -d telefone=1 -d endereco=x >/dev/null
  post "k$i" /carrinho/adicionar -d produtoId=$PID -d quantidade=1 >/dev/null
done
for i in $(seq 1 20); do curl -s -o /dev/null -w "%{redirect_url}\n" -b $T/k$i -X POST $B/compra > $T/rk$i & done
wait
n=$(cat $T/rk* | grep -c "/factura?id=")
chk "exactamente 10 compras aprovadas ($n)" '[ "$n" = 10 ]'
get adm "$B/admin/produtos" > $T/p5.html
chk "stock do produto de teste = 0" 'grep -A6 "Teste concorrência" $T/p5.html | grep -q ">0<"'

echo "== Logout"
post jo /logout >/dev/null
chk "depois do logout /catalogo pede login" '[ "$(curl -s -o /dev/null -w "%{redirect_url}" -b $T/jo $B/catalogo)" = "$B/login" ]'

echo
echo "Resultado: $ok OK, $falhas falhas"
rm -rf $T
