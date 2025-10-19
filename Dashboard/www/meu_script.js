// Seleciona o elemento pela classe "sidebar-toggle"
var sidebarToggle = document.querySelector('.sidebar-toggle');

// Verifica se o elemento foi encontrado
if (sidebarToggle) {
  // Remove o elemento do DOM
  sidebarToggle.parentNode.removeChild(sidebarToggle);
}
