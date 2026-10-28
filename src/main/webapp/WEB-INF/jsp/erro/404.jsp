<c:set var="titulo" value="Página não encontrada"/>
<c:set var="paginaEstreita" value="${true}"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<section class="card error-page" aria-labelledby="erro-titulo">
  <p class="error-page__code" aria-hidden="true">404</p>
  <h1 class="error-page__title" id="erro-titulo">Página não encontrada</h1>
  <p class="error-page__text"><c:out value="${requestScope['jakarta.servlet.error.message']}" default="O endereço pedido não existe."/></p>
  <a class="btn btn--primary" href="${ctx}/">Voltar ao início</a>
</section>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
