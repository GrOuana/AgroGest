<c:set var="titulo" value="Compras detalhadas"/>
<c:set var="menu" value="compras"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<div class="cabecalho-pagina">
  <h1>Compras detalhadas</h1>
  <p class="subtitulo">${fn:length(vendas)} compras · total ${f:mt(totalGeral)}</p>
</div>

<nav class="filtros" aria-label="Ordenar compras">
  <span class="filtros-rotulo">Ordenar por:</span>
  <c:forEach var="o" items="data,valor,cliente,numero">
    <c:set var="rotuloO" value="${o == 'data' ? 'Data' : (o == 'valor' ? 'Valor' : (o == 'cliente' ? 'Cliente' : 'Nº factura'))}"/>
    <a class="filtro ${ordem == o ? 'activo' : ''}"
       href="${ctx}/admin/compras?ordem=${o}&amp;dir=${ordem == o && dir == 'desc' ? 'asc' : 'desc'}">${rotuloO}<c:if test="${ordem == o}"> ${dir == 'asc' ? '▲' : '▼'}</c:if></a>
  </c:forEach>
</nav>

<c:if test="${empty vendas}"><p class="vazio">Ainda não há compras.</p></c:if>

<c:forEach var="v" items="${vendas}">
  <article class="cartao compra">
    <header class="compra-topo">
      <div>
        <h2><c:out value="${v.numeroFactura}"/></h2>
        <span class="compra-data">${f:dataHora(v.data)}</span>
      </div>
      <div class="compra-total">${f:mt(v.total)}</div>
    </header>
    <dl class="dados dados-linha">
      <dt>Cliente</dt><dd><c:out value="${v.clienteNome}"/> · <c:out value="${v.clienteEmail}"/></dd>
      <dt>Endereço</dt><dd><c:out value="${v.clienteEndereco}"/></dd>
      <dt>Telefone</dt><dd><c:out value="${v.clienteTelefone}"/></dd>
    </dl>
    <div class="tabela-envolvente">
      <table class="tabela tabela-compacta">
        <thead><tr><th>Produto</th><th class="num">Quantidade</th><th class="num">Valor unitário</th><th class="num">Subtotal</th></tr></thead>
        <tbody>
          <c:forEach var="i" items="${v.itens}">
            <tr>
              <td><c:out value="${i.produtoNome}"/></td>
              <td class="num">${i.quantidade} <c:out value="${i.unidade}"/></td>
              <td class="num">${f:mt(i.precoUnit)}</td>
              <td class="num">${f:mt(i.subtotal)}</td>
            </tr>
          </c:forEach>
        </tbody>
        <tfoot>
          <tr><th colspan="3" class="num">Subtotal</th><td class="num">${f:mt(v.subtotal)}</td></tr>
          <tr><th colspan="3" class="num">IVA (16%)</th><td class="num">${f:mt(v.iva)}</td></tr>
          <tr class="linha-total"><th colspan="3" class="num">Total</th><td class="num">${f:mt(v.total)}</td></tr>
        </tfoot>
      </table>
    </div>
    <p class="accoes"><a class="botao botao-pequeno botao-secundario" href="${ctx}/factura?id=${v.id}">Ver factura</a></p>
  </article>
</c:forEach>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
