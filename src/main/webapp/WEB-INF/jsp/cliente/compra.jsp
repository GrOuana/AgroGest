<c:set var="titulo" value="Confirmar compra"/>
<c:set var="menu" value="carrinho"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<div class="cabecalho-pagina">
  <h1>Confirmar compra</h1>
  <p class="subtitulo">Verifique os dados antes de confirmar. O stock é descontado no momento da confirmação.</p>
</div>

<div class="grelha-confirmar">
  <section class="cartao">
    <h2>Dados do cliente</h2>
    <dl class="dados">
      <dt>Nome</dt><dd><c:out value="${cliente.nome}"/></dd>
      <dt>Email</dt><dd><c:out value="${cliente.email}"/></dd>
      <dt>Telefone</dt><dd><c:out value="${cliente.telefone}"/></dd>
      <dt>Endereço</dt><dd><c:out value="${cliente.endereco}"/></dd>
    </dl>
  </section>

  <section class="cartao">
    <h2>Resumo</h2>
    <div class="tabela-envolvente">
      <table class="tabela">
        <thead>
          <tr><th>Produto</th><th class="num">Qtd.</th><th class="num">Preço unit.</th><th class="num">Subtotal</th></tr>
        </thead>
        <tbody>
          <c:forEach var="l" items="${resumo.linhas}">
            <tr class="${l.stockSuficiente ? '' : 'linha-erro'}">
              <td><c:out value="${l.produto.nome}"/>
                <c:if test="${!l.stockSuficiente}"><br><small class="texto-erro">Disponível só ${l.produto.quantidade}</small></c:if>
              </td>
              <td class="num">${l.quantidade} <c:out value="${l.produto.unidade}"/></td>
              <td class="num">${f:mt(l.produto.preco)}</td>
              <td class="num">${f:mt(l.subtotal)}</td>
            </tr>
          </c:forEach>
        </tbody>
        <tfoot>
          <tr><th colspan="3" class="num">Subtotal</th><td class="num">${f:mt(resumo.subtotal)}</td></tr>
          <tr><th colspan="3" class="num">IVA (16%)</th><td class="num">${f:mt(resumo.iva)}</td></tr>
          <tr class="linha-total"><th colspan="3" class="num">Total a pagar</th><td class="num">${f:mt(resumo.total)}</td></tr>
        </tfoot>
      </table>
    </div>
  </section>
</div>

<div class="accoes">
  <a class="botao botao-secundario" href="${ctx}/carrinho">Voltar ao carrinho</a>
  <form method="post" action="${ctx}/compra">
    <button type="submit" class="botao botao-primario">Confirmar compra</button>
  </form>
</div>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
