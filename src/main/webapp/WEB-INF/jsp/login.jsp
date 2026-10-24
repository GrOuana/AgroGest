<c:set var="titulo" value="Entrar"/>
<c:set var="menu" value="login"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<section class="cartao cartao-estreito">
  <h1>Entrar no AgroGest</h1>
  <p class="subtitulo">Loja e caderno de campo do agricultor de Nampula.</p>

  <form method="post" action="${ctx}/login" class="formulario">
    <label>Email
      <input type="email" name="email" required autofocus autocomplete="username"
             value="${fn:escapeXml(param.email)}">
    </label>
    <label>Palavra-passe
      <input type="password" name="password" required autocomplete="current-password">
    </label>
    <button type="submit" class="botao botao-primario botao-largo">Entrar</button>
  </form>

  <p class="nota-centro">Ainda não tem conta? <a href="${ctx}/registo">Registe-se como cliente</a>.</p>
</section>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
