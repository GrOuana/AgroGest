<c:set var="titulo" value="Fornecedores"/>
<c:set var="menu" value="fornecedores"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>
<%-- Valores do formulário depois de um erro de validação (o servidor devolve a página com ${erro}) --%>
<c:set var="voltar" value="${param.accao == 'criar'}"/>

<header class="page__header">
  <div class="page__heading">
    <h1 class="page__title">Fornecedores</h1>
    <p class="page__subtitle">Fornecedores de sementes, fertilizantes e maquinaria.</p>
  </div>
</header>

<section class="card" aria-labelledby="novo-fornecedor">
  <header class="card__header"><h2 class="card__title" id="novo-fornecedor">Novo fornecedor</h2></header>
  <form method="post" action="${ctx}/admin/fornecedores" class="form">
    <input type="hidden" name="accao" value="criar">
    <div class="form__grid">
      <div class="form__field">
        <label class="form__label" for="campo-nome">Nome</label>
        <input class="form__input ${erroCampo == 'nome' ? 'form__input--invalid' : ''}" id="campo-nome"
               type="text" name="nome" required minlength="2" maxlength="120" placeholder="Sementes do Sul, Lda"
               pattern="^[A-Za-zÀ-ÖØ-öø-ÿ][A-Za-zÀ-ÖØ-öø-ÿ .,&'\-]*$"
               title="Letras, espaços e . , &amp; ' - (sem números)"
               aria-invalid="${erroCampo == 'nome'}" aria-describedby="ajuda-nome${erroCampo == 'nome' ? ' erro-nome' : ''}"
               value="${fn:escapeXml(voltar ? param.nome : '')}">
        <p class="form__hint" id="ajuda-nome">Sem números. Ex.: Sementes do Sul, Lda</p>
        <c:set var="campo" value="nome"/><%@ include file="/WEB-INF/jsp/comum/erro-campo.jspf" %>
      </div>
      <div class="form__field">
        <label class="form__label" for="campo-tipo">Tipo</label>
        <select class="form__input ${erroCampo == 'tipo' ? 'form__input--invalid' : ''}" id="campo-tipo" name="tipo" required
                aria-invalid="${erroCampo == 'tipo'}">
          <option value="">— escolher —</option>
          <c:forEach var="t" items="${tipos}">
            <option value="${t}" ${voltar && param.tipo == t.name() ? 'selected' : ''}>${t.descricao}</option>
          </c:forEach>
        </select>
        <c:set var="campo" value="tipo"/><%@ include file="/WEB-INF/jsp/comum/erro-campo.jspf" %>
      </div>
      <div class="form__field">
        <label class="form__label" for="campo-contacto">Contacto (telefone)</label>
        <input class="form__input ${erroCampo == 'contacto' ? 'form__input--invalid' : ''}" id="campo-contacto"
               type="tel" name="contacto" required minlength="9" maxlength="9" inputmode="numeric" placeholder="841234567"
               pattern="^8[2-7]\d{7}$"
               title="9 dígitos a começar por 82 a 87, sem espaços nem +258. Ex.: 841234567"
               aria-invalid="${erroCampo == 'contacto'}" aria-describedby="ajuda-contacto${erroCampo == 'contacto' ? ' erro-contacto' : ''}"
               value="${fn:escapeXml(voltar ? param.contacto : '')}">
        <p class="form__hint" id="ajuda-contacto">9 dígitos, 82 a 87. Ex.: 841234567</p>
        <c:set var="campo" value="contacto"/><%@ include file="/WEB-INF/jsp/comum/erro-campo.jspf" %>
      </div>
      <div class="form__field">
        <label class="form__label" for="campo-provincia">Província</label>
        <input class="form__input ${erroCampo == 'provincia' ? 'form__input--invalid' : ''}" id="campo-provincia"
               type="text" name="provincia" required minlength="2" maxlength="60" placeholder="Maputo" list="provincias"
               pattern="^[A-Za-zÀ-ÖØ-öø-ÿ][A-Za-zÀ-ÖØ-öø-ÿ .,&'\-]*$" title="Só letras e espaços"
               aria-invalid="${erroCampo == 'provincia'}" aria-describedby="ajuda-provincia${erroCampo == 'provincia' ? ' erro-provincia' : ''}"
               value="${fn:escapeXml(voltar ? param.provincia : '')}">
        <datalist id="provincias">
          <option value="Cabo Delgado"><option value="Gaza"><option value="Inhambane"><option value="Manica">
          <option value="Maputo"><option value="Nampula"><option value="Niassa"><option value="Sofala">
          <option value="Tete"><option value="Zambézia">
        </datalist>
        <p class="form__hint" id="ajuda-provincia">Só letras.</p>
        <c:set var="campo" value="provincia"/><%@ include file="/WEB-INF/jsp/comum/erro-campo.jspf" %>
      </div>
    </div>
    <div class="form__actions">
      <button type="submit" class="btn btn--primary">Criar fornecedor</button>
    </div>
  </form>
</section>

<section class="card" aria-labelledby="lista-fornecedores">
  <header class="card__header">
    <h2 class="card__title" id="lista-fornecedores">Fornecedores registados <span class="card__title-meta">(${fn:length(fornecedores)})</span></h2>
  </header>
  <c:choose>
    <c:when test="${empty fornecedores}"><p class="empty-state">Ainda não há fornecedores.</p></c:when>
    <c:otherwise>
      <div class="table-wrap">
        <table class="table">
          <thead>
            <tr>
              <th scope="col" class="table__th">#</th>
              <th scope="col" class="table__th">Nome</th>
              <th scope="col" class="table__th">Tipo</th>
              <th scope="col" class="table__th">Contacto</th>
              <th scope="col" class="table__th">Província</th>
              <th scope="col" class="table__th"><span class="visually-hidden">Acções</span></th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="fo" items="${fornecedores}">
              <tr class="table__row">
                <td class="table__td">${fo.id}</td>
                <th scope="row" class="table__td"><span class="table__strong"><c:out value="${fo.nome}"/></span></th>
                <td class="table__td"><span class="tag">${fo.tipo.descricao}</span></td>
                <td class="table__td table__td--nowrap">${fn:escapeXml(f:telefone(fo.contacto))}</td>
                <td class="table__td"><c:out value="${fo.provincia}"/></td>
                <td class="table__td table__td--nowrap">
                  <details class="confirm">
                    <summary class="confirm__toggle btn btn--danger btn--sm">Remover<span class="visually-hidden"> <c:out value="${fo.nome}"/></span></summary>
                    <form method="post" action="${ctx}/admin/fornecedores" class="confirm__panel">
                      <p class="confirm__text">Remover «<c:out value="${fo.nome}"/>»?</p>
                      <input type="hidden" name="accao" value="remover">
                      <input type="hidden" name="id" value="${fo.id}">
                      <button type="submit" class="btn btn--danger btn--sm">Confirmar remoção</button>
                    </form>
                  </details>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </c:otherwise>
  </c:choose>
</section>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
