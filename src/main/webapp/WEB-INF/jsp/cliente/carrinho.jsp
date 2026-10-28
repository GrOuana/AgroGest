<c:set var="titulo" value="Carrinho"/>
<c:set var="menu" value="carrinho"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<header class="page__header">
  <div class="page__heading">
    <h1 class="page__title">Carrinho</h1>
    <p class="page__subtitle">Os totais são recalculados pelo servidor a cada alteração.</p>
  </div>
</header>

<c:choose>
  <c:when test="${resumo.vazio}">
    <section class="card card--empty">
      <p class="empty-state">O seu carrinho está vazio.</p>
      <a class="btn btn--primary" href="${ctx}/catalogo">Ver catálogo</a>
    </section>
  </c:when>
  <c:otherwise>
    <c:if test="${!resumo.stockSuficiente}">
      <div class="alert alert--warning" role="alert">
        <p>Alguns produtos já não têm stock suficiente. Ajuste as quantidades assinaladas.</p>
      </div>
    </c:if>

    <section class="card" aria-labelledby="carrinho-titulo">
      <h2 class="visually-hidden" id="carrinho-titulo">Produtos no carrinho</h2>
      <div class="table-wrap">
        <table class="table">
          <caption class="table__caption">Preços em Meticais. IVA de 16% sobre o subtotal.</caption>
          <thead>
            <tr>
              <th scope="col" class="table__th">Produto</th>
              <th scope="col" class="table__th table__th--num">Preço unit.</th>
              <th scope="col" class="table__th">Quantidade</th>
              <th scope="col" class="table__th table__th--num">Subtotal</th>
              <th scope="col" class="table__th"><span class="visually-hidden">Acções</span></th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="l" items="${resumo.linhas}">
              <tr class="table__row ${l.stockSuficiente ? '' : 'table__row--error'}">
                <th scope="row" class="table__td">
                  <span class="table__strong"><c:out value="${l.produto.nome}"/></span>
                  <span class="table__sub">Disponível: ${l.produto.quantidade} <c:out value="${l.produto.unidade}"/></span>
                </th>
                <td class="table__td table__td--num">${f:mt(l.produto.preco)}</td>
                <td class="table__td table__td--nowrap">
                  <form method="post" action="${ctx}/carrinho/actualizar" class="inline-form inline-form--nowrap">
                    <input type="hidden" name="produtoId" value="${l.produto.id}">
                    <label class="visually-hidden" for="qtd-linha-${l.produto.id}">Quantidade de <c:out value="${l.produto.nome}"/></label>
                    <input class="form__input inline-form__input" id="qtd-linha-${l.produto.id}" type="number"
                           name="quantidade" value="${l.quantidade}" min="1" step="1" required inputmode="numeric">
                    <button type="submit" class="btn btn--secondary btn--sm">Actualizar</button>
                  </form>
                </td>
                <td class="table__td table__td--num">${f:mt(l.subtotal)}</td>
                <td class="table__td table__td--nowrap">
                  <form method="post" action="${ctx}/carrinho/remover" class="inline-form">
                    <input type="hidden" name="produtoId" value="${l.produto.id}">
                    <button type="submit" class="btn btn--danger btn--sm">
                      Remover<span class="visually-hidden"> <c:out value="${l.produto.nome}"/></span>
                    </button>
                  </form>
                </td>
              </tr>
            </c:forEach>
          </tbody>
          <tfoot>
            <tr class="table__row table__row--foot"><th scope="row" colspan="3" class="table__th table__th--num">Subtotal</th><td class="table__td table__td--num">${f:mt(resumo.subtotal)}</td><td class="table__td"></td></tr>
            <tr class="table__row table__row--foot"><th scope="row" colspan="3" class="table__th table__th--num">IVA (16%)</th><td class="table__td table__td--num">${f:mt(resumo.iva)}</td><td class="table__td"></td></tr>
            <tr class="table__row table__row--foot table__row--total"><th scope="row" colspan="3" class="table__th table__th--num">Total</th><td class="table__td table__td--num">${f:mt(resumo.total)}</td><td class="table__td"></td></tr>
          </tfoot>
        </table>
      </div>

      <div class="card__footer">
        <form method="post" action="${ctx}/carrinho/esvaziar">
          <button type="submit" class="btn btn--ghost">Esvaziar carrinho</button>
        </form>
        <a class="btn btn--secondary" href="${ctx}/catalogo">Continuar a comprar</a>
        <a class="btn btn--primary" href="${ctx}/compra">Finalizar compra</a>
      </div>
    </section>
  </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
