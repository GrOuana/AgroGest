<c:set var="titulo" value="Créditos das imagens"/>
<%@ include file="/WEB-INF/jsp/comum/cabecalho.jspf" %>

<header class="page__header">
  <div class="page__heading">
    <h1 class="page__title">Créditos das imagens</h1>
    <p class="page__subtitle">Fotografias do Wikimedia Commons e ícone do Twemoji, usados segundo as respectivas licenças livres.</p>
  </div>
</header>

<section class="card" aria-labelledby="creditos-fotos">
  <header class="card__header"><h2 class="card__title" id="creditos-fotos">Fotografias dos produtos</h2></header>
  <div class="table-wrap">
    <table class="table">
      <caption class="table__caption">As fotografias foram reduzidas para 960 px de largura; não houve outras alterações.</caption>
      <thead>
        <tr>
          <th scope="col" class="table__th"><span class="visually-hidden">Imagem</span></th>
          <th scope="col" class="table__th">Usada em</th>
          <th scope="col" class="table__th">Original</th>
          <th scope="col" class="table__th">Autor</th>
          <th scope="col" class="table__th">Licença</th>
        </tr>
      </thead>
      <tbody>
        <tr class="table__row">
          <td class="table__td"><img class="thumb" src="${ctx}/img/produtos/milho.jpg" alt="" width="44" height="44"></td>
          <th scope="row" class="table__td">Semente de Milho</th>
          <td class="table__td"><a href="https://commons.wikimedia.org/wiki/File:Zea_mays_seeds_closeup.jpg" rel="noopener">Zea mays seeds closeup.jpg</a></td>
          <td class="table__td">Rasbak</td>
          <td class="table__td"><a href="https://creativecommons.org/licenses/by-sa/3.0/deed.pt" rel="license noopener">CC BY-SA 3.0</a></td>
        </tr>
        <tr class="table__row">
          <td class="table__td"><img class="thumb" src="${ctx}/img/produtos/adubo.jpg" alt="" width="44" height="44"></td>
          <th scope="row" class="table__td">Adubo NPK</th>
          <td class="table__td"><a href="https://commons.wikimedia.org/wiki/File:Fertilizer-_NPK-MS.jpg" rel="noopener">Fertilizer- NPK-MS.jpg</a></td>
          <td class="table__td">Mahsa-110</td>
          <td class="table__td"><a href="https://creativecommons.org/licenses/by/4.0/deed.pt" rel="license noopener">CC BY 4.0</a></td>
        </tr>
        <tr class="table__row">
          <td class="table__td"><img class="thumb" src="${ctx}/img/produtos/enxada.jpg" alt="" width="44" height="44"></td>
          <th scope="row" class="table__td">Enxada</th>
          <td class="table__td"><a href="https://commons.wikimedia.org/wiki/File:Hoe_farming_tool_in_Taraba_State.jpg" rel="noopener">Hoe farming tool in Taraba State.jpg</a></td>
          <td class="table__td">Gwanki</td>
          <td class="table__td"><a href="https://creativecommons.org/licenses/by-sa/4.0/deed.pt" rel="license noopener">CC BY-SA 4.0</a></td>
        </tr>
        <tr class="table__row">
          <td class="table__td"><img class="thumb" src="${ctx}/img/produtos/feijao.jpg" alt="" width="44" height="44"></td>
          <th scope="row" class="table__td">Feijão nhemba</th>
          <td class="table__td"><a href="https://commons.wikimedia.org/wiki/File:BlackEyedPeas.JPG" rel="noopener">BlackEyedPeas.JPG</a></td>
          <td class="table__td">Toby Hudson</td>
          <td class="table__td"><a href="https://creativecommons.org/licenses/by-sa/3.0/deed.pt" rel="license noopener">CC BY-SA 3.0</a></td>
        </tr>
        <tr class="table__row">
          <td class="table__td"><img class="thumb" src="${ctx}/img/produtos/sem-foto.jpg" alt="" width="44" height="44"></td>
          <th scope="row" class="table__td">Produtos sem fotografia</th>
          <td class="table__td"><a href="https://commons.wikimedia.org/wiki/File:Cassava_field_in_Mozambique.jpg" rel="noopener">Cassava field in Mozambique.jpg</a></td>
          <td class="table__td">Viljami Aarbakke</td>
          <td class="table__td"><a href="https://creativecommons.org/licenses/by/2.5/deed.pt" rel="license noopener">CC BY 2.5</a></td>
        </tr>
      </tbody>
    </table>
  </div>
</section>

<div class="columns columns--2">
  <section class="card" aria-labelledby="creditos-logo">
    <h2 class="card__title" id="creditos-logo">Ícone do logótipo</h2>
    <p class="card__text">O símbolo 🌱 do logótipo é o emoji «seedling» do <a href="https://github.com/twitter/twemoji" rel="noopener">Twemoji</a>,
      © Twitter, Inc. e colaboradores, licenciado em <a href="https://creativecommons.org/licenses/by/4.0/deed.pt" rel="license noopener">CC-BY 4.0</a>
      (<a href="${ctx}/licencas/twemoji-CC-BY-4.0.txt">texto da licença</a>). O nome AgroGest é deste trabalho escolar.</p>
  </section>
  <section class="card" aria-labelledby="creditos-fonte">
    <h2 class="card__title" id="creditos-fonte">Tipografia</h2>
    <p class="card__text">Fonte <a href="https://rsms.me/inter/" rel="noopener">Inter</a>, © The Inter Project Authors,
      licenciada em SIL Open Font License 1.1 (<a href="${ctx}/licencas/inter-OFL-1.1.txt">texto da licença</a>).</p>
  </section>
</div>

<%@ include file="/WEB-INF/jsp/comum/rodape.jspf" %>
