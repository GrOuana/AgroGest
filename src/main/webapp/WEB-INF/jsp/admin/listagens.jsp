<c:set var="titulo" value="Listagens"/>
<c:set var="menu" value="listagens"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<div class="cabecalho-pagina">
  <h1>Listagens</h1>
  <p class="subtitulo">Clique no título de uma coluna para ordenar; clique outra vez para inverter.</p>
</div>

<nav class="filtros" aria-label="Tipo de listagem">
  <a class="filtro ${tipo == 'produtos' ? 'activo' : ''}" href="${ctx}/admin/listagens?tipo=produtos">Produtos</a>
  <a class="filtro ${tipo == 'fornecedores' ? 'activo' : ''}" href="${ctx}/admin/listagens?tipo=fornecedores">Fornecedores</a>
  <a class="filtro ${tipo == 'clientes' ? 'activo' : ''}" href="${ctx}/admin/listagens?tipo=clientes">Clientes</a>
  <a class="filtro ${tipo == 'armazem' ? 'activo' : ''}" href="${ctx}/admin/listagens?tipo=armazem">Armazém (stock &gt; 0)</a>
  <a class="filtro" href="${ctx}/admin/compras">Compras detalhadas</a>
</nav>

<c:set var="baseOrdenar" value="/admin/listagens?tipo=${tipo}&amp;"/>

<section class="cartao">
  <c:choose>
    <c:when test="${empty itens}"><p class="vazio">Sem registos.</p></c:when>

    <c:when test="${tipo == 'fornecedores'}">
      <div class="tabela-envolvente">
        <table class="tabela">
          <thead><tr>
            <c:set var="classeCol" value=""/>
            <c:set var="col" value="nome"/><c:set var="rotulo" value="Nome"/><%@ include file="/WEB-INF/jsp/comum/ordenar.jspf" %>
            <c:set var="col" value="tipo"/><c:set var="rotulo" value="Tipo"/><%@ include file="/WEB-INF/jsp/comum/ordenar.jspf" %>
            <th>Contacto</th>
            <c:set var="col" value="provincia"/><c:set var="rotulo" value="Província"/><%@ include file="/WEB-INF/jsp/comum/ordenar.jspf" %>
          </tr></thead>
          <tbody>
            <c:forEach var="fo" items="${itens}">
              <tr>
                <td><strong><c:out value="${fo.nome}"/></strong></td>
                <td>${fo.tipo.descricao}</td>
                <td><c:out value="${fo.contacto}"/></td>
                <td><c:out value="${fo.provincia}"/></td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </c:when>

    <c:when test="${tipo == 'clientes'}">
      <div class="tabela-envolvente">
        <table class="tabela">
          <thead><tr>
            <c:set var="classeCol" value=""/>
            <c:set var="col" value="nome"/><c:set var="rotulo" value="Nome"/><%@ include file="/WEB-INF/jsp/comum/ordenar.jspf" %>
            <th>Email</th><th>Telefone</th><th>Endereço</th>
            <c:set var="col" value="data"/><c:set var="rotulo" value="Registo"/><%@ include file="/WEB-INF/jsp/comum/ordenar.jspf" %>
            <c:set var="classeCol" value="num"/>
            <c:set var="col" value="compras"/><c:set var="rotulo" value="Compras"/><%@ include file="/WEB-INF/jsp/comum/ordenar.jspf" %>
            <c:set var="col" value="valor"/><c:set var="rotulo" value="Volume"/><%@ include file="/WEB-INF/jsp/comum/ordenar.jspf" %>
            <th>Conta</th>
          </tr></thead>
          <tbody>
            <c:forEach var="r" items="${itens}">
              <tr class="${r.cliente.ativo ? '' : 'linha-inactiva'}">
                <td><strong><c:out value="${r.cliente.nome}"/></strong></td>
                <td><c:out value="${r.cliente.email}"/></td>
                <td><c:out value="${r.cliente.telefone}"/></td>
                <td><c:out value="${r.cliente.endereco}"/></td>
                <td>${f:data(r.cliente.dataRegisto)}</td>
                <td class="num">${r.numeroCompras}</td>
                <td class="num">${f:mt(r.volume)}</td>
                <td>
                  <form method="post" action="${ctx}/admin/clientes">
                    <input type="hidden" name="id" value="${r.cliente.id}">
                    <button type="submit" class="botao botao-pequeno ${r.cliente.ativo ? 'botao-secundario' : 'botao-primario'}">
                      ${r.cliente.ativo ? 'Desactivar' : 'Activar'}
                    </button>
                  </form>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </c:when>

    <c:otherwise>
      <%-- produtos e armazém --%>
      <div class="tabela-envolvente">
        <table class="tabela">
          <thead><tr>
            <c:set var="classeCol" value=""/>
            <c:set var="col" value="nome"/><c:set var="rotulo" value="Produto"/><%@ include file="/WEB-INF/jsp/comum/ordenar.jspf" %>
            <th>Categoria</th>
            <c:set var="col" value="fornecedor"/><c:set var="rotulo" value="Fornecedor"/><%@ include file="/WEB-INF/jsp/comum/ordenar.jspf" %>
            <c:set var="classeCol" value="num"/>
            <c:set var="col" value="preco"/><c:set var="rotulo" value="Preço"/><%@ include file="/WEB-INF/jsp/comum/ordenar.jspf" %>
            <c:set var="col" value="stock"/><c:set var="rotulo" value="Stock"/><%@ include file="/WEB-INF/jsp/comum/ordenar.jspf" %>
            <c:choose>
              <c:when test="${tipo == 'armazem'}">
                <c:set var="col" value="valor"/><c:set var="rotulo" value="Valor em stock"/><%@ include file="/WEB-INF/jsp/comum/ordenar.jspf" %>
              </c:when>
              <c:otherwise>
                <c:set var="classeCol" value=""/>
                <c:set var="col" value="validade"/><c:set var="rotulo" value="Validade"/><%@ include file="/WEB-INF/jsp/comum/ordenar.jspf" %>
              </c:otherwise>
            </c:choose>
          </tr></thead>
          <tbody>
            <c:forEach var="p" items="${itens}">
              <tr>
                <td><strong><c:out value="${p.nome}"/></strong></td>
                <td>${p.categoria.descricao}</td>
                <td><c:out value="${p.fornecedorNome}"/></td>
                <td class="num">${f:mt(p.preco)}</td>
                <td class="num ${p.quantidade == 0 ? 'texto-erro' : ''}">${p.quantidade} <c:out value="${p.unidade}"/></td>
                <c:choose>
                  <c:when test="${tipo == 'armazem'}"><td class="num">${f:mt(p.valorEmStock)}</td></c:when>
                  <c:otherwise><td>${p.validade == null ? '—' : f:data(p.validade)}</td></c:otherwise>
                </c:choose>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </c:otherwise>
  </c:choose>
</section>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
