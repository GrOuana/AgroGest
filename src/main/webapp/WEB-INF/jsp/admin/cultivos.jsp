<c:set var="titulo" value="Cultivos"/>
<c:set var="menu" value="cultivos"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>
<c:set var="voltar" value="${param.accao == 'criar'}"/>

<header class="page__header">
  <div class="page__heading">
    <h1 class="page__title">Cultivos</h1>
    <p class="page__subtitle">Cultivos registados por campanha. Cultivos com colheitas não podem ser removidos.</p>
  </div>
</header>

<section class="card" aria-labelledby="novo-cultivo">
  <header class="card__header"><h2 class="card__title" id="novo-cultivo">Registar cultivo</h2></header>
  <c:if test="${empty campanhas}">
    <div class="alert alert--warning" role="status"><p>Crie primeiro uma <a href="${ctx}/admin/campanhas">campanha</a>.</p></div>
  </c:if>
  <form method="post" action="${ctx}/admin/cultivos" class="form form--inline">
    <input type="hidden" name="accao" value="criar">
    <input type="hidden" name="filtroCampanhaId" value="${campanhaActual.id}">
    <c:set var="campanhaEscolhida" value="${voltar ? param.campanhaId : campanhaActual.id}"/>
    <div class="form__field">
      <label class="form__label" for="campo-campanhaId">Campanha</label>
      <select class="form__input" id="campo-campanhaId" name="campanhaId" required aria-describedby="ajuda-cultivo">
        <option value="">— escolher —</option>
        <c:forEach var="c" items="${campanhas}">
          <c:if test="${!c.fechada}">
            <option value="${c.id}" ${campanhaEscolhida == c.id ? 'selected' : ''}><c:out value="${c.nome}"/></option>
          </c:if>
        </c:forEach>
      </select>
    </div>
    <div class="form__field">
      <label class="form__label" for="campo-cultura">Cultura</label>
      <input class="form__input ${voltar && erroCampo == 'cultura' ? 'form__input--invalid' : ''}" id="campo-cultura" type="text" name="cultura"
             required minlength="2" maxlength="80" placeholder="Feijão nhemba"
             pattern="^[A-Za-zÀ-ÖØ-öø-ÿ][A-Za-zÀ-ÖØ-öø-ÿ .,&'\-]*$" title="Só letras e espaços, sem números"
             aria-invalid="${voltar && erroCampo == 'cultura'}" value="${fn:escapeXml(voltar ? param.cultura : '')}">
    </div>
    <div class="form__field">
      <label class="form__label" for="campo-variedade">Variedade</label>
      <input class="form__input" id="campo-variedade" type="text" name="variedade" required maxlength="80" placeholder="Macia"
             value="${fn:escapeXml(voltar ? param.variedade : '')}">
    </div>
    <div class="form__field">
      <label class="form__label" for="campo-hectares">Hectares</label>
      <input class="form__input ${voltar && erroCampo == 'hectares' ? 'form__input--invalid' : ''}" id="campo-hectares" type="number" name="hectares"
             required min="0.01" max="100000" step="0.01" inputmode="decimal" placeholder="8"
             title="Área em hectares, maior que zero"
             aria-invalid="${voltar && erroCampo == 'hectares'}" value="${fn:escapeXml(voltar ? param.hectares : '')}">
    </div>
    <div class="form__field">
      <label class="form__label" for="campo-plantio">Data de plantio</label>
      <input class="form__input ${voltar && erroCampo == 'plantio' ? 'form__input--invalid' : ''}" id="campo-plantio" type="date" name="plantio" required
             aria-invalid="${voltar && erroCampo == 'plantio'}" value="${fn:escapeXml(voltar ? param.plantio : '')}">
    </div>
    <button type="submit" class="btn btn--primary">Registar cultivo</button>
  </form>
  <p class="note" id="ajuda-cultivo">Só aparecem campanhas abertas. A data de plantio tem de estar dentro do período da campanha.</p>
</section>

<section class="card" aria-labelledby="lista-cultivos">
  <header class="card__header">
    <h2 class="card__title" id="lista-cultivos">Cultivos <span class="card__title-meta">(${fn:length(cultivos)})</span></h2>
    <form method="get" action="${ctx}/admin/cultivos" class="inline-form" role="search" aria-label="Filtrar cultivos">
      <label class="visually-hidden" for="filtro-campanha">Filtrar por campanha</label>
      <select class="form__input inline-form__select" id="filtro-campanha" name="campanhaId">
        <option value="">Todas as campanhas</option>
        <c:forEach var="c" items="${campanhas}">
          <option value="${c.id}" ${campanhaActual.id == c.id ? 'selected' : ''}><c:out value="${c.nome}"/></option>
        </c:forEach>
      </select>
      <button type="submit" class="btn btn--secondary btn--sm">Filtrar</button>
    </form>
  </header>
  <c:choose>
    <c:when test="${empty cultivos}"><p class="empty-state">Não há cultivos registados.</p></c:when>
    <c:otherwise>
      <div class="table-wrap">
        <table class="table">
          <thead>
            <tr>
              <th scope="col" class="table__th">#</th>
              <th scope="col" class="table__th">Cultura</th>
              <th scope="col" class="table__th">Variedade</th>
              <th scope="col" class="table__th">Campanha</th>
              <th scope="col" class="table__th table__th--num">Hectares</th>
              <th scope="col" class="table__th">Plantio</th>
              <th scope="col" class="table__th table__th--num">Colheitas</th>
              <th scope="col" class="table__th"><span class="visually-hidden">Acções</span></th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="cv" items="${cultivos}">
              <tr class="table__row">
                <td class="table__td">${cv.id}</td>
                <th scope="row" class="table__td"><span class="table__strong"><c:out value="${cv.cultura}"/></span></th>
                <td class="table__td"><c:out value="${cv.variedade}"/></td>
                <td class="table__td"><c:out value="${campanhasPorId[cv.campanhaId].nome}"/></td>
                <td class="table__td table__td--num">${f:numero(cv.hectares)} ha</td>
                <td class="table__td table__td--nowrap"><time datetime="${f:iso(cv.plantio)}">${f:data(cv.plantio)}</time></td>
                <td class="table__td table__td--num"><a href="${ctx}/admin/colheitas?cultivoId=${cv.id}">${numColheitas[cv.id]}<span class="visually-hidden"> colheitas</span></a></td>
                <td class="table__td table__td--nowrap">
                  <div class="actions actions--nowrap">
                    <a class="btn btn--secondary btn--sm" href="${ctx}/admin/colheitas?cultivoId=${cv.id}">Colheitas</a>
                    <details class="confirm">
                      <summary class="confirm__toggle btn btn--danger btn--sm">Remover<span class="visually-hidden"> <c:out value="${cv.cultura}"/></span></summary>
                      <form method="post" action="${ctx}/admin/cultivos" class="confirm__panel">
                        <p class="confirm__text">Remover o cultivo «<c:out value="${cv.cultura}"/>»?</p>
                        <input type="hidden" name="accao" value="remover">
                        <input type="hidden" name="id" value="${cv.id}">
                        <input type="hidden" name="filtroCampanhaId" value="${campanhaActual.id}">
                        <button type="submit" class="btn btn--danger btn--sm">Confirmar remoção</button>
                      </form>
                    </details>
                  </div>
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
