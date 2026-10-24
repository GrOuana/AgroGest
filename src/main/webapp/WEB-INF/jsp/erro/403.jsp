<c:set var="titulo" value="Acesso negado"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<section class="cartao cartao-estreito pagina-erro">
  <p class="codigo-erro">403</p>
  <h1>Acesso negado</h1>
  <p><c:out value="${requestScope['jakarta.servlet.error.message']}" default="Não tem permissão para ver esta página."/></p>
  <c:choose>
    <c:when test="${u == null}"><a class="botao botao-primario" href="${ctx}/login">Entrar</a></c:when>
    <c:otherwise><a class="botao botao-primario" href="${ctx}/">Voltar ao início</a></c:otherwise>
  </c:choose>
</section>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
