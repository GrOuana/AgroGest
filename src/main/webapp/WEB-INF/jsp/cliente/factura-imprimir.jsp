<%-- Versão de impressão: só a factura, sem menu. Imprime-se com Ctrl+P (o frontend não usa JavaScript). --%>
<!DOCTYPE html>
<html lang="pt" data-theme="${tema}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="color-scheme" content="${tema == 'dark' ? 'dark' : (tema == 'light' ? 'light' : 'light dark')}">
  <title>Factura <c:out value="${venda.numeroFactura}"/> · AgroGest</title>
  <link rel="stylesheet" href="${ctx}/css/global.css">
</head>
<body>
<main class="print-page">
  <p class="print-page__hint no-print">
    Prima <kbd>Ctrl</kbd> + <kbd>P</kbd> (ou <kbd>⌘</kbd> + <kbd>P</kbd> no Mac) para imprimir ou guardar em PDF.
  </p>
  <%@ include file="/WEB-INF/jsp/cliente/factura-corpo.jspf" %>
</main>
</body>
</html>
