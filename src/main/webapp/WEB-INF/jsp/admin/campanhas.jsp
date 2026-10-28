<c:set var="titulo" value="Campanhas"/>
<c:set var="menu" value="campanhas"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>
<c:set var="voltar" value="${param.accao == 'criar'}"/>

<header class="page__header">
  <div class="page__heading">
    <h1 class="page__title">Campanhas agrícolas</h1>
    <p class="page__subtitle">Uma campanha agrupa os cultivos de uma época. Campanhas com cultivos não podem ser removidas.</p>
  </div>
</header>

<section class="card" aria-labelledby="nova-campanha">
  <header class="card__header"><h2 class="card__title" id="nova-campanha">Nova campanha</h2></header>
  <form method="post" action="${ctx}/admin/campanhas" class="form form--inline">
    <input type="hidden" name="accao" value="criar">
    <div class="form__field">
      <label class="form__label" for="campo-nome">Nome</label>
      <input class="form__input ${voltar && erroCampo == 'nome' ? 'form__input--invalid' : ''}" id="campo-nome" type="text" name="nome"
             required minlength="3" maxlength="120" placeholder="Campanha 2026/2027"
             aria-invalid="${voltar && erroCampo == 'nome'}" value="${fn:escapeXml(voltar ? param.nome : '')}">
    </div>
    <div class="form__field">
      <label class="form__label" for="campo-inicio">Início</label>
      <input class="form__input ${voltar && erroCampo == 'inicio' ? 'form__input--invalid' : ''}" id="campo-inicio" type="date" name="inicio" required
             aria-invalid="${voltar && erroCampo == 'inicio'}" value="${fn:escapeXml(voltar ? param.inicio : '')}">
    </div>
    <div class="form__field">
      <label class="form__label" for="campo-fim">Fim</label>
      <input class="form__input ${voltar && erroCampo == 'fim' ? 'form__input--invalid' : ''}" id="campo-fim" type="date" name="fim" required
             aria-invalid="${voltar && erroCampo == 'fim'}" aria-describedby="ajuda-fim"
             value="${fn:escapeXml(voltar ? param.fim : '')}">
    </div>
    <button type="submit" class="btn btn--primary">Criar campanha</button>
  </form>
  <p class="note" id="ajuda-fim">A data de fim não pode ser anterior à de início.</p>
</section>

<section class="card" aria-labelledby="lista-campanhas">
  <header class="card__header">
    <h2 class="card__title" id="lista-campanhas">Campanhas <span class="card__title-meta">(${fn:length(campanhas)})</span></h2>
  </header>
  <c:choose>
    <c:when test="${empty campanhas}"><p class="empty-state">Ainda não há campanhas.</p></c:when>
    <c:otherwise>
      <div class="table-wrap">
        <table class="table">
          <thead>
            <tr>
              <th scope="col" class="table__th">#</th>
              <th scope="col" class="table__th">Nome</th>
              <th scope="col" class="table__th">Início</th>
              <th scope="col" class="table__th">Fim</th>
              <th scope="col" class="table__th">Estado</th>
              <th scope="col" class="table__th table__th--num">Cultivos</th>
              <th scope="col" class="table__th"><span class="visually-hidden">Acções</span></th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="c" items="${campanhas}">
              <tr class="table__row">
                <td class="table__td">${c.id}</td>
                <th scope="row" class="table__td"><span class="table__strong"><c:out value="${c.nome}"/></span></th>
                <td class="table__td table__td--nowrap"><time datetime="${f:iso(c.inicio)}">${f:data(c.inicio)}</time></td>
                <td class="table__td table__td--nowrap"><time datetime="${f:iso(c.fim)}">${f:data(c.fim)}</time></td>
                <td class="table__td">
                  <c:choose>
                    <c:when test="${c.fechada}"><span class="tag">Fechada</span></c:when>
                    <c:otherwise><span class="tag tag--success">Aberta</span></c:otherwise>
                  </c:choose>
                </td>
                <td class="table__td table__td--num"><a href="${ctx}/admin/cultivos?campanhaId=${c.id}">${numCultivos[c.id]}<span class="visually-hidden"> cultivos</span></a></td>
                <td class="table__td table__td--nowrap">
                  <div class="actions actions--nowrap">
                    <form method="post" action="${ctx}/admin/campanhas" class="inline-form">
                      <input type="hidden" name="id" value="${c.id}">
                      <input type="hidden" name="accao" value="${c.fechada ? 'reabrir' : 'fechar'}">
                      <button type="submit" class="btn btn--secondary btn--sm">${c.fechada ? 'Reabrir' : 'Fechar'}<span class="visually-hidden"> <c:out value="${c.nome}"/></span></button>
                    </form>
                    <details class="confirm">
                      <summary class="confirm__toggle btn btn--danger btn--sm">Remover<span class="visually-hidden"> <c:out value="${c.nome}"/></span></summary>
                      <form method="post" action="${ctx}/admin/campanhas" class="confirm__panel">
                        <p class="confirm__text">Remover «<c:out value="${c.nome}"/>»?</p>
                        <input type="hidden" name="accao" value="remover">
                        <input type="hidden" name="id" value="${c.id}">
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
