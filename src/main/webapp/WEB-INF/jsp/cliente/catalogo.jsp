<c:set var="titulo" value="Catálogo"/>
<c:set var="menu" value="catalogo"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<div class="cabecalho-pagina">
  <h1>Catálogo</h1>
  <p class="subtitulo">Sementes, fertilizantes, maquinaria e ferramentas em stock.</p>
</div>

<nav class="filtros" aria-label="Filtrar por categoria">
  <a href="${ctx}/catalogo" class="filtro ${categoriaActual == null ? 'activo' : ''}">Todas</a>
  <c:forEach var="cat" items="${categorias}">
    <a href="${ctx}/catalogo?categoria=${cat}" class="filtro ${categoriaActual == cat ? 'activo' : ''}">${cat.descricao}</a>
  </c:forEach>
</nav>

<c:if test="${empty produtos}">
  <p class="vazio">Não há produtos nesta categoria.</p>
</c:if>

<div class="grelha-produtos">
  <c:forEach var="p" items="${produtos}">
    <article class="produto ${p.emStock && !p.expirado ? '' : 'produto-indisponivel'}">
      <img class="produto-foto" src="${fn:escapeXml(f:foto(ctx, p.fotoUrl))}" alt="${fn:escapeXml(p.nome)}" loading="lazy">
      <div class="produto-corpo">
        <span class="etiqueta etiqueta-${fn:toLowerCase(p.categoria)}">${p.categoria.descricao}</span>
        <h2><c:out value="${p.nome}"/></h2>
        <p class="produto-descricao"><c:out value="${p.descricao}"/></p>
        <dl class="produto-dados">
          <dt>Preço</dt><dd class="preco">${f:mt(p.preco)} <small>/ <c:out value="${p.unidade}"/></small></dd>
          <dt>Disponível</dt>
          <dd>
            <c:choose>
              <c:when test="${p.emStock}">${p.quantidade} <c:out value="${p.unidade}"/></c:when>
              <c:otherwise><span class="texto-erro">Esgotado</span></c:otherwise>
            </c:choose>
          </dd>
          <dt>Validade</dt>
          <dd>
            <c:choose>
              <c:when test="${p.validade == null}">—</c:when>
              <c:when test="${p.expirado}"><span class="texto-erro">Expirado (${f:data(p.validade)})</span></c:when>
              <c:otherwise>${f:data(p.validade)}</c:otherwise>
            </c:choose>
          </dd>
          <dt>Fornecedor</dt><dd><c:out value="${p.fornecedorNome}"/></dd>
        </dl>

        <c:if test="${u.cliente}">
          <c:choose>
            <c:when test="${p.emStock && !p.expirado}">
              <form method="post" action="${ctx}/carrinho/adicionar" class="form-adicionar">
                <input type="hidden" name="produtoId" value="${p.id}">
                <input type="hidden" name="categoria" value="${categoriaActual}">
                <label class="sr-only" for="qtd-${p.id}">Quantidade</label>
                <input id="qtd-${p.id}" type="number" name="quantidade" value="1" min="1" max="${p.quantidade}" required>
                <button type="submit" class="botao botao-primario">Adicionar</button>
              </form>
              <c:if test="${noCarrinho[p.id] != null}">
                <p class="no-carrinho">No carrinho: ${noCarrinho[p.id]} <c:out value="${p.unidade}"/></p>
              </c:if>
            </c:when>
            <c:otherwise>
              <p class="indisponivel">Indisponível para compra</p>
            </c:otherwise>
          </c:choose>
        </c:if>
      </div>
    </article>
  </c:forEach>
</div>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
