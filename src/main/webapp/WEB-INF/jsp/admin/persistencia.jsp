<c:set var="titulo" value="Persistência"/>
<c:set var="menu" value="persistencia"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<header class="page__header">
  <div class="page__heading">
    <h1 class="page__title">Persistência em ficheiro</h1>
    <p class="page__subtitle">Gravado ao encerrar o Tomcat e de 5 em 5 minutos; reposto no arranque.</p>
  </div>
</header>

<section class="card" aria-labelledby="estado-ficheiro">
  <header class="card__header"><h2 class="card__title" id="estado-ficheiro">Estado</h2></header>
  <dl class="facts">
    <dt class="facts__term">Ficheiro</dt><dd class="facts__detail"><code><c:out value="${persistencia.ficheiro}"/></code></dd>
    <dt class="facts__term">Existe</dt>
    <dd class="facts__detail">
      <c:choose>
        <c:when test="${persistencia.ficheiroExiste}"><span class="tag tag--success">Sim</span> ${persistencia.tamanho} bytes · modificado em ${f:dataHora(persistencia.modificado)}</c:when>
        <c:otherwise><span class="tag">Não</span></c:otherwise>
      </c:choose>
    </dd>
    <dt class="facts__term">Última gravação</dt><dd class="facts__detail">${persistencia.ultimaGravacao == null ? 'ainda não gravado nesta execução' : f:dataHora(persistencia.ultimaGravacao)}</dd>
    <dt class="facts__term">No arranque</dt><dd class="facts__detail"><c:out value="${persistencia.estadoArranque}"/></dd>
  </dl>
</section>

<div class="columns columns--3">
  <section class="card" aria-labelledby="acc-gravar">
    <h2 class="card__title" id="acc-gravar">Gravar agora</h2>
    <p class="card__text">Grava o estado completo em <code>dados.ser</code>: ficheiro temporário + ATOMIC_MOVE; a versão anterior fica em <code>dados.ser.bak</code>.</p>
    <form method="post" action="${ctx}/admin/persistencia">
      <input type="hidden" name="accao" value="gravar">
      <button type="submit" class="btn btn--primary">Gravar agora</button>
    </form>
  </section>

  <section class="card" aria-labelledby="acc-eliminar">
    <h2 class="card__title" id="acc-eliminar">Eliminar ficheiro</h2>
    <p class="card__text">Apaga <code>dados.ser</code> e a cópia. Os dados em memória continuam e voltam a ser gravados ao encerrar.</p>
    <details class="confirm">
      <summary class="confirm__toggle btn btn--danger">Eliminar ficheiro</summary>
      <form method="post" action="${ctx}/admin/persistencia" class="confirm__panel">
        <p class="confirm__text">Eliminar o ficheiro de dados?</p>
        <input type="hidden" name="accao" value="eliminar">
        <button type="submit" class="btn btn--danger btn--sm">Confirmar eliminação</button>
      </form>
    </details>
  </section>

  <section class="card" aria-labelledby="acc-repor">
    <h2 class="card__title" id="acc-repor">Repor demonstração</h2>
    <p class="card__text">Apaga tudo da memória e carrega os dados de demonstração (3 fornecedores, 3 produtos, 5 clientes, 4 vendas, 1 campanha).</p>
    <details class="confirm">
      <summary class="confirm__toggle btn btn--danger">Repor dados</summary>
      <form method="post" action="${ctx}/admin/persistencia" class="confirm__panel">
        <p class="confirm__text">Apagar todos os dados actuais?</p>
        <input type="hidden" name="accao" value="repor">
        <button type="submit" class="btn btn--danger btn--sm">Confirmar reposição</button>
      </form>
    </details>
  </section>
</div>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
