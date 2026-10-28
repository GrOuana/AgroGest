<c:set var="titulo" value="Entrar"/>
<c:set var="menu" value="login"/>
<c:set var="paginaEstreita" value="${true}"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<section class="card" aria-labelledby="login-titulo">
  <header class="page__header">
    <div class="page__heading">
      <h1 class="page__title" id="login-titulo">Entrar no AgroGest</h1>
      <p class="page__subtitle">Loja e caderno de campo do agricultor de Nampula.</p>
    </div>
  </header>

  <form method="post" action="${ctx}/login" class="form">
    <div class="form__field">
      <label class="form__label" for="campo-email">Email</label>
      <input class="form__input" id="campo-email" type="email" name="email" required maxlength="120"
             autocomplete="username" autofocus placeholder="nome@dominio.mz"
             value="${fn:escapeXml(param.email)}">
    </div>
    <div class="form__field">
      <label class="form__label" for="campo-password">Palavra-passe</label>
      <input class="form__input" id="campo-password" type="password" name="password" required
             autocomplete="current-password">
    </div>
    <button type="submit" class="btn btn--primary btn--block">Entrar</button>
  </form>

  <p class="note note--center">Ainda não tem conta? <a href="${ctx}/registo">Registe-se como cliente</a>.</p>
</section>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
