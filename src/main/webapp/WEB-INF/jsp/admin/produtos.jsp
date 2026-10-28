<c:set var="titulo" value="Produtos"/>
<c:set var="menu" value="produtos"/>
<%-- Erros por campo só no formulário principal: um erro na linha "repor stock"
     não deve marcar o campo Quantidade do formulário de criação. --%>
<c:set var="ec" value="${param.accao == 'criar' || param.accao == 'actualizar' ? erroCampo : ''}"/>
<c:set var="erroCampo" value="${ec}"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

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

<header class="page__header">
  <div class="page__heading">
    <h1 class="page__title">Produtos</h1>
    <p class="page__subtitle">Criar, actualizar, repor stock e remover produtos do catálogo.</p>
  </div>
</header>

<section class="card" id="formulario" aria-labelledby="form-produto-titulo">
  <header class="card__header">
    <h2 class="card__title" id="form-produto-titulo">
      <c:choose>
        <c:when test="${pe != null}">Editar produto #${pe.id}: <c:out value="${pe.nome}"/></c:when>
        <c:otherwise>Novo produto</c:otherwise>
      </c:choose>
    </h2>
  </header>

  <c:if test="${empty fornecedores}">
    <div class="alert alert--warning" role="status">
      <p>Crie primeiro um <a href="${ctx}/admin/fornecedores">fornecedor</a>: cada produto pertence a um.</p>
    </div>
  </c:if>

  <form method="post" action="${ctx}/admin/produtos" class="form">
    <input type="hidden" name="accao" value="${pe != null ? 'actualizar' : 'criar'}">
    <c:if test="${pe != null}"><input type="hidden" name="id" value="${pe.id}"></c:if>

    <div class="form__grid form__grid--3">
      <div class="form__field">
        <label class="form__label" for="campo-nome">Nome</label>
        <input class="form__input ${ec == 'nome' ? 'form__input--invalid' : ''}" id="campo-nome" type="text" name="nome"
               required minlength="2" maxlength="120" placeholder="Semente Feijão nhemba"
               aria-invalid="${ec == 'nome'}" aria-describedby="${ec == 'nome' ? 'erro-nome' : ''}"
               value="${fn:escapeXml(vNome)}">
        <c:set var="campo" value="nome"/><%@ include file="/WEB-INF/jsp/comum/erro-campo.jspf" %>
      </div>
      <div class="form__field">
        <label class="form__label" for="campo-categoria">Categoria</label>
        <select class="form__input ${ec == 'categoria' ? 'form__input--invalid' : ''}" id="campo-categoria" name="categoria" required
                aria-invalid="${ec == 'categoria'}">
          <option value="">— escolher —</option>
          <c:forEach var="cat" items="${categorias}">
            <option value="${cat}" ${cat.name() == vCategoria ? 'selected' : ''}>${cat.descricao}</option>
          </c:forEach>
        </select>
        <c:set var="campo" value="categoria"/><%@ include file="/WEB-INF/jsp/comum/erro-campo.jspf" %>
      </div>
      <div class="form__field">
        <label class="form__label" for="campo-fornecedorId">Fornecedor</label>
        <select class="form__input ${ec == 'fornecedorId' ? 'form__input--invalid' : ''}" id="campo-fornecedorId" name="fornecedorId" required
                aria-invalid="${ec == 'fornecedorId'}">
          <option value="">— escolher —</option>
          <c:forEach var="fo" items="${fornecedores}">
            <option value="${fo.id}" ${vFornecedor == fo.id ? 'selected' : ''}><c:out value="${fo.nome}"/></option>
          </c:forEach>
        </select>
        <c:set var="campo" value="fornecedorId"/><%@ include file="/WEB-INF/jsp/comum/erro-campo.jspf" %>
      </div>
      <div class="form__field">
        <label class="form__label" for="campo-preco">Preço (MT)</label>
        <input class="form__input ${ec == 'preco' ? 'form__input--invalid' : ''}" id="campo-preco" type="number" name="preco"
               required min="0.01" max="100000000" step="0.01" inputmode="decimal" placeholder="320.00"
               title="Valor em Meticais, maior que zero, com até 2 casas decimais"
               aria-invalid="${ec == 'preco'}" aria-describedby="ajuda-preco${ec == 'preco' ? ' erro-preco' : ''}"
               value="${fn:escapeXml(vPreco)}">
        <p class="form__hint" id="ajuda-preco">Maior que zero, até 2 casas decimais.</p>
        <c:set var="campo" value="preco"/><%@ include file="/WEB-INF/jsp/comum/erro-campo.jspf" %>
      </div>
      <div class="form__field">
        <label class="form__label" for="campo-quantidade">Quantidade em stock</label>
        <input class="form__input ${ec == 'quantidade' ? 'form__input--invalid' : ''}" id="campo-quantidade" type="number" name="quantidade"
               required min="0" max="1000000" step="1" inputmode="numeric" placeholder="400"
               title="Número inteiro, zero ou mais"
               aria-invalid="${ec == 'quantidade'}" aria-describedby="ajuda-quantidade${ec == 'quantidade' ? ' erro-quantidade' : ''}"
               value="${fn:escapeXml(vQuantidade)}">
        <p class="form__hint" id="ajuda-quantidade">Número inteiro (0 ou mais).</p>
        <c:set var="campo" value="quantidade"/><%@ include file="/WEB-INF/jsp/comum/erro-campo.jspf" %>
      </div>
      <div class="form__field">
        <label class="form__label" for="campo-unidade">Unidade</label>
        <input class="form__input ${ec == 'unidade' ? 'form__input--invalid' : ''}" id="campo-unidade" type="text" name="unidade"
               required maxlength="20" placeholder="kg" list="unidades"
               pattern="^[A-Za-zÀ-ÖØ-öø-ÿ]{1,20}$" title="Só letras: kg, saco, unidade, litro…"
               aria-invalid="${ec == 'unidade'}" aria-describedby="ajuda-unidade${ec == 'unidade' ? ' erro-unidade' : ''}"
               value="${fn:escapeXml(vUnidade)}">
        <datalist id="unidades">
          <option value="kg"><option value="saco"><option value="unidade"><option value="litro"><option value="caixa">
        </datalist>
        <p class="form__hint" id="ajuda-unidade">Só letras: kg, saco, unidade, litro.</p>
        <c:set var="campo" value="unidade"/><%@ include file="/WEB-INF/jsp/comum/erro-campo.jspf" %>
      </div>
      <div class="form__field">
        <label class="form__label" for="campo-validade">Validade<span class="form__optional">(opcional)</span></label>
        <input class="form__input ${ec == 'validade' ? 'form__input--invalid' : ''}" id="campo-validade" type="date" name="validade"
               aria-invalid="${ec == 'validade'}" aria-describedby="${ec == 'validade' ? 'erro-validade' : ''}"
               value="${fn:escapeXml(vValidade)}">
        <c:set var="campo" value="validade"/><%@ include file="/WEB-INF/jsp/comum/erro-campo.jspf" %>
      </div>
      <div class="form__field form__field--wide">
        <label class="form__label" for="campo-fotoUrl">Foto (URL)<span class="form__optional">(opcional)</span></label>
        <input class="form__input ${ec == 'fotoUrl' ? 'form__input--invalid' : ''}" id="campo-fotoUrl" type="text" name="fotoUrl"
               maxlength="500" placeholder="img/produtos/feijao.svg"
               pattern="^(https?:\/\/\S+|img\/[\w.\/\-]+)$" title="Endereço https://… ou caminho img/… da aplicação"
               aria-invalid="${ec == 'fotoUrl'}" aria-describedby="ajuda-fotoUrl${ec == 'fotoUrl' ? ' erro-fotoUrl' : ''}"
               value="${fn:escapeXml(vFoto)}">
        <p class="form__hint" id="ajuda-fotoUrl">Endereço https://… ou uma imagem da aplicação, como img/produtos/feijao.svg.</p>
        <c:set var="campo" value="fotoUrl"/><%@ include file="/WEB-INF/jsp/comum/erro-campo.jspf" %>
      </div>
    </div>
    <div class="form__field">
      <label class="form__label" for="campo-descricao">Descrição<span class="form__optional">(opcional)</span></label>
      <textarea class="form__input" id="campo-descricao" name="descricao" rows="2" maxlength="500"><c:out value="${vDescricao}"/></textarea>
    </div>

    <div class="form__actions">
      <c:if test="${pe != null}"><a class="btn btn--secondary" href="${ctx}/admin/produtos">Cancelar</a></c:if>
      <button type="submit" class="btn btn--primary">${pe != null ? 'Guardar alterações' : 'Criar produto'}</button>
    </div>
  </form>
