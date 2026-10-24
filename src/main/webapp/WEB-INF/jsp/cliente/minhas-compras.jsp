<c:set var="titulo" value="Minhas compras"/>
<c:set var="menu" value="minhas"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<div class="cabecalho-pagina">
  <h1>Minhas compras</h1>
  <p class="subtitulo">Histórico de todas as suas compras e respectivas facturas.</p>
</div>

<c:choose>
  <c:when test="${empty vendas}">
    <section class="cartao vazio-cartao">
      <p>Ainda não fez nenhuma compra.</p>
      <a class="botao botao-primario" href="${ctx}/catalogo">Ver catálogo</a>
    </section>
  </c:when>
  <c:otherwise>
    <div class="tabela-envolvente">
      <table class="tabela">
        <thead>
          <tr><th>Factura</th><th>Data</th><th>Produtos</th><th class="num">Total</th><th></th></tr>
        </thead>
        <tbody>
          <c:forEach var="v" items="${vendas}">
            <tr>
              <td><strong><c:out value="${v.numeroFactura}"/></strong></td>
              <td>${f:dataHora(v.data)}</td>
              <td>
                <c:forEach var="i" items="${v.itens}" varStatus="s">
                  <c:out value="${i.produtoNome}"/> (${i.quantidade})<c:if test="${!s.last}">, </c:if>
                </c:forEach>
              </td>
              <td class="num">${f:mt(v.total)}</td>
              <td><a class="botao botao-pequeno" href="${ctx}/factura?id=${v.id}">Ver factura</a></td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>
  </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
