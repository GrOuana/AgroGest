<c:set var="titulo" value="Página não encontrada"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<section class="cartao cartao-estreito pagina-erro">
  <p class="codigo-erro">404</p>
  <h1>Página não encontrada</h1>
  <p><c:out value="${requestScope['jakarta.servlet.error.message']}" default="O endereço pedido não existe."/></p>
  <a class="botao botao-primario" href="${ctx}/">Voltar ao início</a>
</section>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
