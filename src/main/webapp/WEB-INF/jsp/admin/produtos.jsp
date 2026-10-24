<c:set var="titulo" value="Produtos"/>
<c:set var="menu" value="produtos"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<div class="cabecalho-pagina">
  <h1>Produtos</h1>
  <p class="subtitulo">Criar, actualizar, repor stock e remover produtos do catálogo.</p>
</div>

<%-- Formulário: edição se houver produtoEditar, criação caso contrário.
     Depois de um erro, os campos mostram o que foi escrito (param). --%>
<c:set var="pe" value="${produtoEditar}"/>
<c:set var="usarParam" value="${emEdicao || (pe == null && param.accao == 'criar')}"/>
<c:set var="vNome" value="${usarParam ? param.nome : pe.nome}"/>
<c:set var="vCategoria" value="${usarParam ? param.categoria : pe.categoria}"/>
<c:set var="vFornecedor" value="${usarParam ? param.fornecedorId : pe.fornecedorId}"/>
<c:set var="vPreco" value="${usarParam ? param.preco : pe.preco}"/>
<c:set var="vQuantidade" value="${usarParam ? param.quantidade : pe.quantidade}"/>
<c:set var="vUnidade" value="${usarParam ? param.unidade : pe.unidade}"/>
<c:set var="vDescricao" value="${usarParam ? param.descricao : pe.descricao}"/>
<c:set var="vFoto" value="${usarParam ? param.fotoUrl : pe.fotoUrl}"/>
<c:set var="vValidade" value="${usarParam ? param.validade : f:iso(pe.validade)}"/>

<section class="cartao" id="formulario">
  <c:choose>
    <c:when test="${pe != null}"><h2>Editar produto #${pe.id}: <c:out value="${pe.nome}"/></h2></c:when>
    <c:otherwise><h2>Novo produto</h2></c:otherwise>
  </c:choose>

  <c:if test="${empty fornecedores}">
    <p class="aviso aviso-erro">Crie primeiro um <a href="${ctx}/admin/fornecedores">fornecedor</a>: cada produto pertence a um.</p>
  </c:if>

  <form method="post" action="${ctx}/admin/produtos" class="formulario">
    <input type="hidden" name="accao" value="${pe != null ? 'actualizar' : 'criar'}">
    <c:if test="${pe != null}"><input type="hidden" name="id" value="${pe.id}"></c:if>

    <div class="grelha-3">
      <label>Nome
        <input type="text" name="nome" required maxlength="200" placeholder="Semente Feijão nhemba"
               value="${fn:escapeXml(vNome)}">
      </label>
      <label>Categoria
        <select name="categoria" required>
          <option value="">— escolher —</option>
          <c:forEach var="cat" items="${categorias}">
            <option value="${cat}" ${cat.name() == vCategoria ? 'selected' : ''}>${cat.descricao}</option>
          </c:forEach>
        </select>
      </label>
      <label>Fornecedor
        <select name="fornecedorId" required>
          <option value="">— escolher —</option>
          <c:forEach var="fo" items="${fornecedores}">
            <option value="${fo.id}" ${vFornecedor == fo.id ? 'selected' : ''}><c:out value="${fo.nome}"/></option>
          </c:forEach>
        </select>
      </label>
      <label>Preço (MT)
        <input type="number" name="preco" required min="0.01" step="0.01" placeholder="320"
               value="${fn:escapeXml(vPreco)}">
      </label>
      <label>Quantidade em stock
        <input type="number" name="quantidade" required min="0" step="1" placeholder="400"
               value="${fn:escapeXml(vQuantidade)}">
      </label>
      <label>Unidade
        <input type="text" name="unidade" required maxlength="30" placeholder="kg, saco, unidade, litro" list="unidades"
               value="${fn:escapeXml(vUnidade)}">
        <datalist id="unidades">
          <option value="kg"><option value="saco"><option value="unidade"><option value="litro"><option value="caixa">
        </datalist>
      </label>
      <label>Validade <small>(opcional)</small>
        <input type="date" name="validade" value="${fn:escapeXml(vValidade)}">
      </label>
      <label class="coluna-2">Foto (URL) <small>(opcional — ex.: img/produtos/feijao.svg ou https://…)</small>
        <input type="text" name="fotoUrl" maxlength="500" value="${fn:escapeXml(vFoto)}">
      </label>
    </div>
    <label>Descrição
      <textarea name="descricao" rows="2" maxlength="500"><c:out value="${vDescricao}"/></textarea>
    </label>

    <div class="accoes">
      <c:if test="${pe != null}"><a class="botao botao-secundario" href="${ctx}/admin/produtos">Cancelar</a></c:if>
      <button type="submit" class="botao botao-primario">${pe != null ? 'Guardar alterações' : 'Criar produto'}</button>
    </div>
  </form>
</section>

<section class="cartao">
  <h2>Produtos <small>(${fn:length(produtos)})</small></h2>
  <c:choose>
    <c:when test="${empty produtos}"><p class="vazio">Ainda não há produtos.</p></c:when>
    <c:otherwise>
      <div class="tabela-envolvente">
        <table class="tabela">
          <thead>
            <tr><th></th><th>Produto</th><th>Fornecedor</th><th class="num">Preço</th><th class="num">Stock</th>
                <th>Validade</th><th>Repor stock</th><th></th></tr>
          </thead>
          <tbody>
            <c:forEach var="p" items="${produtos}">
              <tr id="produto-${p.id}">
                <td><img class="miniatura" src="${fn:escapeXml(f:foto(ctx, p.fotoUrl))}" alt=""></td>
                <td><strong><c:out value="${p.nome}"/></strong><br><span class="etiqueta etiqueta-${fn:toLowerCase(p.categoria)}">${p.categoria.descricao}</span></td>
                <td><c:out value="${p.fornecedorNome}"/></td>
                <td class="num">${f:mt(p.preco)}<br><small>/ <c:out value="${p.unidade}"/></small></td>
                <td class="num ${p.quantidade == 0 ? 'texto-erro' : (p.quantidade < 10 ? 'texto-aviso' : '')}">${p.quantidade}</td>
                <td>
                  <c:choose>
                    <c:when test="${p.validade == null}">—</c:when>
                    <c:when test="${p.expirado}"><span class="texto-erro">${f:data(p.validade)}</span></c:when>
                    <c:otherwise>${f:data(p.validade)}</c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <form method="post" action="${ctx}/admin/produtos" class="form-linha">
                    <input type="hidden" name="accao" value="repor">
                    <input type="hidden" name="id" value="${p.id}">
                    <input type="number" name="quantidade" min="1" step="1" required placeholder="+ qtd"
                           aria-label="Quantidade a repor de ${fn:escapeXml(p.nome)}">
                    <button type="submit" class="botao botao-pequeno">Repor</button>
                  </form>
                </td>
                <td class="celula-accoes">
                  <a class="botao botao-pequeno botao-secundario" href="${ctx}/admin/produtos?editar=${p.id}#formulario">Editar</a>
                  <details class="confirmar">
                    <summary class="botao botao-pequeno botao-perigo">Remover</summary>
                    <form method="post" action="${ctx}/admin/produtos">
                      <input type="hidden" name="accao" value="remover">
                      <input type="hidden" name="id" value="${p.id}">
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
