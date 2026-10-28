<c:set var="titulo" value="Relatórios"/>
<c:set var="menu" value="relatorios"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<header class="page__header">
  <div class="page__heading">
    <h1 class="page__title">Relatórios de clientes</h1>
    <p class="page__subtitle">Calculados no servidor a partir das vendas registadas.</p>
  </div>
</header>

<div class="columns columns--2">
  <section class="card" aria-labelledby="rel-nome">
    <header class="card__header"><h2 class="card__title" id="rel-nome">1. Clientes por nome <span class="card__title-meta">(crescente)</span></h2></header>
    <c:choose>
      <c:when test="${empty porNome}"><p class="empty-state">Sem clientes.</p></c:when>
      <c:otherwise>
        <ol class="ranking">
          <c:forEach var="r" items="${porNome}">
            <li class="ranking__item"><span class="ranking__name"><c:out value="${r.cliente.nome}"/></span><span class="ranking__meta"><c:out value="${r.cliente.email}"/></span></li>
          </c:forEach>
        </ol>
      </c:otherwise>
    </c:choose>
  </section>

  <section class="card" aria-labelledby="rel-volume">
    <header class="card__header"><h2 class="card__title" id="rel-volume">2. Clientes que compraram <span class="card__title-meta">(por volume)</span></h2></header>
    <c:choose>
      <c:when test="${empty porVolume}"><p class="empty-state">Ainda nenhum cliente comprou.</p></c:when>
      <c:otherwise>
        <div class="table-wrap">
          <table class="table">
            <thead>
              <tr>
                <th scope="col" class="table__th">#</th>
                <th scope="col" class="table__th">Cliente</th>
                <th scope="col" class="table__th table__th--num">Compras</th>
                <th scope="col" class="table__th table__th--num">Volume</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="r" items="${porVolume}" varStatus="s">
                <tr class="table__row">
                  <td class="table__td">${s.count}</td>
                  <th scope="row" class="table__td"><c:out value="${r.cliente.nome}"/></th>
                  <td class="table__td table__td--num">${r.numeroCompras}</td>
                  <td class="table__td table__td--num"><span class="table__strong">${f:mt(r.volume)}</span></td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </c:otherwise>
    </c:choose>
  </section>

  <section class="card" aria-labelledby="rel-assiduos">
    <header class="card__header"><h2 class="card__title" id="rel-assiduos">3. Clientes mais assíduos <span class="card__title-meta">(nº de compras)</span></h2></header>
    <c:choose>
      <c:when test="${empty assiduos}"><p class="empty-state">Ainda nenhum cliente comprou.</p></c:when>
      <c:otherwise>
        <div class="table-wrap">
          <table class="table">
            <thead>
              <tr>
                <th scope="col" class="table__th">#</th>
                <th scope="col" class="table__th">Cliente</th>
                <th scope="col" class="table__th table__th--num">Compras</th>
                <th scope="col" class="table__th">Última compra</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="r" items="${assiduos}" varStatus="s">
                <tr class="table__row">
                  <td class="table__td">${s.count}</td>
                  <th scope="row" class="table__td"><c:out value="${r.cliente.nome}"/></th>
                  <td class="table__td table__td--num"><span class="table__strong">${r.numeroCompras}</span></td>
                  <td class="table__td table__td--nowrap">${f:dataHora(r.ultimaCompra)}</td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </c:otherwise>
    </c:choose>
  </section>

  <section class="card" aria-labelledby="rel-sem">
    <header class="card__header"><h2 class="card__title" id="rel-sem">4. Clientes sem compras <span class="card__title-meta">(extra)</span></h2></header>
    <c:choose>
      <c:when test="${empty semCompras}"><p class="empty-state">Todos os clientes já compraram.</p></c:when>
      <c:otherwise>
        <ul class="list">
          <c:forEach var="r" items="${semCompras}">
            <li class="list__item"><span class="list__main"><c:out value="${r.cliente.nome}"/></span><span class="list__meta">registado em ${f:data(r.cliente.dataRegisto)}</span></li>
          </c:forEach>
        </ul>
      </c:otherwise>
    </c:choose>
  </section>
</div>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
