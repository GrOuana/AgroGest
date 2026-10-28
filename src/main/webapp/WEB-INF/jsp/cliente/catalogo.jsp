<c:set var="titulo" value="Catálogo"/>
<c:set var="menu" value="catalogo"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<header class="page__header">
  <div class="page__heading">
    <h1 class="page__title">Catálogo</h1>
    <p class="page__subtitle">Sementes, fertilizantes, maquinaria e ferramentas em stock.</p>
  </div>
</header>

<nav aria-label="Filtrar por categoria">
  <ul class="filter-bar">
    <li><a class="filter-bar__chip ${categoriaActual == null ? 'filter-bar__chip--active' : ''}" href="${ctx}/catalogo"
           ${categoriaActual == null ? 'aria-current="true"' : ''}>Todas</a></li>
    <c:forEach var="cat" items="${categorias}">
      <li><a class="filter-bar__chip ${categoriaActual == cat ? 'filter-bar__chip--active' : ''}"
             href="${ctx}/catalogo?categoria=${cat}" ${categoriaActual == cat ? 'aria-current="true"' : ''}>${cat.descricao}</a></li>
    </c:forEach>
  </ul>
</nav>

<c:choose>
  <c:when test="${empty produtos}">
    <section class="card card--empty"><p class="empty-state">Não há produtos nesta categoria.</p></section>
  </c:when>
  <c:otherwise>
    <h2 class="visually-hidden">Produtos (${fn:length(produtos)})</h2>
    <ul class="product-grid">
      <c:forEach var="p" items="${produtos}">
        <c:set var="disponivel" value="${p.emStock && !p.expirado}"/>
        <li class="product-grid__item">
          <article class="product-card ${disponivel ? '' : 'product-card--unavailable'}" aria-labelledby="produto-${p.id}">
            <div class="product-card__media">
              <img class="product-card__img" src="${fn:escapeXml(f:foto(ctx, p.fotoUrl))}" alt="" loading="lazy"
                   width="400" height="300">
            </div>
            <div class="product-card__body">
              <p><span class="tag tag--${fn:toLowerCase(p.categoria)}">${p.categoria.descricao}</span></p>
              <h3 class="product-card__title" id="produto-${p.id}"><c:out value="${p.nome}"/></h3>
              <c:if test="${not empty p.descricao}">
                <p class="product-card__desc"><c:out value="${p.descricao}"/></p>
              </c:if>
              <dl class="product-card__facts">
                <dt class="product-card__term">Preço</dt>
                <dd class="product-card__detail">
                  <span class="product-card__price">${f:mt(p.preco)}</span>
                  <span class="product-card__unit">/ <c:out value="${p.unidade}"/></span>
                </dd>
                <dt class="product-card__term">Disponível</dt>
                <dd class="product-card__detail">
                  <c:choose>
                    <c:when test="${p.emStock}">${p.quantidade} <c:out value="${p.unidade}"/></c:when>
                    <c:otherwise><span class="stock stock--out">Esgotado</span></c:otherwise>
                  </c:choose>
                </dd>
                <dt class="product-card__term">Validade</dt>
                <dd class="product-card__detail">
                  <c:choose>
                    <c:when test="${p.validade == null}">Sem validade</c:when>
                    <c:when test="${p.expirado}"><span class="stock stock--out">Expirado em ${f:data(p.validade)}</span></c:when>
                    <c:otherwise><time datetime="${f:iso(p.validade)}">${f:data(p.validade)}</time></c:otherwise>
                  </c:choose>
                </dd>
                <dt class="product-card__term">Fornecedor</dt>
                <dd class="product-card__detail"><c:out value="${p.fornecedorNome}"/></dd>
              </dl>

              <c:if test="${u.cliente}">
                <c:choose>
                  <c:when test="${disponivel}">
                    <c:if test="${noCarrinho[p.id] != null}">
                      <p class="product-card__in-cart">No carrinho: ${noCarrinho[p.id]} <c:out value="${p.unidade}"/></p>
                    </c:if>
                    <form method="post" action="${ctx}/carrinho/adicionar" class="product-card__form">
                      <input type="hidden" name="produtoId" value="${p.id}">
                      <input type="hidden" name="categoria" value="${categoriaActual}">
                      <label class="visually-hidden" for="qtd-${p.id}">Quantidade de <c:out value="${p.nome}"/></label>
                      <input class="form__input product-card__qty" id="qtd-${p.id}" type="number" name="quantidade"
                             value="1" min="1" max="${p.quantidade}" step="1" required inputmode="numeric"
                             title="Um número inteiro entre 1 e ${p.quantidade}">
                      <button type="submit" class="btn btn--primary">Adicionar</button>
                    </form>
                  </c:when>
                  <c:otherwise>
                    <p class="product-card__status">Indisponível para compra</p>
                  </c:otherwise>
                </c:choose>
              </c:if>
            </div>
          </article>
        </li>
      </c:forEach>
    </ul>
  </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
