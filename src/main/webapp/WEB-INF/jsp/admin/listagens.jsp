<c:set var="titulo" value="Listagens"/>
<c:set var="menu" value="listagens"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<header class="page__header">
  <div class="page__heading">
    <h1 class="page__title">Listagens</h1>
    <p class="page__subtitle">Clique no título de uma coluna para ordenar; clique outra vez para inverter.</p>
  </div>
</header>

<nav aria-label="Tipo de listagem">
  <ul class="filter-bar">
    <li><a class="filter-bar__chip ${tipo == 'produtos' ? 'filter-bar__chip--active' : ''}" href="${ctx}/admin/listagens?tipo=produtos" ${tipo == 'produtos' ? 'aria-current="page"' : ''}>Produtos</a></li>
    <li><a class="filter-bar__chip ${tipo == 'fornecedores' ? 'filter-bar__chip--active' : ''}" href="${ctx}/admin/listagens?tipo=fornecedores" ${tipo == 'fornecedores' ? 'aria-current="page"' : ''}>Fornecedores</a></li>
    <li><a class="filter-bar__chip ${tipo == 'clientes' ? 'filter-bar__chip--active' : ''}" href="${ctx}/admin/listagens?tipo=clientes" ${tipo == 'clientes' ? 'aria-current="page"' : ''}>Clientes</a></li>
    <li><a class="filter-bar__chip ${tipo == 'armazem' ? 'filter-bar__chip--active' : ''}" href="${ctx}/admin/listagens?tipo=armazem" ${tipo == 'armazem' ? 'aria-current="page"' : ''}>Armazém (stock &gt; 0)</a></li>
    <li><a class="filter-bar__chip" href="${ctx}/admin/compras">Compras detalhadas</a></li>
  </ul>
</nav>

<c:set var="baseOrdenar" value="/admin/listagens?tipo=${tipo}&amp;"/>