</section>

<section class="card" aria-labelledby="lista-produtos">
  <header class="card__header">
    <h2 class="card__title" id="lista-produtos">Produtos <span class="card__title-meta">(${fn:length(produtos)})</span></h2>
  </header>
  <c:choose>
    <c:when test="${empty produtos}"><p class="empty-state">Ainda não há produtos.</p></c:when>
    <c:otherwise>
      <div class="table-wrap">
        <table class="table">
          <thead>
            <tr>
              <th scope="col" class="table__th"><span class="visually-hidden">Foto</span></th>
              <th scope="col" class="table__th">Produto</th>
              <th scope="col" class="table__th">Fornecedor</th>
              <th scope="col" class="table__th table__th--num">Preço</th>
              <th scope="col" class="table__th table__th--num">Stock</th>
              <th scope="col" class="table__th">Validade</th>
              <th scope="col" class="table__th">Repor stock</th>
              <th scope="col" class="table__th"><span class="visually-hidden">Acções</span></th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="p" items="${produtos}">
              <tr class="table__row" id="produto-${p.id}">
                <td class="table__td"><img class="thumb" src="${fn:escapeXml(f:foto(ctx, p.fotoUrl))}" alt="" width="44" height="44" loading="lazy"></td>
                <th scope="row" class="table__td">
                  <span class="table__strong"><c:out value="${p.nome}"/></span>
                  <span class="tag tag--${fn:toLowerCase(p.categoria)}">${p.categoria.descricao}</span>
                </th>
                <td class="table__td"><c:out value="${p.fornecedorNome}"/></td>
                <td class="table__td table__td--num">${f:mt(p.preco)}<span class="table__sub">/ <c:out value="${p.unidade}"/></span></td>
                <td class="table__td table__td--num ${p.quantidade == 0 ? 'stock stock--out' : (p.quantidade < 10 ? 'stock stock--low' : '')}">${p.quantidade}</td>
                <td class="table__td table__td--nowrap">
                  <c:choose>
                    <c:when test="${p.validade == null}">—</c:when>
                    <c:when test="${p.expirado}"><span class="stock stock--out">${f:data(p.validade)}</span></c:when>
                    <c:otherwise>${f:data(p.validade)}</c:otherwise>
                  </c:choose>
                </td>
                <td class="table__td table__td--nowrap">
                  <form method="post" action="${ctx}/admin/produtos" class="inline-form inline-form--nowrap">
                    <input type="hidden" name="accao" value="repor">
                    <input type="hidden" name="id" value="${p.id}">
                    <label class="visually-hidden" for="repor-${p.id}">Quantidade a repor de <c:out value="${p.nome}"/></label>
                    <input class="form__input inline-form__input" id="repor-${p.id}" type="number" name="quantidade"
                           min="1" max="1000000" step="1" required inputmode="numeric" placeholder="+ qtd"
                           title="Número inteiro maior que zero">
                    <button type="submit" class="btn btn--secondary btn--sm">Repor</button>
                  </form>
                </td>
                <td class="table__td table__td--nowrap">
                  <div class="actions actions--nowrap">
                    <a class="btn btn--secondary btn--sm" href="${ctx}/admin/produtos?editar=${p.id}#formulario">
                      Editar<span class="visually-hidden"> <c:out value="${p.nome}"/></span>
                    </a>
                    <details class="confirm">
                      <summary class="confirm__toggle btn btn--danger btn--sm">Remover<span class="visually-hidden"> <c:out value="${p.nome}"/></span></summary>
                      <form method="post" action="${ctx}/admin/produtos" class="confirm__panel">
                        <p class="confirm__text">Remover «<c:out value="${p.nome}"/>»? As facturas já emitidas não mudam.</p>
                        <input type="hidden" name="accao" value="remover">
                        <input type="hidden" name="id" value="${p.id}">
                        <button type="submit" class="btn btn--danger btn--sm">Confirmar remoção</button>
                      </form>
                    </details>
                  </div>
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
