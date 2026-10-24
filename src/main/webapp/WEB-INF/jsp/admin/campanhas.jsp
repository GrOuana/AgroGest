<c:set var="titulo" value="Campanhas"/>
<c:set var="menu" value="campanhas"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<div class="cabecalho-pagina">
  <h1>Campanhas agrícolas</h1>
  <p class="subtitulo">Uma campanha agrupa os cultivos de uma época. Campanhas com cultivos não podem ser removidas.</p>
</div>

<section class="cartao">
  <h2>Nova campanha</h2>
  <form method="post" action="${ctx}/admin/campanhas" class="formulario formulario-linha">
    <input type="hidden" name="accao" value="criar">
    <label>Nome
      <input type="text" name="nome" required maxlength="200" placeholder="Campanha 2026/2027"
             value="${fn:escapeXml(param.accao == 'criar' ? param.nome : '')}">
    </label>
    <label>Início
      <input type="date" name="inicio" required value="${fn:escapeXml(param.accao == 'criar' ? param.inicio : '')}">
    </label>
    <label>Fim
      <input type="date" name="fim" required value="${fn:escapeXml(param.accao == 'criar' ? param.fim : '')}">
    </label>
    <button type="submit" class="botao botao-primario">Criar campanha</button>
  </form>
</section>

<section class="cartao">
  <h2>Campanhas <small>(${fn:length(campanhas)})</small></h2>
  <c:choose>
    <c:when test="${empty campanhas}"><p class="vazio">Ainda não há campanhas.</p></c:when>
    <c:otherwise>
      <div class="tabela-envolvente">
        <table class="tabela">
          <thead><tr><th>#</th><th>Nome</th><th>Início</th><th>Fim</th><th>Estado</th><th class="num">Cultivos</th><th></th></tr></thead>
          <tbody>
            <c:forEach var="c" items="${campanhas}">
              <tr>
                <td>${c.id}</td>
                <td><strong><c:out value="${c.nome}"/></strong></td>
                <td>${f:data(c.inicio)}</td>
                <td>${f:data(c.fim)}</td>
                <td>
                  <c:choose>
                    <c:when test="${c.fechada}"><span class="etiqueta etiqueta-cinza">Fechada</span></c:when>
                    <c:otherwise><span class="etiqueta etiqueta-verde">Aberta</span></c:otherwise>
                  </c:choose>
                </td>
                <td class="num"><a href="${ctx}/admin/cultivos?campanhaId=${c.id}">${numCultivos[c.id]}</a></td>
                <td class="celula-accoes">
                  <form method="post" action="${ctx}/admin/campanhas">
                    <input type="hidden" name="id" value="${c.id}">
                    <c:choose>
                      <c:when test="${c.fechada}">
                        <input type="hidden" name="accao" value="reabrir">
                        <button type="submit" class="botao botao-pequeno botao-secundario">Reabrir</button>
                      </c:when>
                      <c:otherwise>
                        <input type="hidden" name="accao" value="fechar">
                        <button type="submit" class="botao botao-pequeno botao-secundario">Fechar</button>
                      </c:otherwise>
                    </c:choose>
                  </form>
                  <details class="confirmar">
                    <summary class="botao botao-pequeno botao-perigo">Remover</summary>
                    <form method="post" action="${ctx}/admin/campanhas">
                      <input type="hidden" name="accao" value="remover">
                      <input type="hidden" name="id" value="${c.id}">
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
