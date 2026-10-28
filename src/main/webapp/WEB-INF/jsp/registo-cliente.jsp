<%--
  Registo de cliente.
  Validação no browser (HTML5: required, type, pattern, minlength, maxlength) para
  dar resposta imediata; a mesma validação repete-se no servidor (AuthService +
  Validar), que é a que garante a integridade dos dados. Se o servidor recusar,
  ${erro} traz a mensagem e ${erroCampo} o nome do campo, que fica assinalado.
--%>
<c:set var="titulo" value="Criar conta"/>
<c:set var="menu" value="registo"/>
<c:set var="paginaEstreita" value="${true}"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<section class="card" aria-labelledby="registo-titulo">
  <header class="page__header">
    <div class="page__heading">
      <h1 class="page__title" id="registo-titulo">Criar conta de cliente</h1>
      <p class="page__subtitle">Registe-se para comprar sementes, fertilizantes e ferramentas.</p>
    </div>
  </header>

  <form method="post" action="${ctx}/registo" class="form" aria-describedby="registo-obrigatorios">
    <p class="note" id="registo-obrigatorios">Todos os campos são obrigatórios.</p>

    <div class="form__field">
      <label class="form__label" for="campo-nome">Nome completo</label>
      <input class="form__input ${erroCampo == 'nome' ? 'form__input--invalid' : ''}"
             id="campo-nome" name="nome" type="text" required minlength="2" maxlength="120"
             autocomplete="name" placeholder="João Silva"
             pattern="^[A-Za-zÀ-ÖØ-öø-ÿ][A-Za-zÀ-ÖØ-öø-ÿ '\-]*$"
             title="Só letras e espaços, sem números (ex.: João Silva)"
             aria-invalid="${erroCampo == 'nome'}"
             aria-describedby="ajuda-nome${erroCampo == 'nome' ? ' erro-nome' : ''}"
             value="${fn:escapeXml(param.nome)}">
      <p class="form__hint" id="ajuda-nome">Só letras e espaços, sem números.</p>
      <c:set var="campo" value="nome"/><%@ include file="/WEB-INF/jsp/comum/erro-campo.jspf" %>
    </div>

    <div class="form__field">
      <label class="form__label" for="campo-email">Email</label>
      <input class="form__input ${erroCampo == 'email' ? 'form__input--invalid' : ''}"
             id="campo-email" name="email" type="email" required maxlength="120"
             autocomplete="email" placeholder="nome@dominio.mz"
             pattern="^[^@\s]+@[^@\s]+\.[^@\s]{2,}$"
             title="Um email válido, por exemplo joao@teste.mz"
             aria-invalid="${erroCampo == 'email'}"
             aria-describedby="ajuda-email${erroCampo == 'email' ? ' erro-email' : ''}"
             value="${fn:escapeXml(param.email)}">
      <p class="form__hint" id="ajuda-email">Será o seu nome de utilizador. Não pode estar já registado.</p>
      <c:set var="campo" value="email"/><%@ include file="/WEB-INF/jsp/comum/erro-campo.jspf" %>
    </div>

    <div class="form__grid form__grid--2">
      <div class="form__field">
        <label class="form__label" for="campo-password">Palavra-passe</label>
        <input class="form__input ${erroCampo == 'password' ? 'form__input--invalid' : ''}"
               id="campo-password" name="password" type="password" required minlength="4" maxlength="100"
               autocomplete="new-password"
               title="Pelo menos 4 caracteres"
               aria-invalid="${erroCampo == 'password'}"
               aria-describedby="ajuda-password${erroCampo == 'password' ? ' erro-password' : ''}">
        <p class="form__hint" id="ajuda-password">Mínimo 4 caracteres.</p>
        <c:set var="campo" value="password"/><%@ include file="/WEB-INF/jsp/comum/erro-campo.jspf" %>
      </div>
      <div class="form__field">
        <label class="form__label" for="campo-confirmacao">Confirmar palavra-passe</label>
        <input class="form__input ${erroCampo == 'confirmacao' ? 'form__input--invalid' : ''}"
               id="campo-confirmacao" name="confirmacao" type="password" required minlength="4" maxlength="100"
               autocomplete="new-password"
               aria-invalid="${erroCampo == 'confirmacao'}"
               aria-describedby="ajuda-confirmacao${erroCampo == 'confirmacao' ? ' erro-confirmacao' : ''}">
        <p class="form__hint" id="ajuda-confirmacao">Repita a palavra-passe.</p>
        <c:set var="campo" value="confirmacao"/><%@ include file="/WEB-INF/jsp/comum/erro-campo.jspf" %>
      </div>
    </div>

    <div class="form__field">
      <label class="form__label" for="campo-telefone">Telefone</label>
      <input class="form__input ${erroCampo == 'telefone' ? 'form__input--invalid' : ''}"
             id="campo-telefone" name="telefone" type="tel" required minlength="9" maxlength="9"
             inputmode="numeric" autocomplete="tel-national" placeholder="841234567"
             pattern="^8[2-7]\d{7}$"
             title="9 dígitos a começar por 82, 83, 84, 85, 86 ou 87 (Tmcel, Vodacom ou Movitel), sem espaços nem +258. Ex.: 841234567"
             aria-invalid="${erroCampo == 'telefone'}"
             aria-describedby="ajuda-telefone${erroCampo == 'telefone' ? ' erro-telefone' : ''}"
             value="${fn:escapeXml(param.telefone)}">
      <p class="form__hint" id="ajuda-telefone">Número moçambicano: 9 dígitos começados por 82 a 87, sem +258. Ex.: 841234567.</p>
      <c:set var="campo" value="telefone"/><%@ include file="/WEB-INF/jsp/comum/erro-campo.jspf" %>
    </div>

    <div class="form__field">
      <label class="form__label" for="campo-endereco">Endereço</label>
      <input class="form__input ${erroCampo == 'endereco' ? 'form__input--invalid' : ''}"
             id="campo-endereco" name="endereco" type="text" required minlength="5" maxlength="200"
             autocomplete="street-address" placeholder="Av. Eduardo Mondlane, Nampula"
             title="Rua ou bairro e cidade"
             aria-invalid="${erroCampo == 'endereco'}"
             aria-describedby="ajuda-endereco${erroCampo == 'endereco' ? ' erro-endereco' : ''}"
             value="${fn:escapeXml(param.endereco)}">
      <p class="form__hint" id="ajuda-endereco">Rua ou bairro e cidade. Aparece nas suas facturas.</p>
      <c:set var="campo" value="endereco"/><%@ include file="/WEB-INF/jsp/comum/erro-campo.jspf" %>
    </div>

    <button type="submit" class="btn btn--primary btn--block">Criar conta</button>
  </form>

  <p class="note note--center">Já tem conta? <a href="${ctx}/login">Entrar</a>.</p>
</section>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