<section class="card" aria-label="Resultados">
  <c:choose>
    <c:when test="${empty itens}"><p class="empty-state">Sem registos.</p></c:when>

    <c:when test="${tipo == 'fornecedores'}">
      <div class="table-wrap">
        <table class="table">
          <caption class="table__caption">${fn:length(itens)} fornecedores</caption>
          <thead><tr>
            <c:set var="numerica" value="${false}"/>
            <c:set var="col" value="nome"/><c:set var="rotulo" value="Nome"/><%@ include file="/WEB-INF/jsp/comum/ordenar.jspf" %>
            <c:set var="col" value="tipo"/><c:set var="rotulo" value="Tipo"/><%@ include file="/WEB-INF/jsp/comum/ordenar.jspf" %>
            <th scope="col" class="table__th">Contacto</th>
            <c:set var="col" value="provincia"/><c:set var="rotulo" value="Província"/><%@ include file="/WEB-INF/jsp/comum/ordenar.jspf" %>
          </tr></thead>
          <tbody>
            <c:forEach var="fo" items="${itens}">
              <tr class="table__row">
                <th scope="row" class="table__td"><span class="table__strong"><c:out value="${fo.nome}"/></span></th>
                <td class="table__td">${fo.tipo.descricao}</td>
                <td class="table__td table__td--nowrap">${fn:escapeXml(f:telefone(fo.contacto))}</td>
                <td class="table__td"><c:out value="${fo.provincia}"/></td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </c:when>

    <c:when test="${tipo == 'clientes'}">
      <div class="table-wrap">
        <table class="table">
          <caption class="table__caption">${fn:length(itens)} clientes. Um cliente desactivado não consegue entrar.</caption>
          <thead><tr>
            <c:set var="numerica" value="${false}"/>
            <c:set var="col" value="nome"/><c:set var="rotulo" value="Nome"/><%@ include file="/WEB-INF/jsp/comum/ordenar.jspf" %>
            <th scope="col" class="table__th">Contactos</th>
            <th scope="col" class="table__th">Endereço</th>
            <c:set var="col" value="data"/><c:set var="rotulo" value="Registo"/><%@ include file="/WEB-INF/jsp/comum/ordenar.jspf" %>
            <c:set var="numerica" value="${true}"/>
            <c:set var="col" value="compras"/><c:set var="rotulo" value="Compras"/><%@ include file="/WEB-INF/jsp/comum/ordenar.jspf" %>
            <c:set var="col" value="valor"/><c:set var="rotulo" value="Volume"/><%@ include file="/WEB-INF/jsp/comum/ordenar.jspf" %>
            <th scope="col" class="table__th">Conta</th>
          </tr></thead>
          <tbody>
            <c:forEach var="r" items="${itens}">
              <tr class="table__row ${r.cliente.ativo ? '' : 'table__row--muted'}">
                <th scope="row" class="table__td">
                  <span class="table__strong"><c:out value="${r.cliente.nome}"/></span>
                  <c:if test="${!r.cliente.ativo}"><span class="tag">Desactivado</span></c:if>
                </th>
                <td class="table__td">
                  <c:out value="${r.cliente.email}"/>
                  <span class="table__sub">${fn:escapeXml(f:telefone(r.cliente.telefone))}</span>
                </td>
                <td class="table__td"><c:out value="${r.cliente.endereco}"/></td>
                <td class="table__td table__td--nowrap">${f:data(r.cliente.dataRegisto)}</td>
                <td class="table__td table__td--num">${r.numeroCompras}</td>
                <td class="table__td table__td--num">${f:mt(r.volume)}</td>
                <td class="table__td table__td--nowrap">
                  <form method="post" action="${ctx}/admin/clientes" class="inline-form">
                    <input type="hidden" name="id" value="${r.cliente.id}">
                    <button type="submit" class="btn btn--sm ${r.cliente.ativo ? 'btn--secondary' : 'btn--primary'}">
                      ${r.cliente.ativo ? 'Desactivar' : 'Activar'}<span class="visually-hidden"> <c:out value="${r.cliente.nome}"/></span>
                    </button>
                  </form>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </c:when>

    <c:otherwise>
      <%-- produtos e armazém --%>
      <div class="table-wrap">
        <table class="table">
          <caption class="table__caption">${fn:length(itens)} produtos${tipo == 'armazem' ? ' com stock disponível' : ''}</caption>
          <thead><tr>
            <c:set var="numerica" value="${false}"/>
            <c:set var="col" value="nome"/><c:set var="rotulo" value="Produto"/><%@ include file="/WEB-INF/jsp/comum/ordenar.jspf" %>
            <th scope="col" class="table__th">Categoria</th>
            <c:set var="col" value="fornecedor"/><c:set var="rotulo" value="Fornecedor"/><%@ include file="/WEB-INF/jsp/comum/ordenar.jspf" %>
            <c:set var="numerica" value="${true}"/>
            <c:set var="col" value="preco"/><c:set var="rotulo" value="Preço"/><%@ include file="/WEB-INF/jsp/comum/ordenar.jspf" %>
            <c:set var="col" value="stock"/><c:set var="rotulo" value="Stock"/><%@ include file="/WEB-INF/jsp/comum/ordenar.jspf" %>
            <c:choose>
              <c:when test="${tipo == 'armazem'}">
                <c:set var="col" value="valor"/><c:set var="rotulo" value="Valor em stock"/><%@ include file="/WEB-INF/jsp/comum/ordenar.jspf" %>
              </c:when>
              <c:otherwise>
                <c:set var="numerica" value="${false}"/>
                <c:set var="col" value="validade"/><c:set var="rotulo" value="Validade"/><%@ include file="/WEB-INF/jsp/comum/ordenar.jspf" %>
              </c:otherwise>
            </c:choose>
          </tr></thead>
          <tbody>
            <c:forEach var="p" items="${itens}">
              <tr class="table__row">
                <th scope="row" class="table__td"><span class="table__strong"><c:out value="${p.nome}"/></span></th>
                <td class="table__td"><span class="tag tag--${fn:toLowerCase(p.categoria)}">${p.categoria.descricao}</span></td>
                <td class="table__td"><c:out value="${p.fornecedorNome}"/></td>
                <td class="table__td table__td--num">${f:mt(p.preco)}</td>
                <td class="table__td table__td--num ${p.quantidade == 0 ? 'stock stock--out' : ''}">${p.quantidade} <c:out value="${p.unidade}"/></td>
                <c:choose>
                  <c:when test="${tipo == 'armazem'}"><td class="table__td table__td--num">${f:mt(p.valorEmStock)}</td></c:when>
                  <c:otherwise><td class="table__td table__td--nowrap">${p.validade == null ? '—' : f:data(p.validade)}</td></c:otherwise>
                </c:choose>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </c:otherwise>
  </c:choose>
</section>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
