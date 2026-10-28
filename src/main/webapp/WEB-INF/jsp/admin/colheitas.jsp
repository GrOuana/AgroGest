<c:set var="titulo" value="Colheitas"/>
<c:set var="menu" value="colheitas"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>
<c:set var="voltar" value="${param.accao == 'criar'}"/>

<header class="page__header">
  <div class="page__heading">
    <h1 class="page__title">Colheitas</h1>
    <p class="page__subtitle">O valor total é calculado pelo sistema: kg × preço por kg.</p>
  </div>
</header>

<section class="card" aria-labelledby="nova-colheita">
  <header class="card__header"><h2 class="card__title" id="nova-colheita">Registar colheita</h2></header>
  <c:if test="${empty cultivos}">
    <div class="alert alert--warning" role="status"><p>Registe primeiro um <a href="${ctx}/admin/cultivos">cultivo</a>.</p></div>
  </c:if>
  <form method="post" action="${ctx}/admin/colheitas" class="form form--inline">
    <input type="hidden" name="accao" value="criar">
    <input type="hidden" name="filtroCultivoId" value="${cultivoActual.id}">
    <c:set var="cultivoEscolhido" value="${voltar ? param.cultivoId : cultivoActual.id}"/>
    <div class="form__field">
      <label class="form__label" for="campo-cultivoId">Cultivo</label>
      <select class="form__input" id="campo-cultivoId" name="cultivoId" required>
        <option value="">— escolher —</option>
        <c:forEach var="cv" items="${cultivos}">
          <c:set var="camp" value="${campanhasPorId[cv.campanhaId]}"/>
          <option value="${cv.id}" ${cultivoEscolhido == cv.id ? 'selected' : ''} ${camp.fechada ? 'disabled' : ''}>
            <c:out value="${cv.cultura} — ${cv.variedade} (${camp.nome})"/><c:if test="${camp.fechada}"> · fechada</c:if>
          </option>
        </c:forEach>
      </select>
    </div>
    <div class="form__field">
      <label class="form__label" for="campo-data">Data</label>
      <input class="form__input ${voltar && erroCampo == 'data' ? 'form__input--invalid' : ''}" id="campo-data" type="date" name="data" required
             aria-invalid="${voltar && erroCampo == 'data'}" value="${fn:escapeXml(voltar ? param.data : '')}">
    </div>
    <div class="form__field">
      <label class="form__label" for="campo-kg">Quantidade (kg)</label>
      <input class="form__input ${voltar && erroCampo == 'kg' ? 'form__input--invalid' : ''}" id="campo-kg" type="number" name="kg"
             required min="0.01" max="100000000" step="0.01" inputmode="decimal" placeholder="3200"
             title="Quilogramas, maior que zero"
             aria-invalid="${voltar && erroCampo == 'kg'}" value="${fn:escapeXml(voltar ? param.kg : '')}">
    </div>
    <div class="form__field">
      <label class="form__label" for="campo-precoKg">Preço por kg (MT)</label>
      <input class="form__input ${voltar && erroCampo == 'precoKg' ? 'form__input--invalid' : ''}" id="campo-precoKg" type="number" name="precoKg"
             required min="0.01" max="100000000" step="0.01" inputmode="decimal" placeholder="22.00"
             title="Meticais por kg, maior que zero, até 2 casas decimais"
             aria-invalid="${voltar && erroCampo == 'precoKg'}" value="${fn:escapeXml(voltar ? param.precoKg : '')}">
    </div>
    <button type="submit" class="btn btn--primary">Registar colheita</button>
  </form>
</section>

<section class="card" aria-labelledby="lista-colheitas">
  <header class="card__header">
    <h2 class="card__title" id="lista-colheitas">Colheitas
      <c:if test="${cultivoActual != null}"> de <c:out value="${cultivoActual.cultura} — ${cultivoActual.variedade}"/></c:if>
      <span class="card__title-meta">(${fn:length(colheitas)})</span>
    </h2>
    <form method="get" action="${ctx}/admin/colheitas" class="inline-form" role="search" aria-label="Filtrar colheitas">
      <label class="visually-hidden" for="filtro-cultivo">Filtrar por cultivo</label>
      <select class="form__input inline-form__select" id="filtro-cultivo" name="cultivoId">
        <option value="">Todos os cultivos</option>
        <c:forEach var="cv" items="${cultivos}">
          <option value="${cv.id}" ${cultivoActual.id == cv.id ? 'selected' : ''}><c:out value="${cv.cultura} — ${cv.variedade}"/></option>
        </c:forEach>
      </select>
      <button type="submit" class="btn btn--secondary btn--sm">Filtrar</button>
    </form>
  </header>
  <c:choose>
    <c:when test="${empty colheitas}"><p class="empty-state">Não há colheitas registadas.</p></c:when>
    <c:otherwise>
      <div class="table-wrap">
        <table class="table">
          <thead>
            <tr>
              <th scope="col" class="table__th">#</th>
              <th scope="col" class="table__th">Cultivo</th>
              <th scope="col" class="table__th">Data</th>
              <th scope="col" class="table__th table__th--num">Quantidade</th>
              <th scope="col" class="table__th table__th--num">Preço/kg</th>
              <th scope="col" class="table__th table__th--num">Valor total</th>
              <th scope="col" class="table__th"><span class="visually-hidden">Acções</span></th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="co" items="${colheitas}">
              <c:set var="cv" value="${cultivosPorId[co.cultivoId]}"/>
              <tr class="table__row">
                <td class="table__td">${co.id}</td>
                <th scope="row" class="table__td">
                  <span class="table__strong"><c:out value="${cv.cultura} — ${cv.variedade}"/></span>
                  <span class="table__sub"><c:out value="${campanhasPorId[cv.campanhaId].nome}"/></span>
                </th>
                <td class="table__td table__td--nowrap"><time datetime="${f:iso(co.data)}">${f:data(co.data)}</time></td>
                <td class="table__td table__td--num">${f:numero(co.kg)} kg</td>
                <td class="table__td table__td--num">${f:mt(co.precoKg)}</td>
                <td class="table__td table__td--num"><span class="table__strong">${f:mt(co.valorTotal)}</span></td>
                <td class="table__td table__td--nowrap">
                  <details class="confirm">
                    <summary class="confirm__toggle btn btn--danger btn--sm">Remover<span class="visually-hidden"> colheita ${co.id}</span></summary>
                    <form method="post" action="${ctx}/admin/colheitas" class="confirm__panel">
                      <p class="confirm__text">Remover esta colheita?</p>
                      <input type="hidden" name="accao" value="remover">
                      <input type="hidden" name="id" value="${co.id}">
                      <input type="hidden" name="filtroCultivoId" value="${cultivoActual.id}">
                      <button type="submit" class="btn btn--danger btn--sm">Confirmar remoção</button>
                    </form>
                  </details>
                </td>
              </tr>
            </c:forEach>
          </tbody>
          <tfoot>
            <tr class="table__row table__row--foot table__row--total">
              <th scope="row" colspan="3" class="table__th table__th--num">Total</th>
              <td class="table__td table__td--num">${f:numero(totalKg)} kg</td>
              <td class="table__td"></td>
              <td class="table__td table__td--num">${f:mt(totalValor)}</td>
              <td class="table__td"></td>
            </tr>
          </tfoot>
        </table>
      </div>
    </c:otherwise>
  </c:choose>
</section>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
