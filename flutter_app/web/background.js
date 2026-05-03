// Chrome Extension MV3 — Service Worker
// Abre Allot en una pestaña nueva al hacer clic en el icono de la extensión

chrome.action.onClicked.addListener(async () => {
  const url = chrome.runtime.getURL('index.html');

  // Si ya hay una pestaña abierta con Allot, la enfoca en lugar de abrir otra
  const tabs = await chrome.tabs.query({ url });
  if (tabs.length > 0) {
    chrome.tabs.update(tabs[0].id, { active: true });
    chrome.windows.update(tabs[0].windowId, { focused: true });
  } else {
    chrome.tabs.create({ url });
  }
});
