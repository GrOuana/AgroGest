<c:set var="titulo" value="Minhas compras"/>
<c:set var="menu" value="minhas"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<header class="page__header">
  <div class="page__heading">
    <h1 class="page__title">Minhas compras</h1>
    <p class="page__subtitle">Histórico de todas as suas compras e respectivas facturas.</p>
  </div>
</header>

<c:choose>
  <c:when test="${empty vendas}">
    <section class="card card--empty">
      <p class="empty-state">Ainda não fez nenhuma compra.</p>
      <a class="btn btn--primary" href="${ctx}/catalogo">Ver catálogo</a>
    </section>
  </c:when>
  <c:otherwise>
    <section class="card" aria-labelledby="historico-titulo">
      <header class="card__header">
        <h2 class="card__title" id="historico-titulo">Facturas <span class="card__title-meta">(${fn:length(vendas)})</span></h2>
      </header>
      <div class="table-wrap">
        <table class="table">
          <thead>
            <tr>
              <th scope="col" class="table__th">Factura</th>
              <th scope="col" class="table__th">Data</th>
              <th scope="col" class="table__th">Produtos</th>
              <th scope="col" class="table__th table__th--num">Total</th>
              <th scope="col" class="table__th"><span class="visually-hidden">Acções</span></th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="v" items="${vendas}">
              <tr class="table__row">
                <th scope="row" class="table__td table__td--nowrap"><span class="table__strong"><c:out value="${v.numeroFactura}"/></span></th>
                <td class="table__td table__td--nowrap">${f:dataHora(v.data)}</td>
                <td class="table__td">
                  <c:forEach var="i" items="${v.itens}" varStatus="s">
                    <c:out value="${i.produtoNome}"/> (${i.quantidade})<c:if test="${!s.last}">, </c:if>
                  </c:forEach>
                </td>
                <td class="table__td table__td--num">${f:mt(v.total)}</td>
                <td class="table__td table__td--nowrap">
                  <a class="btn btn--secondary btn--sm" href="${ctx}/factura?id=${v.id}">
                    Ver factura<span class="visually-hidden"> <c:out value="${v.numeroFactura}"/></span>
                  </a>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </section>
  </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
