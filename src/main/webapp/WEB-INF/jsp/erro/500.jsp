<c:set var="titulo" value="Erro interno"/>
<c:set var="paginaEstreita" value="${true}"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<section class="card error-page" aria-labelledby="erro-titulo">
  <p class="error-page__code" aria-hidden="true">500</p>
  <h1 class="error-page__title" id="erro-titulo">Ocorreu um erro inesperado</h1>
  <p class="error-page__text">O pedido não pôde ser concluído. O erro ficou registado no log do Tomcat (<code>logs/catalina.*.log</code>).</p>
  <a class="btn btn--primary" href="${ctx}/">Voltar ao início</a>
</section>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
