<c:set var="titulo" value="Persistência"/>
<c:set var="menu" value="persistencia"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<div class="cabecalho-pagina">
  <h1>Persistência em ficheiro</h1>
  <p class="subtitulo">O estado é gravado automaticamente ao encerrar o Tomcat, de 5 em 5 minutos, e reposto no arranque.</p>
</div>

<section class="cartao">
  <h2>Estado</h2>
  <dl class="dados">
    <dt>Ficheiro</dt><dd><code><c:out value="${persistencia.ficheiro}"/></code></dd>
    <dt>Existe</dt>
    <dd>
      <c:choose>
        <c:when test="${persistencia.ficheiroExiste}"><span class="etiqueta etiqueta-verde">Sim</span> ${persistencia.tamanho} bytes · modificado em ${f:dataHora(persistencia.modificado)}</c:when>
        <c:otherwise><span class="etiqueta etiqueta-cinza">Não</span></c:otherwise>
      </c:choose>
    </dd>
    <dt>Última gravação</dt><dd>${persistencia.ultimaGravacao == null ? 'ainda não gravado nesta execução' : f:dataHora(persistencia.ultimaGravacao)}</dd>
    <dt>No arranque</dt><dd><c:out value="${persistencia.estadoArranque}"/></dd>
  </dl>
</section>

<div class="grelha-3">
  <section class="cartao">
    <h2>Gravar agora</h2>
    <p>Grava o estado completo em <code>dados.ser</code> (escrita atómica: ficheiro temporário + ATOMIC_MOVE; a versão anterior fica em <code>dados.ser.bak</code>).</p>
    <form method="post" action="${ctx}/admin/persistencia">
      <input type="hidden" name="accao" value="gravar">
      <button type="submit" class="botao botao-primario">Gravar agora</button>
    </form>
  </section>

  <section class="cartao">
    <h2>Eliminar ficheiro</h2>
    <p>Apaga <code>dados.ser</code> e a cópia. Os dados em memória continuam e voltam a ser gravados ao encerrar.</p>
    <details class="confirmar">
      <summary class="botao botao-perigo">Eliminar ficheiro</summary>
      <form method="post" action="${ctx}/admin/persistencia">
        <input type="hidden" name="accao" value="eliminar">
        <button type="submit" class="botao botao-perigo">Confirmar eliminação</button>
      </form>
    </details>
  </section>

  <section class="cartao">
    <h2>Repor demonstração</h2>
    <p>Apaga tudo da memória e carrega os dados de demonstração (3 fornecedores, 3 produtos, 5 clientes, 4 vendas, 1 campanha).</p>
    <details class="confirmar">
      <summary class="botao botao-perigo">Repor dados</summary>
      <form method="post" action="${ctx}/admin/persistencia">
        <input type="hidden" name="accao" value="repor">
        <button type="submit" class="botao botao-perigo">Confirmar reposição</button>
      </form>
    </details>
  </section>
</div>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
