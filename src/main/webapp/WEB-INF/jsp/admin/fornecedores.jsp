<c:set var="titulo" value="Fornecedores"/>
<c:set var="menu" value="fornecedores"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<div class="cabecalho-pagina">
  <h1>Fornecedores</h1>
  <p class="subtitulo">Fornecedores de sementes, fertilizantes e maquinaria.</p>
</div>

<section class="cartao">
  <h2>Novo fornecedor</h2>
  <form method="post" action="${ctx}/admin/fornecedores" class="formulario formulario-linha">
    <input type="hidden" name="accao" value="criar">
    <label>Nome
      <input type="text" name="nome" required maxlength="200" placeholder="Sementes do Sul, Lda"
             value="${fn:escapeXml(param.accao == 'criar' ? param.nome : '')}">
    </label>
    <label>Tipo
      <select name="tipo" required>
        <option value="">— escolher —</option>
        <c:forEach var="t" items="${tipos}">
          <option value="${t}" ${param.accao == 'criar' && param.tipo == t.name() ? 'selected' : ''}>${t.descricao}</option>
        </c:forEach>
      </select>
    </label>
    <label>Contacto
      <input type="text" name="contacto" required maxlength="200" placeholder="+258 84 000 0000"
             value="${fn:escapeXml(param.accao == 'criar' ? param.contacto : '')}">
    </label>
    <label>Província
      <input type="text" name="provincia" required maxlength="200" placeholder="Maputo"
             value="${fn:escapeXml(param.accao == 'criar' ? param.provincia : '')}">
    </label>
    <button type="submit" class="botao botao-primario">Criar fornecedor</button>
  </form>
</section>

<section class="cartao">
  <h2>Fornecedores registados <small>(${fn:length(fornecedores)})</small></h2>
  <c:choose>
    <c:when test="${empty fornecedores}"><p class="vazio">Ainda não há fornecedores.</p></c:when>
    <c:otherwise>
      <div class="tabela-envolvente">
        <table class="tabela">
          <thead><tr><th>#</th><th>Nome</th><th>Tipo</th><th>Contacto</th><th>Província</th><th></th></tr></thead>
          <tbody>
            <c:forEach var="fo" items="${fornecedores}">
              <tr>
                <td>${fo.id}</td>
                <td><strong><c:out value="${fo.nome}"/></strong></td>
                <td><span class="etiqueta">${fo.tipo.descricao}</span></td>
                <td><c:out value="${fo.contacto}"/></td>
                <td><c:out value="${fo.provincia}"/></td>
                <td class="celula-accoes">
                  <details class="confirmar">
                    <summary class="botao botao-pequeno botao-perigo">Remover</summary>
                    <form method="post" action="${ctx}/admin/fornecedores">
                      <input type="hidden" name="accao" value="remover">
                      <input type="hidden" name="id" value="${fo.id}">
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
