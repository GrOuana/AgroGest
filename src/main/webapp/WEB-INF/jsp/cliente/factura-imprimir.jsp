<%-- Versão de impressão: só a factura, sem menu. Imprime-se com Ctrl+P (o frontend não usa JavaScript). --%>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Factura <c:out value="${venda.numeroFactura}"/> · AgroGest</title>
  <link rel="stylesheet" href="${ctx}/css/estilo.css">
</head>
<body class="pagina-impressao">
  <p class="instrucao-impressao nao-imprimir">
    Prima <kbd>Ctrl</kbd> + <kbd>P</kbd> (ou <kbd>⌘</kbd> + <kbd>P</kbd> no Mac) para imprimir ou guardar em PDF.
  </p>
  <%@ include file="/WEB-INF/jsp/cliente/factura-corpo.jspf" %>
</body>
</html>
