# 🐞 Debugger App - Visual UI Inspector & Style Editor

A real-time, browser-based debugging environment for inspecting, modifying, and customizing web application layouts with visual tools.

## ✨ Features

### 🎨 GUI Layout Editor
- **Element Selection**: Click-to-pick or dropdown selector
- **Live Style Editing**:
  - Width, height, padding, margin (sliders)
  - Background & text colors (color pickers)
  - Border radius, opacity, z-index
  - Font size, family, weight
- **Real-time Preview**: Changes apply instantly
- **Theme Management**:
  - Save themes as JSON
  - Load saved themes
  - Export CSS files
  - Reset to original styles

### 📁 File Manager
- Upload files (code, documents, images)
- File preview with syntax display
- Metadata display (size, type, timestamp)
- Delete uploaded files

### 🖥️ Console Logger
- Real-time console output capture
- Filter by level (log, warn, error, info)
- Auto-scroll to latest messages
- Clear console functionality

### 🧪 State Evaluator
- Execute JavaScript expressions
- Evaluate in iframe or debugger context
- View results with syntax highlighting
- Expression history tracking

## 🚀 Quick Start

### Option 1: Open Directly
```bash
cd debugger-app
# Open index.html in your browser
xdg-open index.html  # Linux
open index.html      # macOS
start index.html     # Windows
```

### Option 2: Use with Local Server
```bash
# Using Python
cd debugger-app
python3 -m http.server 8080

# Using Node.js
npx http-server -p 8080

# Then open: http://localhost:8080
```

## 📖 How to Use

### 1. Element Selection
- **Method 1**: Use dropdown to select an element
- **Method 2**: Click "Pick Element" and click on target in preview

### 2. Modify Styles
- Adjust sliders for numeric values (width, padding, etc.)
- Use color pickers for colors
- Change dropdowns for fonts and properties
- See changes apply instantly in the preview

### 3. Save Your Work
- **Save Theme**: Downloads JSON file + saves to localStorage
- **Load Theme**: Upload previously saved theme JSON
- **Export CSS**: Get standalone CSS file of all changes
- **Reset**: Restore original styles

### 4. Console & Debugging
- Switch to **Console tab** to view logs
- Use **State tab** to evaluate expressions like:
  ```javascript
  document.querySelector('.button')
  window.innerWidth
  Math.random()
  ```

### 5. File Management
- Upload files via **Files tab**
- Click "View" to preview content
- Delete unwanted files

## 🎨 Color Theme

The app uses a dark theme with neon cyan accents:
- **Background**: #0d0d0d to #1a1a1a
- **Accent**: #00FFFF (cyan)
- **Text**: #E0E0E0
- **Font**: Courier New, monospace

## 📁 File Structure

```
debugger-app/
├── index.html          # Main application
├── css/
│   └── debugger.css    # Dark theme styles
├── js/
│   ├── gui-editor.js   # Visual style editor
│   ├── file-manager.js # File upload/preview
│   ├── console.js      # Console logger
│   ├── state.js        # Expression evaluator
│   └── main.js         # App initialization
├── examples/
│   └── demo.html       # Sample page for testing
└── README.md           # This file
```

## 🔧 Advanced Usage

### Inspecting Your Own Page
Replace the iframe source in `index.html`:
```html
<iframe id="targetFrame" src="YOUR_PAGE_URL.html"></iframe>
```

### Cross-Origin Restrictions
If inspecting external pages, you may encounter CORS restrictions. Solutions:
1. Run both pages on same domain
2. Use a local proxy
3. Disable CORS in browser (development only!)

### Keyboard Shortcuts
- `Enter` in State tab: Evaluate expression
- Panel toggles: Click `−` to collapse panels

## 🛠️ Customization

### Change Theme Colors
Edit `css/debugger.css` `:root` variables:
```css
:root {
    --bg-dark: #0d0d0d;
    --accent-cyan: #00FFFF;
    /* ... more variables */
}
```

### Add New Style Controls
In `js/gui-editor.js`, add new controls following the pattern:
```javascript
this.setupRangeControl('newProperty', (value) => {
    if (this.selectedElement) {
        this.selectedElement.style.newProperty = value;
    }
});
```

## 📝 Known Limitations

1. **Cross-Origin Restrictions**: Cannot inspect pages from different domains
2. **File Content Persistence**: Uploaded files stored in memory only (lost on refresh)
3. **Advanced Debugging**: Breakpoints/step-through require browser DevTools integration

## 🔮 Future Enhancements

- [ ] Breakpoint support (Chrome DevTools Protocol)
- [ ] Network request monitoring
- [ ] Performance profiling
- [ ] CSS animations editor
- [ ] Responsive design testing tools
- [ ] Browser extension version

## 📄 License

Free to use and modify.

## 🤝 Contributing

This is a standalone tool. Feel free to fork and customize for your needs!

---

**Built with ❤️ for developers who love visual debugging**
