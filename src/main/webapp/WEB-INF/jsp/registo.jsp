<c:set var="titulo" value="Criar conta"/>
<c:set var="menu" value="registo"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<section class="cartao cartao-estreito">
  <h1>Criar conta de cliente</h1>
  <p class="subtitulo">Registe-se para comprar sementes, fertilizantes e ferramentas.</p>

  <form method="post" action="${ctx}/registo" class="formulario">
    <label>Nome completo
      <input type="text" name="nome" required maxlength="200" autocomplete="name"
             value="${fn:escapeXml(param.nome)}">
    </label>
    <label>Email
      <input type="email" name="email" required maxlength="200" autocomplete="email"
             value="${fn:escapeXml(param.email)}">
    </label>
    <div class="grelha-2">
      <label>Palavra-passe
        <input type="password" name="password" required minlength="4" autocomplete="new-password">
      </label>
      <label>Confirmar palavra-passe
        <input type="password" name="confirmacao" required minlength="4" autocomplete="new-password">
      </label>
    </div>
    <label>Telefone
      <input type="tel" name="telefone" required maxlength="40" placeholder="+258 84 000 0000"
             value="${fn:escapeXml(param.telefone)}">
    </label>
    <label>Endereço
      <input type="text" name="endereco" required maxlength="200" placeholder="Av. Eduardo Mondlane, Nampula"
             value="${fn:escapeXml(param.endereco)}">
    </label>
    <button type="submit" class="botao botao-primario botao-largo">Criar conta</button>
  </form>

  <p class="nota-centro">Já tem conta? <a href="${ctx}/login">Entrar</a>.</p>
</section>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
