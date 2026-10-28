<c:set var="titulo" value="Confirmar compra"/>
<c:set var="menu" value="carrinho"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<header class="page__header">
  <div class="page__heading">
    <h1 class="page__title">Confirmar compra</h1>
    <p class="page__subtitle">Verifique os dados. O stock só é descontado quando confirmar.</p>
  </div>
</header>

<div class="columns columns--sidebar">
  <section class="card" aria-labelledby="dados-cliente">
    <header class="card__header"><h2 class="card__title" id="dados-cliente">Dados do cliente</h2></header>
    <dl class="facts">
      <dt class="facts__term">Nome</dt><dd class="facts__detail"><c:out value="${cliente.nome}"/></dd>
      <dt class="facts__term">Email</dt><dd class="facts__detail"><c:out value="${cliente.email}"/></dd>
      <dt class="facts__term">Telefone</dt><dd class="facts__detail">${fn:escapeXml(f:telefone(cliente.telefone))}</dd>
      <dt class="facts__term">Endereço</dt><dd class="facts__detail"><c:out value="${cliente.endereco}"/></dd>
    </dl>
  </section>

  <section class="card" aria-labelledby="resumo-compra">
    <header class="card__header"><h2 class="card__title" id="resumo-compra">Resumo</h2></header>
    <div class="table-wrap">
      <table class="table">
        <thead>
          <tr>
            <th scope="col" class="table__th">Produto</th>
            <th scope="col" class="table__th table__th--num">Qtd.</th>
            <th scope="col" class="table__th table__th--num">Preço unit.</th>
            <th scope="col" class="table__th table__th--num">Subtotal</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="l" items="${resumo.linhas}">
            <tr class="table__row ${l.stockSuficiente ? '' : 'table__row--error'}">
              <th scope="row" class="table__td">
                <span class="table__strong"><c:out value="${l.produto.nome}"/></span>
                <c:if test="${!l.stockSuficiente}"><span class="table__sub stock stock--out">Disponível só ${l.produto.quantidade}</span></c:if>
              </th>
              <td class="table__td table__td--num">${l.quantidade} <c:out value="${l.produto.unidade}"/></td>
              <td class="table__td table__td--num">${f:mt(l.produto.preco)}</td>
              <td class="table__td table__td--num">${f:mt(l.subtotal)}</td>
            </tr>
          </c:forEach>
        </tbody>
        <tfoot>
          <tr class="table__row table__row--foot"><th scope="row" colspan="3" class="table__th table__th--num">Subtotal</th><td class="table__td table__td--num">${f:mt(resumo.subtotal)}</td></tr>
          <tr class="table__row table__row--foot"><th scope="row" colspan="3" class="table__th table__th--num">IVA (16%)</th><td class="table__td table__td--num">${f:mt(resumo.iva)}</td></tr>
          <tr class="table__row table__row--foot table__row--total"><th scope="row" colspan="3" class="table__th table__th--num">Total a pagar</th><td class="table__td table__td--num">${f:mt(resumo.total)}</td></tr>
        </tfoot>
      </table>
    </div>
    <div class="card__footer">
      <a class="btn btn--secondary" href="${ctx}/carrinho">Voltar ao carrinho</a>
      <form method="post" action="${ctx}/compra">
        <button type="submit" class="btn btn--primary">Confirmar compra</button>
      </form>
    </div>
  </section>
</div>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
