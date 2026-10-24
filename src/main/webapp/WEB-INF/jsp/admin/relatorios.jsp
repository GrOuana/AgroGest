<c:set var="titulo" value="Relatórios"/>
<c:set var="menu" value="relatorios"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<div class="cabecalho-pagina">
  <h1>Relatórios de clientes</h1>
</div>

<div class="grelha-2">
  <section class="cartao">
    <h2>1. Clientes por nome <small>(crescente)</small></h2>
    <c:choose>
      <c:when test="${empty porNome}"><p class="vazio">Sem clientes.</p></c:when>
      <c:otherwise>
        <ol class="ranking">
          <c:forEach var="r" items="${porNome}">
            <li><span><c:out value="${r.cliente.nome}"/></span><small><c:out value="${r.cliente.email}"/></small></li>
          </c:forEach>
        </ol>
      </c:otherwise>
    </c:choose>
  </section>

  <section class="cartao">
    <h2>2. Clientes que compraram <small>(por volume)</small></h2>
    <c:choose>
      <c:when test="${empty porVolume}"><p class="vazio">Ainda nenhum cliente comprou.</p></c:when>
      <c:otherwise>
        <div class="tabela-envolvente">
          <table class="tabela tabela-compacta">
            <thead><tr><th>#</th><th>Cliente</th><th class="num">Compras</th><th class="num">Volume</th></tr></thead>
            <tbody>
              <c:forEach var="r" items="${porVolume}" varStatus="s">
                <tr><td>${s.count}</td><td><c:out value="${r.cliente.nome}"/></td><td class="num">${r.numeroCompras}</td><td class="num"><strong>${f:mt(r.volume)}</strong></td></tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </c:otherwise>
    </c:choose>
  </section>

  <section class="cartao">
    <h2>3. Clientes mais assíduos <small>(nº de compras)</small></h2>
    <c:choose>
      <c:when test="${empty assiduos}"><p class="vazio">Ainda nenhum cliente comprou.</p></c:when>
      <c:otherwise>
        <div class="tabela-envolvente">
          <table class="tabela tabela-compacta">
            <thead><tr><th>#</th><th>Cliente</th><th class="num">Compras</th><th>Última compra</th></tr></thead>
            <tbody>
              <c:forEach var="r" items="${assiduos}" varStatus="s">
                <tr><td>${s.count}</td><td><c:out value="${r.cliente.nome}"/></td><td class="num"><strong>${r.numeroCompras}</strong></td><td>${f:dataHora(r.ultimaCompra)}</td></tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </c:otherwise>
    </c:choose>
  </section>

  <section class="cartao">
    <h2>4. Clientes sem compras <small>(extra)</small></h2>
    <c:choose>
      <c:when test="${empty semCompras}"><p class="vazio">Todos os clientes já compraram.</p></c:when>
      <c:otherwise>
        <ul class="lista-simples">
          <c:forEach var="r" items="${semCompras}">
            <li><span><c:out value="${r.cliente.nome}"/></span><small>registado em ${f:data(r.cliente.dataRegisto)}</small></li>
          </c:forEach>
        </ul>
      </c:otherwise>
    </c:choose>
  </section>
</div>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
