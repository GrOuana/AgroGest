<c:set var="titulo" value="Compras detalhadas"/>
<c:set var="menu" value="compras"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<header class="page__header">
  <div class="page__heading">
    <h1 class="page__title">Compras detalhadas</h1>
    <p class="page__subtitle">${fn:length(vendas)} compras · total ${f:mt(totalGeral)}</p>
  </div>
</header>

<nav aria-label="Ordenar compras">
  <ul class="filter-bar">
    <li class="filter-bar__label" aria-hidden="true">Ordenar por:</li>
    <c:forEach var="o" items="data,valor,cliente,numero">
      <c:set var="rotuloO" value="${o == 'data' ? 'Data' : (o == 'valor' ? 'Valor' : (o == 'cliente' ? 'Cliente' : 'Nº factura'))}"/>
      <li>
        <a class="filter-bar__chip ${ordem == o ? 'filter-bar__chip--active' : ''}" ${ordem == o ? 'aria-current="true"' : ''}
           href="${ctx}/admin/compras?ordem=${o}&amp;dir=${ordem == o && dir == 'desc' ? 'asc' : 'desc'}">
          <span class="visually-hidden">Ordenar por </span>${rotuloO}<c:if test="${ordem == o}"><span aria-hidden="true"> ${dir == 'asc' ? '▲' : '▼'}</span><span class="visually-hidden">, ${dir == 'asc' ? 'crescente' : 'decrescente'}</span></c:if>
        </a>
      </li>
    </c:forEach>
  </ul>
</nav>

<c:if test="${empty vendas}">
  <section class="card card--empty"><p class="empty-state">Ainda não há compras.</p></section>
</c:if>

<c:forEach var="v" items="${vendas}">
  <article class="card purchase" aria-labelledby="compra-${v.id}">
    <header class="purchase__header">
      <div>
        <h2 class="purchase__title" id="compra-${v.id}"><c:out value="${v.numeroFactura}"/></h2>
        <time class="purchase__date">${f:dataHora(v.data)}</time>
      </div>
      <p class="purchase__total"><span class="visually-hidden">Total: </span>${f:mt(v.total)}</p>
    </header>
    <dl class="facts purchase__facts">
      <dt class="facts__term">Cliente</dt><dd class="facts__detail"><c:out value="${v.clienteNome}"/> · <c:out value="${v.clienteEmail}"/></dd>
      <dt class="facts__term">Endereço</dt><dd class="facts__detail"><c:out value="${v.clienteEndereco}"/></dd>
      <dt class="facts__term">Telefone</dt><dd class="facts__detail">${fn:escapeXml(f:telefone(v.clienteTelefone))}</dd>
    </dl>
    <div class="table-wrap">
      <table class="table">
        <thead>
          <tr>
            <th scope="col" class="table__th">Produto</th>
            <th scope="col" class="table__th table__th--num">Quantidade</th>
            <th scope="col" class="table__th table__th--num">Valor unitário</th>
            <th scope="col" class="table__th table__th--num">Subtotal</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="i" items="${v.itens}">
            <tr class="table__row">
              <th scope="row" class="table__td"><c:out value="${i.produtoNome}"/></th>
              <td class="table__td table__td--num">${i.quantidade} <c:out value="${i.unidade}"/></td>
              <td class="table__td table__td--num">${f:mt(i.precoUnit)}</td>
              <td class="table__td table__td--num">${f:mt(i.subtotal)}</td>
            </tr>
          </c:forEach>
        </tbody>
        <tfoot>
          <tr class="table__row table__row--foot"><th scope="row" colspan="3" class="table__th table__th--num">Subtotal</th><td class="table__td table__td--num">${f:mt(v.subtotal)}</td></tr>
          <tr class="table__row table__row--foot"><th scope="row" colspan="3" class="table__th table__th--num">IVA (16%)</th><td class="table__td table__td--num">${f:mt(v.iva)}</td></tr>
          <tr class="table__row table__row--foot table__row--total"><th scope="row" colspan="3" class="table__th table__th--num">Total</th><td class="table__td table__td--num">${f:mt(v.total)}</td></tr>
        </tfoot>
      </table>
    </div>
    <div class="card__footer">
      <a class="btn btn--secondary btn--sm" href="${ctx}/factura?id=${v.id}">Ver factura<span class="visually-hidden"> <c:out value="${v.numeroFactura}"/></span></a>
    </div>
  </article>
</c:forEach>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
