<c:set var="titulo" value="Factura ${venda.numeroFactura}"/>
<c:set var="menu" value="${sessionScope.utilizador.admin ? 'compras' : 'minhas'}"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<div class="actions actions--between actions--page no-print">
  <c:choose>
    <c:when test="${u.admin}"><a class="btn btn--secondary" href="${ctx}/admin/compras">← Compras</a></c:when>
    <c:otherwise><a class="btn btn--secondary" href="${ctx}/minhas-compras">← Minhas compras</a></c:otherwise>
  </c:choose>
  <a class="btn btn--primary" href="${ctx}/factura?id=${venda.id}&amp;imprimir=1" target="_blank" rel="noopener">
    Imprimir factura<span class="visually-hidden"> (abre num novo separador)</span>
  </a>
</div>

<%@ include file="/WEB-INF/jsp/cliente/factura-corpo.jspf" %>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
