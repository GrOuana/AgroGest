<c:set var="titulo" value="Carrinho"/>
<c:set var="menu" value="carrinho"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<div class="cabecalho-pagina">
  <h1>Carrinho</h1>
</div>

<c:choose>
  <c:when test="${resumo.vazio}">
    <section class="cartao vazio-cartao">
      <p>O seu carrinho está vazio.</p>
      <a class="botao botao-primario" href="${ctx}/catalogo">Ver catálogo</a>
    </section>
  </c:when>
  <c:otherwise>
    <c:if test="${!resumo.stockSuficiente}">
      <div class="aviso aviso-erro">Alguns produtos já não têm stock suficiente. Ajuste as quantidades assinaladas.</div>
    </c:if>

    <div class="tabela-envolvente">
      <table class="tabela">
        <thead>
          <tr>
            <th>Produto</th>
            <th class="num">Preço unit.</th>
            <th class="num">Quantidade</th>
            <th class="num">Subtotal</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="l" items="${resumo.linhas}">
            <tr class="${l.stockSuficiente ? '' : 'linha-erro'}">
              <td>
                <strong><c:out value="${l.produto.nome}"/></strong>
                <br><small>Disponível: ${l.produto.quantidade} <c:out value="${l.produto.unidade}"/></small>
              </td>
              <td class="num">${f:mt(l.produto.preco)}</td>
              <td class="num">
                <form method="post" action="${ctx}/carrinho/actualizar" class="form-linha">
                  <input type="hidden" name="produtoId" value="${l.produto.id}">
                  <input type="number" name="quantidade" value="${l.quantidade}" min="1" required
                         aria-label="Quantidade de ${fn:escapeXml(l.produto.nome)}">
                  <button type="submit" class="botao botao-pequeno">Actualizar</button>
                </form>
              </td>
              <td class="num">${f:mt(l.subtotal)}</td>
              <td>
                <form method="post" action="${ctx}/carrinho/remover">
                  <input type="hidden" name="produtoId" value="${l.produto.id}">
                  <button type="submit" class="botao botao-pequeno botao-perigo">Remover</button>
                </form>
              </td>
            </tr>
          </c:forEach>
        </tbody>
        <tfoot>
          <tr><th colspan="3" class="num">Subtotal</th><td class="num">${f:mt(resumo.subtotal)}</td><td></td></tr>
          <tr><th colspan="3" class="num">IVA (16%)</th><td class="num">${f:mt(resumo.iva)}</td><td></td></tr>
          <tr class="linha-total"><th colspan="3" class="num">Total</th><td class="num">${f:mt(resumo.total)}</td><td></td></tr>
        </tfoot>
      </table>
    </div>

    <div class="accoes">
      <form method="post" action="${ctx}/carrinho/esvaziar">
        <button type="submit" class="botao botao-secundario">Esvaziar carrinho</button>
      </form>
      <a class="botao botao-secundario" href="${ctx}/catalogo">Continuar a comprar</a>
      <a class="botao botao-primario" href="${ctx}/compra">Finalizar compra</a>
    </div>
  </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
