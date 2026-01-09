# 🐞 Divine Debugger - Chrome Extension

Visual UI Inspector & Style Editor as a Chrome DevTools Extension

## 🚀 Installation

### Load Unpacked Extension (Development)

1. **Open Chrome Extensions Page**
   ```
   chrome://extensions/
   ```

2. **Enable Developer Mode**
   - Toggle the "Developer mode" switch in the top right

3. **Load Extension**
   - Click "Load unpacked"
   - Select the `debugger-extension` folder
   - Extension icon will appear in your toolbar!

4. **Use Divine Debugger**
   - Navigate to any webpage
   - Open DevTools (F12 or Right-click → Inspect)
   - Click the "Divine Debugger" tab
   - Start debugging!

## ✨ Features

### 🎯 Element Inspector
- Select any element on the page
- View element info (tag, ID, classes)
- Quick actions: Hide, Show, Highlight

### 🎨 Style Editor
- **Layout**: Width, height, padding, margin
- **Appearance**: Colors, border radius, opacity, z-index
- **Typography**: Font size, family, weight
- Real-time preview as you adjust

### 🖥️ Console Logger
- View console messages from the inspected page
- Filter by log level
- Clear and manage logs

### 🧪 JavaScript Evaluator
- Execute code in the inspected page context
- View results instantly
- Expression history

### 💾 Theme Management
- Save your style changes as themes
- Export to CSS files
- Load and apply saved themes

## 📖 How to Use

1. **Open DevTools** on any webpage (F12)
2. **Find "Divine Debugger" tab** in DevTools
3. **Select an element** from the dropdown or click "Inspect Element"
4. **Adjust styles** using the Style Editor panel
5. **See changes live** on the actual page
6. **Save your work** with Theme Management

## 🎨 Interface

- **Dark theme** with cyan (#00FFFF) accents
- **Left Panel**: Element inspector & quick actions
- **Right Panel**: Style editor & theme tools
- **Bottom Panel**: Console & JavaScript evaluator

## 🔧 Technical Details

### Permissions Required
- `activeTab`: Access current tab for inspection
- `storage`: Save themes and preferences
- `<all_urls>`: Inject styles into any page

### Files Structure
```
debugger-extension/
├── manifest.json           # Extension config
├── popup.html             # Extension popup
├── icons/                 # Extension icons
├── devtools/
│   ├── devtools.html      # DevTools entry point
│   ├── devtools.js        # Panel registration
│   ├── panel.html         # Main debugger UI
│   └── panel.js           # Extension logic
├── css/
│   └── debugger.css       # Styles
└── js/                    # (future enhancements)
```

## 🆚 vs Browser DevTools

**Divine Debugger** complements Chrome DevTools:
- **Simpler UI** for quick style tweaks
- **Visual controls** (sliders, color pickers)
- **Theme saving** for design iterations
- **Quick actions** for common tasks

**Chrome DevTools** is better for:
- Breakpoint debugging
- Network monitoring
- Performance profiling
- DOM manipulation

## 🔮 Future Enhancements

- [ ] Network request monitoring
- [ ] Performance metrics
- [ ] CSS animations editor
- [ ] Responsive design testing
- [ ] Element screenshot
- [ ] Style diff/compare
- [ ] Keyboard shortcuts

## 🐛 Troubleshooting

### Extension not showing in DevTools?
- Refresh the extension at `chrome://extensions/`
- Reload the page you're inspecting
- Close and reopen DevTools

### Can't modify elements?
- Check if site has CSP (Content Security Policy) restrictions
- Some sites block external modifications

### Changes not saving?
- Use "Save Theme" to persist changes
- Changes are live only - refresh reverts them

## 📝 Development

### Making Changes
1. Edit files in `debugger-extension/`
2. Go to `chrome://extensions/`
3. Click reload icon on Divine Debugger card
4. Refresh DevTools panel

### Adding Features
- **panel.js**: Main extension logic
- **panel.html**: UI structure
- **debugger.css**: Styling

## 📄 License

Free to use and modify.

---

**Built with ❤️ for developers who love visual debugging**
