<c:set var="titulo" value="Acesso negado"/>
<c:set var="paginaEstreita" value="${true}"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<section class="card error-page" aria-labelledby="erro-titulo">
  <p class="error-page__code" aria-hidden="true">403</p>
  <h1 class="error-page__title" id="erro-titulo">Acesso negado</h1>
  <p class="error-page__text"><c:out value="${requestScope['jakarta.servlet.error.message']}" default="Não tem permissão para ver esta página."/></p>
  <c:choose>
    <c:when test="${u == null}"><a class="btn btn--primary" href="${ctx}/login">Entrar</a></c:when>
    <c:otherwise><a class="btn btn--primary" href="${ctx}/">Voltar ao início</a></c:otherwise>
  </c:choose>
</section>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
