<c:set var="titulo" value="Cultivos"/>
<c:set var="menu" value="cultivos"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<div class="cabecalho-pagina">
  <h1>Cultivos</h1>
  <p class="subtitulo">Cultivos registados por campanha. Cultivos com colheitas não podem ser removidos.</p>
</div>

<section class="cartao">
  <h2>Registar cultivo</h2>
  <c:if test="${empty campanhas}">
    <p class="aviso aviso-erro">Crie primeiro uma <a href="${ctx}/admin/campanhas">campanha</a>.</p>
  </c:if>
  <form method="post" action="${ctx}/admin/cultivos" class="formulario formulario-linha">
    <input type="hidden" name="accao" value="criar">
    <input type="hidden" name="filtroCampanhaId" value="${campanhaActual.id}">
    <c:set var="campanhaEscolhida" value="${param.accao == 'criar' ? param.campanhaId : campanhaActual.id}"/>
    <label>Campanha
      <select name="campanhaId" required>
        <option value="">— escolher —</option>
        <c:forEach var="c" items="${campanhas}">
          <c:if test="${!c.fechada}">
            <option value="${c.id}" ${campanhaEscolhida == c.id ? 'selected' : ''}><c:out value="${c.nome}"/></option>
          </c:if>
        </c:forEach>
      </select>
    </label>
    <label>Cultura
      <input type="text" name="cultura" required maxlength="200" placeholder="Feijão nhemba"
             value="${fn:escapeXml(param.accao == 'criar' ? param.cultura : '')}">
    </label>
    <label>Variedade
      <input type="text" name="variedade" required maxlength="200" placeholder="Macia"
             value="${fn:escapeXml(param.accao == 'criar' ? param.variedade : '')}">
    </label>
    <label>Hectares
      <input type="number" name="hectares" required min="0.01" step="0.01" placeholder="8"
             value="${fn:escapeXml(param.accao == 'criar' ? param.hectares : '')}">
    </label>
    <label>Data de plantio
      <input type="date" name="plantio" required value="${fn:escapeXml(param.accao == 'criar' ? param.plantio : '')}">
    </label>
    <button type="submit" class="botao botao-primario">Registar cultivo</button>
  </form>
  <p class="nota">Só aparecem campanhas abertas. A data de plantio tem de estar dentro do período da campanha.</p>
</section>

<section class="cartao">
  <div class="cartao-cabecalho">
    <h2>Cultivos <small>(${fn:length(cultivos)})</small></h2>
    <form method="get" action="${ctx}/admin/cultivos" class="form-linha">
      <label class="sr-only" for="filtro-campanha">Filtrar por campanha</label>
      <select id="filtro-campanha" name="campanhaId">
        <option value="">Todas as campanhas</option>
        <c:forEach var="c" items="${campanhas}">
          <option value="${c.id}" ${campanhaActual.id == c.id ? 'selected' : ''}><c:out value="${c.nome}"/></option>
        </c:forEach>
      </select>
      <button type="submit" class="botao botao-pequeno botao-secundario">Filtrar</button>
    </form>
  </div>
  <c:choose>
    <c:when test="${empty cultivos}"><p class="vazio">Não há cultivos registados.</p></c:when>
    <c:otherwise>
      <div class="tabela-envolvente">
        <table class="tabela">
          <thead><tr><th>#</th><th>Cultura</th><th>Variedade</th><th>Campanha</th><th class="num">Hectares</th><th>Plantio</th><th class="num">Colheitas</th><th></th></tr></thead>
          <tbody>
            <c:forEach var="cv" items="${cultivos}">
              <tr>
                <td>${cv.id}</td>
                <td><strong><c:out value="${cv.cultura}"/></strong></td>
                <td><c:out value="${cv.variedade}"/></td>
                <td><c:out value="${campanhasPorId[cv.campanhaId].nome}"/></td>
                <td class="num">${f:numero(cv.hectares)} ha</td>
                <td>${f:data(cv.plantio)}</td>
                <td class="num"><a href="${ctx}/admin/colheitas?cultivoId=${cv.id}">${numColheitas[cv.id]}</a></td>
                <td class="celula-accoes">
                  <a class="botao botao-pequeno botao-secundario" href="${ctx}/admin/colheitas?cultivoId=${cv.id}">Colheitas</a>
                  <details class="confirmar">
                    <summary class="botao botao-pequeno botao-perigo">Remover</summary>
                    <form method="post" action="${ctx}/admin/cultivos">
                      <input type="hidden" name="accao" value="remover">
                      <input type="hidden" name="id" value="${cv.id}">
                      <input type="hidden" name="filtroCampanhaId" value="${campanhaActual.id}">
                      <button type="submit" class="botao botao-pequeno botao-perigo">Confirmar remoção</button>
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
