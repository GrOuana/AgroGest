<c:set var="titulo" value="Erro interno"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<section class="cartao cartao-estreito pagina-erro">
  <p class="codigo-erro">500</p>
  <h1>Ocorreu um erro inesperado</h1>
  <p>O pedido não pôde ser concluído. O erro ficou registado no log do Tomcat (<code>logs/catalina.*.log</code>).</p>
  <a class="botao botao-primario" href="${ctx}/">Voltar ao início</a>
</section>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
