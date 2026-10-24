<c:set var="titulo" value="Colheitas"/>
<c:set var="menu" value="colheitas"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<div class="cabecalho-pagina">
  <h1>Colheitas</h1>
  <p class="subtitulo">Colheitas registadas por cultivo. O valor total é calculado pelo sistema: kg × preço por kg.</p>
</div>

<section class="cartao">
  <h2>Registar colheita</h2>
  <c:if test="${empty cultivos}">
    <p class="aviso aviso-erro">Registe primeiro um <a href="${ctx}/admin/cultivos">cultivo</a>.</p>
  </c:if>
  <form method="post" action="${ctx}/admin/colheitas" class="formulario formulario-linha">
    <input type="hidden" name="accao" value="criar">
    <input type="hidden" name="filtroCultivoId" value="${cultivoActual.id}">
    <c:set var="cultivoEscolhido" value="${param.accao == 'criar' ? param.cultivoId : cultivoActual.id}"/>
    <label>Cultivo
      <select name="cultivoId" required>
        <option value="">— escolher —</option>
        <c:forEach var="cv" items="${cultivos}">
          <c:set var="camp" value="${campanhasPorId[cv.campanhaId]}"/>
          <option value="${cv.id}" ${cultivoEscolhido == cv.id ? 'selected' : ''} ${camp.fechada ? 'disabled' : ''}>
            <c:out value="${cv.cultura} — ${cv.variedade} (${camp.nome})"/><c:if test="${camp.fechada}"> · fechada</c:if>
          </option>
        </c:forEach>
      </select>
    </label>
    <label>Data
      <input type="date" name="data" required value="${fn:escapeXml(param.accao == 'criar' ? param.data : '')}">
    </label>
    <label>Quantidade (kg)
      <input type="number" name="kg" required min="0.01" step="0.01" placeholder="3200"
             value="${fn:escapeXml(param.accao == 'criar' ? param.kg : '')}">
    </label>
    <label>Preço por kg (MT)
      <input type="number" name="precoKg" required min="0.01" step="0.01" placeholder="22"
             value="${fn:escapeXml(param.accao == 'criar' ? param.precoKg : '')}">
    </label>
    <button type="submit" class="botao botao-primario">Registar colheita</button>
  </form>
</section>

<section class="cartao">
  <div class="cartao-cabecalho">
    <h2>Colheitas
      <c:if test="${cultivoActual != null}"> de <c:out value="${cultivoActual.cultura} — ${cultivoActual.variedade}"/></c:if>
      <small>(${fn:length(colheitas)})</small>
    </h2>
    <form method="get" action="${ctx}/admin/colheitas" class="form-linha">
      <label class="sr-only" for="filtro-cultivo">Filtrar por cultivo</label>
      <select id="filtro-cultivo" name="cultivoId">
        <option value="">Todos os cultivos</option>
        <c:forEach var="cv" items="${cultivos}">
          <option value="${cv.id}" ${cultivoActual.id == cv.id ? 'selected' : ''}><c:out value="${cv.cultura} — ${cv.variedade}"/></option>
        </c:forEach>
      </select>
      <button type="submit" class="botao botao-pequeno botao-secundario">Filtrar</button>
    </form>
  </div>
  <c:choose>
    <c:when test="${empty colheitas}"><p class="vazio">Não há colheitas registadas.</p></c:when>
    <c:otherwise>
      <div class="tabela-envolvente">
        <table class="tabela">
          <thead><tr><th>#</th><th>Cultivo</th><th>Data</th><th class="num">Quantidade</th><th class="num">Preço/kg</th><th class="num">Valor total</th><th></th></tr></thead>
          <tbody>
            <c:forEach var="co" items="${colheitas}">
              <c:set var="cv" value="${cultivosPorId[co.cultivoId]}"/>
              <tr>
                <td>${co.id}</td>
                <td><c:out value="${cv.cultura} — ${cv.variedade}"/><br><small><c:out value="${campanhasPorId[cv.campanhaId].nome}"/></small></td>
                <td>${f:data(co.data)}</td>
                <td class="num">${f:numero(co.kg)} kg</td>
                <td class="num">${f:mt(co.precoKg)}</td>
                <td class="num"><strong>${f:mt(co.valorTotal)}</strong></td>
                <td class="celula-accoes">
                  <details class="confirmar">
                    <summary class="botao botao-pequeno botao-perigo">Remover</summary>
                    <form method="post" action="${ctx}/admin/colheitas">
                      <input type="hidden" name="accao" value="remover">
                      <input type="hidden" name="id" value="${co.id}">
                      <input type="hidden" name="filtroCultivoId" value="${cultivoActual.id}">
                      <button type="submit" class="botao botao-pequeno botao-perigo">Confirmar remoção</button>
                    </form>
                  </details>
                </td>
              </tr>
            </c:forEach>
          </tbody>
          <tfoot>
            <tr class="linha-total"><th colspan="3" class="num">Total</th><td class="num">${f:numero(totalKg)} kg</td><td></td><td class="num">${f:mt(totalValor)}</td><td></td></tr>
          </tfoot>
        </table>
      </div>
    </c:otherwise>
  </c:choose>
</section>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
