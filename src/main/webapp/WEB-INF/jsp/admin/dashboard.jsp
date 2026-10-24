<c:set var="titulo" value="Painel"/>
<c:set var="menu" value="painel"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<div class="cabecalho-pagina">
  <h1>Painel do administrador</h1>
  <p class="subtitulo">Resumo do catálogo, clientes, vendas e campanhas.</p>
</div>

<div class="indicadores">
  <a class="indicador" href="${ctx}/admin/fornecedores"><span class="indicador-valor">${painel.fornecedores}</span><span>fornecedores</span></a>
  <a class="indicador" href="${ctx}/admin/produtos"><span class="indicador-valor">${painel.produtos}</span><span>produtos</span></a>
  <a class="indicador" href="${ctx}/admin/listagens?tipo=clientes"><span class="indicador-valor">${painel.clientes}</span><span>clientes</span></a>
  <a class="indicador" href="${ctx}/admin/compras"><span class="indicador-valor">${painel.vendas}</span><span>vendas</span></a>
  <a class="indicador" href="${ctx}/admin/campanhas"><span class="indicador-valor">${painel.campanhas}</span><span>${painel.campanhas == 1 ? 'campanha' : 'campanhas'}</span></a>
  <div class="indicador indicador-destaque"><span class="indicador-valor">${f:mt(painel.totalVendido)}</span><span>total vendido (com IVA)</span></div>
</div>

<div class="grelha-2 grelha-topo">
  <section class="cartao">
    <h2>Últimas vendas</h2>
    <c:choose>
      <c:when test="${empty painel.ultimasVendas}"><p class="vazio">Ainda não há vendas.</p></c:when>
      <c:otherwise>
        <div class="tabela-envolvente">
          <table class="tabela tabela-compacta">
            <thead><tr><th>Factura</th><th>Cliente</th><th>Data</th><th class="num">Total</th></tr></thead>
            <tbody>
              <c:forEach var="v" items="${painel.ultimasVendas}">
                <tr>
                  <td><a href="${ctx}/factura?id=${v.id}"><c:out value="${v.numeroFactura}"/></a></td>
                  <td><c:out value="${v.clienteNome}"/></td>
                  <td>${f:dataHora(v.data)}</td>
                  <td class="num">${f:mt(v.total)}</td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </c:otherwise>
    </c:choose>
  </section>

  <section class="cartao">
    <h2>Stock baixo <small>(menos de ${limiteStock})</small></h2>
    <c:choose>
      <c:when test="${empty painel.stockBaixo}"><p class="vazio">Todos os produtos têm stock suficiente.</p></c:when>
      <c:otherwise>
        <ul class="lista-simples">
          <c:forEach var="p" items="${painel.stockBaixo}">
            <li>
              <a href="${ctx}/admin/produtos#produto-${p.id}"><c:out value="${p.nome}"/></a>
              <span class="${p.quantidade == 0 ? 'texto-erro' : 'texto-aviso'}">${p.quantidade} <c:out value="${p.unidade}"/></span>
            </li>
          </c:forEach>
        </ul>
      </c:otherwise>
    </c:choose>
  </section>
</div>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
