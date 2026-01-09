// Create the Divine Debugger panel in DevTools
chrome.devtools.panels.create(
    "Divine Debugger",
    "icons/icon48.png",
    "devtools/panel.html",
    function(panel) {
        console.log("Divine Debugger panel created");
    }
);
