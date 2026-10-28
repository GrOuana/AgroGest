<c:set var="titulo" value="Painel"/>
<c:set var="menu" value="painel"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<header class="page__header">
  <div class="page__heading">
    <h1 class="page__title">Painel</h1>
    <p class="page__subtitle">Resumo do catálogo, clientes, vendas e campanhas.</p>
  </div>
  <div class="page__actions">
    <a class="btn btn--secondary" href="${ctx}/admin/relatorios">Ver relatórios</a>
    <a class="btn btn--primary" href="${ctx}/admin/produtos#formulario">Novo produto</a>
  </div>
</header>

<section aria-labelledby="indicadores-titulo">
  <h2 class="visually-hidden" id="indicadores-titulo">Indicadores</h2>
  <div class="stats">
    <a class="stats__item" href="${ctx}/admin/fornecedores"><span class="stats__value">${painel.fornecedores}</span><span class="stats__label">fornecedores</span></a>
    <a class="stats__item" href="${ctx}/admin/produtos"><span class="stats__value">${painel.produtos}</span><span class="stats__label">produtos</span></a>
    <a class="stats__item" href="${ctx}/admin/listagens?tipo=clientes"><span class="stats__value">${painel.clientes}</span><span class="stats__label">clientes</span></a>
    <a class="stats__item" href="${ctx}/admin/compras"><span class="stats__value">${painel.vendas}</span><span class="stats__label">vendas</span></a>
    <a class="stats__item" href="${ctx}/admin/campanhas"><span class="stats__value">${painel.campanhas}</span><span class="stats__label">${painel.campanhas == 1 ? 'campanha' : 'campanhas'}</span></a>
    <div class="stats__item stats__item--highlight"><span class="stats__value">${f:mt(painel.totalVendido)}</span><span class="stats__label">total vendido (com IVA)</span></div>
  </div>
</section>

<div class="columns columns--2">
  <section class="card" aria-labelledby="ultimas-vendas">
    <header class="card__header">
      <h2 class="card__title" id="ultimas-vendas">Últimas vendas</h2>
      <a class="btn btn--ghost btn--sm" href="${ctx}/admin/compras">Ver todas</a>
    </header>
    <c:choose>
      <c:when test="${empty painel.ultimasVendas}"><p class="empty-state">Ainda não há vendas.</p></c:when>
      <c:otherwise>
        <div class="table-wrap">
          <table class="table">
            <thead>
              <tr>
                <th scope="col" class="table__th">Factura</th>
                <th scope="col" class="table__th">Cliente</th>
                <th scope="col" class="table__th table__th--num">Total</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="v" items="${painel.ultimasVendas}">
                <tr class="table__row">
                  <th scope="row" class="table__td table__td--nowrap">
                    <a href="${ctx}/factura?id=${v.id}"><c:out value="${v.numeroFactura}"/></a>
                    <span class="table__sub">${f:dataHora(v.data)}</span>
                  </th>
                  <td class="table__td"><c:out value="${v.clienteNome}"/></td>
                  <td class="table__td table__td--num">${f:mt(v.total)}</td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </c:otherwise>
    </c:choose>
  </section>

  <section class="card" aria-labelledby="stock-baixo">
    <header class="card__header">
      <h2 class="card__title" id="stock-baixo">Stock baixo <span class="card__title-meta">(menos de ${limiteStock})</span></h2>
    </header>
    <c:choose>
      <c:when test="${empty painel.stockBaixo}"><p class="empty-state">Todos os produtos têm stock suficiente.</p></c:when>
      <c:otherwise>
        <ul class="list">
          <c:forEach var="p" items="${painel.stockBaixo}">
            <li class="list__item">
              <a class="list__main" href="${ctx}/admin/produtos#produto-${p.id}"><c:out value="${p.nome}"/></a>
              <span class="list__meta ${p.quantidade == 0 ? 'stock stock--out' : 'stock stock--low'}">${p.quantidade} <c:out value="${p.unidade}"/></span>
            </li>
          </c:forEach>
        </ul>
      </c:otherwise>
    </c:choose>
  </section>
</div>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
