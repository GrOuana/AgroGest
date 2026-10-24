<c:set var="titulo" value="Factura ${venda.numeroFactura}"/>
<c:set var="menu" value="${sessionScope.utilizador.admin ? 'compras' : 'minhas'}"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<div class="accoes accoes-topo nao-imprimir">
  <c:choose>
    <c:when test="${u.admin}"><a class="botao botao-secundario" href="${ctx}/admin/compras">← Compras</a></c:when>
    <c:otherwise><a class="botao botao-secundario" href="${ctx}/minhas-compras">← Minhas compras</a></c:otherwise>
  </c:choose>
  <a class="botao botao-primario" href="${ctx}/factura?id=${venda.id}&amp;imprimir=1" target="_blank" rel="noopener">Imprimir factura</a>
</div>

<%@ include file="/WEB-INF/jsp/cliente/factura-corpo.jspf" %>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
