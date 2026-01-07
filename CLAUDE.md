# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Divine Node (PKN - Parakleon) is a self-hosted, multi-agent AI system that runs locally with complete privacy. It combines 6 specialized AI agents coordinated through a Flask backend, using llama.cpp for local LLM inference (Qwen2.5-Coder-14B), and a cyberpunk-themed web UI. The system is designed for both desktop Linux and Android (Termux).

## Build & Test Commands

### Service Management
```bash
# Start all services (Flask server port 8010, llama.cpp port 8000)
./pkn_control.sh start-all

# Stop all services
./pkn_control.sh stop-all

# Check service status
./pkn_control.sh status

# Individual service control
./pkn_control.sh start-divinenode    # Flask server
./pkn_control.sh start-llama         # llama.cpp inference server
./pkn_control.sh start-parakleon     # API wrapper
./pkn_control.sh start-ollama        # Ollama (optional)

# Debug LLM connection
./pkn_control.sh debug-qwen
```

### Development
```bash
# Python environment
source .venv/bin/activate
pip install -r requirements.txt

# View logs
tail -f divinenode.log    # Flask server logs
tail -f llama.log         # llama.cpp inference logs

# Test endpoints
curl http://localhost:8010/health
curl http://localhost:8000/v1/models
curl -X POST http://localhost:8010/api/multi-agent/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello", "mode": "auto"}'
```

### Testing
```bash
# Test agent integration
python3 test_free_agents.py
python3 test_fixed_agents.py

# Test streaming responses
./test_streaming.sh

# Test specific tools
curl -X POST http://localhost:8010/api/phonescan \
  -H "Content-Type: application/json" \
  -d '{"number": "+1-555-123-4567"}'
```

## Architecture

### Multi-Agent System
The core architecture uses **agent_manager.py** to coordinate 6 specialized agents:

1. **Coder** (`AgentType.CODER`) - Code writing, debugging, refactoring via Qwen2.5-Coder
2. **Reasoner** (`AgentType.REASONER`) - Planning, logic, problem-solving
3. **Researcher** (`AgentType.RESEARCHER`) - Web research, documentation lookup
4. **Executor** (`AgentType.EXECUTOR`) - System commands, file operations
5. **General** (`AgentType.GENERAL`) - Quick Q&A, simple queries
6. **Consultant** (`AgentType.CONSULTANT`) - External LLM calls (Claude/GPT)

**Key Design Pattern:**
- Frontend sends message → `divinenode_server.py` receives via `/api/multi-agent/chat`
- `agent_manager.py` classifies task and routes to appropriate agent
- Agent executes with tool access via `tools/` modules
- Response returns with agent metadata (which agent, tools used, performance metrics)

### Backend Structure (Python)

```
divinenode_server.py (1,212 lines)
├── Flask server on port 8010
├── Routes: /api/multi-agent/chat, /api/phonescan, /api/generate-image, /health
└── Serves static files (pkn.html, js/, css/, img/)

agent_manager.py (625 lines)
├── AgentManager class coordinates all agents
├── Task classification based on keywords and complexity
├── Agent-to-agent messaging via AgentMessage
└── Tool integration via tools/ modules

conversation_memory.py (404 lines)
├── Session persistence (memory/ directory)
├── Global memory (~/.parakleon_memory.json)
└── Project memory (pkn_memory.json)

code_context.py (416 lines)
├── Project analysis and symbol extraction
└── Tree-sitter integration for code parsing

local_parakleon_agent.py (386 lines)
├── Local LLM agent implementation
└── Interfaces with llama.cpp via OpenAI-compatible API

external_llm.py (374 lines)
├── External API integration (Claude, GPT)
└── Fallback for consultant agent
```

### Frontend Structure (JavaScript - Modular)

**Core UI:**
- `pkn.html` - Main entry point, loads all JS modules
- `js/main.js` - Core UI initialization and event handling
- `js/chat.js` - Chat message rendering and history
- `js/multi_agent_ui.js` - Agent selection, routing, and status display

**Features:**
- `js/autocomplete.js` - Code completion (40-120ms)
- `js/agent_quality.js` - Performance monitoring and health checks
- `js/images.js` - AI image generation UI
- `js/projects.js` - Project management and file operations
- `js/settings.js` - User settings and preferences
- `js/files.js` - File upload and management

**Utilities:**
- `js/storage.js` - LocalStorage wrapper for persistence
- `js/utils.js` - Common utility functions
- `js/models.js` - Model selection and configuration

### Tool System

Tools are organized in `tools/` directory (imported in agent_manager.py):
- `code_tools.py` - Code analysis, symbol extraction
- `file_tools.py` - Read/write files with safety checks
- `system_tools.py` - Execute shell commands
- `web_tools.py` - HTTP requests, web scraping
- `memory_tools.py` - Conversation persistence

**Tool Usage Pattern:**
Agents can call tools during task execution. Tools return structured data that agents incorporate into responses.

### LLM Integration

**llama.cpp server:**
- Started via `pkn_control.sh start-llama`
- OpenAI-compatible API on port 8000
- Model: Qwen2.5-Coder-14B-Instruct-Q4_K_M (8.4GB)
- Key parameters: `--n_gpu_layers 45`, `--n_batch 512`, `--n_ctx 8192`
- Chat format: `--chat_format qwen`

**Backend connection:**
- Python agents use requests library to call http://127.0.0.1:8000/v1/chat/completions
- Follows OpenAI API spec (messages array, temperature, max_tokens)

## Key Patterns & Conventions

### Agent Routing Logic
Located in `agent_manager.py`, routing uses keyword matching:
- "code", "function", "debug" → Coder agent
- "plan", "analyze", "think" → Reasoner agent
- "research", "search", "find" → Researcher agent
- "run", "execute", "command" → Executor agent
- Default fallback → General agent

Override with `agent_override` parameter in `/api/multi-agent/chat` request.

### Session Management
- Each chat session gets unique `session_id` (UUID)
- Sessions persist to `memory/session_{id}.json`
- Global context in `~/.parakleon_memory.json` (user preferences, notes)
- Project context in `pkn_memory.json` (project-specific knowledge)

### Error Handling
- Agents return structured responses with `{"error": "message"}` on failure
- Frontend displays errors in red badges
- Quality monitor tracks success/failure rates per agent
- Automatic retry logic: 1 retry attempt with 3s delay

### Performance Targets
- Autocomplete: <120ms
- Agent selection: <50ms
- Simple queries (General agent): 2-4s
- Code generation (Coder agent): 8-15s
- Complex tasks (multi-agent): 20-45s

## Configuration Files

### Environment Variables (.env)
```bash
OLLAMA_BASE=http://127.0.0.1:11434
LOCAL_LLM_BASE=http://127.0.0.1:8000/v1
LLAMA_MODEL_PATH=/home/gh0st/pkn/llama.cpp/models/qwen2.5-coder-14b-instruct-q4_k_m.gguf
OPENAI_API_KEY=your_key_here  # Optional for consultant agent
ANTHROPIC_API_KEY=your_key_here  # Optional for consultant agent
```

### Memory Files
- `~/.parakleon_memory.json` - Global user preferences and notes
- `pkn_memory.json` - Project-specific context
- `memory/session_{id}.json` - Individual chat sessions

### Model Requirements
The system expects a GGUF model file at path specified in `pkn_control.sh` (line 22):
```bash
GGUF_MODEL="$PKN_DIR/llama.cpp/models/Qwen2.5-Coder-14B-Instruct-abliterated-Q4_K_M.gguf"
```

## Mobile Deployment (Termux)

Key differences for Android:
- Use `termux_menu.sh` instead of `pkn_control.sh` for user-friendly menu
- Build llama.cpp with: `cmake .. -DCMAKE_BUILD_TYPE=Release` (no GPU)
- Reduce model size: Use Qwen 7B Q4_0 (3.8GB) instead of 14B
- Reduce threads: `--n_threads 4` in pkn_control.sh
- Battery: Acquire wake lock via `termux-wake-lock`
- Storage: Extract to `/sdcard/pkn` for better permissions

## Important Notes for Development

### When Modifying Agents
1. Agent definitions are in `agent_manager.py` `_init_agents()` method
2. Update routing keywords in `_classify_task()` if adding new capabilities
3. Test with `./pkn_control.sh debug-qwen` to verify LLM connectivity

### When Adding Tools
1. Create tool function in appropriate `tools/` module
2. Import in `agent_manager.py` top section
3. Document tool in agent's `capabilities` list
4. Tools must return JSON-serializable data

### When Modifying Frontend
1. All JS is modular - edit specific `js/*.js` file, not monolithic app.js
2. CSS follows cyberpunk theme: dark backgrounds, cyan accents (#00ffff)
3. Mobile breakpoints: 320px, 768px, 1024px
4. Hard refresh required: Ctrl+Shift+R (browser caching is disabled but helpful during development)

### When Debugging
- Check `divinenode.log` for Flask errors
- Check `llama.log` for LLM inference errors
- Browser console (F12) for frontend JavaScript errors
- Use `curl` to test API endpoints directly
- Quality monitor UI shows per-agent performance and errors

### Critical Path for Message Flow
1. User types in `pkn.html` input → Event listener in `js/chat.js`
2. `sendMessage()` calls `/api/multi-agent/chat` with message + mode
3. Flask route in `divinenode_server.py` receives request
4. `agent_manager.handle_task()` classifies and routes to agent
5. Agent calls llama.cpp at `http://127.0.0.1:8000/v1/chat/completions`
6. Response flows back through agent_manager → Flask → frontend
7. `js/chat.js` renders response with agent badge and performance metrics

### Ports in Use
- 8010: Flask server (divinenode_server.py)
- 8000: llama.cpp inference server
- 9000: Parakleon API wrapper (optional)
- 11434: Ollama (optional)

Avoid conflicts by checking `lsof -i :8010` before starting services.

## llama.cpp Integration

The project includes llama.cpp as a submodule for local inference:

### Building llama.cpp
```bash
cd llama.cpp
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release  # Add -DLLAMA_CUDA=ON for GPU
make -j$(nproc)
```

### Server Usage
Launched via `pkn_control.sh` which runs:
```bash
python3 -m llama_cpp.server \
  --model "$GGUF_MODEL" \
  --host 0.0.0.0 \
  --port 8000 \
  --chat_format qwen \
  --n_threads $(($(nproc) - 2)) \
  --n_gpu_layers 45 \
  --n_batch 512 \
  --n_ctx 8192
```

See llama.cpp/README.md for full build options and `.github/copilot-instructions.md` for llama.cpp-specific conventions.

## Recent Fixes (2026-01-05)

### Welcome Screen Overlay Issue - RESOLVED

**Problem**: Welcome screen was appearing over chat messages after user sent first message.

**Root Cause**: Multiple `setTimeout(() => showWelcomeScreen(), 50)` calls throughout app.js were re-showing the welcome screen even after messages existed.

**Solution Implemented**:
1. CSS: `.welcome-screen` now has `display: none` by default (line 1806 in main.css)
2. JS: `hideWelcomeScreen()` completely removes element from DOM using `.remove()` (app.js:338-343)
3. JS: `showWelcomeScreen()` actively checks for messages and removes welcome screen if any exist (app.js:347-363)

**Key Code Locations**:
- `/home/gh0st/pkn/css/main.css` line 1806: Default hidden state
- `/home/gh0st/pkn/app.js` lines 338-363: Welcome screen show/hide logic
- `/home/gh0st/pkn/app.js` lines 757, 2355, 2372, 2405, 2533: setTimeout calls that trigger showWelcomeScreen()

### Agent Switcher FAB Button - REFINED

**Changed**: Made FAB button more subtle and less intrusive
- Size: 56px → 44px (40px on mobile)
- Background: Translucent `rgba(0, 255, 255, 0.15)` instead of solid cyan
- Opacity: 60% default, 100% on hover
- Icon: Reduced to 24px with 80% opacity

**Code Location**: `/home/gh0st/pkn/css/main.css` lines 2070-2097

## Current State (as of 2026-01-05)

### Active Files
- **Frontend**: `pkn.html`, `app.js` (143KB), modular `js/*.js` files
- **Backend**: `divinenode_server.py`, `agent_manager.py`, Python modules
- **Styles**: `css/main.css`, `css/multi_agent.css`
- **Config**: `pkn_control.sh`, `.env`, `CLAUDE.md`, `CHANGELOG.md`

### Cleaned Up
- Removed: `css/main.css.backup`, `css/multi_agent.css.backup`
- Excluded from backups: `minecraft_builds/` (gaming projects), `llama.cpp/`, `.venv/`, `node_modules/`, `*.log`, `memory/`

### Backup Location
Latest backup: `../pkn_backup_YYYYMMDD_HHMMSS.tar.gz` (excludes gaming content, logs, dependencies)

## Debugging Tips

### If Welcome Screen Issues Return
1. Check browser console for "Welcome screen shown/hidden/removed" logs
2. Verify CSS has `display: none` on `.welcome-screen` class
3. Ensure `hideWelcomeScreen()` is called in `sendMessage()` (app.js line 386)
4. Check that `showWelcomeScreen()` has the message-checking logic

### If FAB Button Too Loud
- Adjust opacity in `.agent-switcher-fab` class (main.css line 2088)
- Reduce background alpha: `rgba(0, 255, 255, 0.15)` (lower last value)
- Check mobile breakpoint styles at line 2278

## Mobile Phone Deployment (2026-01-07)

### Termux Android Deployment Summary

**Deployment Location**: User's Android phone via Termux
- Phone directory: `~/pkn-phone/` (separate from PC build at `/home/gh0st/pkn/`)
- SSH access: `ssh u0_a322@192.168.1.200 -p 8022` (password: `pkn123`)
- Server port: 8010 (same as desktop)

### Lightweight Mobile Server

Created **`~/pkn-phone/divinenode_server.py`** - stripped-down Flask server optimized for mobile:
- Single local Phi-3 Mini agent (3.8GB model)
- Minimal endpoints for chat functionality
- No Ollama, no multi-agent orchestration (too resource-intensive for phone)
- Added missing API endpoints to prevent 405 errors:
  - `/api/multi-agent/chat/stream` (non-streaming fallback for mobile)
  - `/api/autocomplete` (disabled - returns empty suggestions)
  - `/api/multi-agent/agents` (returns single "general" agent)
  - `/api/health` (health check)
  - `/api/files/list` (disabled - returns empty array)
  - `/api/models/ollama` (not available on mobile)
  - `/api/models/llamacpp` (returns phi3-mini-3.8b)

### UI Files Transferred to Phone

All UI files copied from PC (`/home/gh0st/pkn/`) to phone (`~/pkn-phone/`):
- `pkn.html` - Main HTML (modified for mobile with inline CSS)
- `css/` - Stylesheets directory
- `js/` - JavaScript modules
- `img/` - Images including `icchat.png` icon
- `manifest.json` - PWA manifest

### Mobile CSS Strategy - Inline Critical CSS

**Problem**: External CSS files were aggressively cached by mobile browsers (304 Not Modified responses), preventing layout updates.

**Solutions Attempted**:
1. ✗ External `css/mobile.css` - kept caching
2. ✗ Cache-busting parameters `?v=timestamp` - still cached
3. ✗ Disabled service worker (`sw.js` → `sw.js.disabled`) - helped but not enough
4. ✓ **Inline CSS in HTML `<head>`** - final working solution

**Implemented Mobile CSS** (added directly to `~/pkn-phone/pkn.html` before `</head>`):
```html
<!-- MOBILE INLINE CSS -->
<style>
@media (max-width: 1024px) {
    /* Hide scrollbars */
    *::-webkit-scrollbar { display: none !important; }
    * { scrollbar-width: none !important; max-width: 100vw !important; }

    /* Base font size readable on mobile */
    html, body { font-size: 14px !important; overflow-x: hidden !important; width: 100vw !important; margin: 0 !important; }

    /* Sidebar completely hidden by default */
    .sidebar { transform: translateX(-105%) !important; position: fixed !important; width: 240px !important; z-index: 1000 !important; }
    .sidebar.visible { transform: translateX(0) !important; }
    .hover-strip { display: none !important; width: 0 !important; }

    /* Main content full width */
    .main { margin-left: 0 !important; width: 100% !important; }

    /* Hide desktop-only controls */
    .header select, select#modelSelect, select#agentSelect { display: none !important; }
    .header button { width: 100% !important; font-size: 13px !important; height: 36px !important; }

    /* Subtle menu toggle button */
    .toggle-btn { position: fixed !important; top: 12px !important; left: 12px !important; width: 36px !important; height: 36px !important; background: rgba(0,255,255,0.15) !important; opacity: 0.6 !important; }

    /* Welcome boxes stack vertically */
    .welcome-grid, .features-grid { display: flex !important; flex-direction: column !important; }
    .welcome-box { width: calc(100% - 20px) !important; padding: 12px !important; }

    /* Messages area with bottom padding for fixed input */
    #messagesContainer { padding-bottom: 140px !important; font-size: 15px !important; }
    .message { padding: 12px !important; font-size: 15px !important; }

    /* Fixed input container at bottom */
    .input-container { position: fixed !important; bottom: 0 !important; padding: 10px !important; z-index: 999 !important; }

    /* Chat controls in 3-column grid above input */
    .input-controls { display: flex !important; flex-wrap: wrap !important; gap: 6px !important; margin-bottom: 8px !important; }
    .input-controls button { flex: 1 1 calc(33% - 4px) !important; font-size: 12px !important; height: 32px !important; }

    /* Textarea sizing */
    #messageInput { font-size: 15px !important; height: 42px !important; padding: 10px !important; }

    /* Circular glowing send button */
    .send-btn { width: 42px !important; height: 42px !important; border-radius: 50% !important; background: linear-gradient(135deg, #00ffff, #00cccc) !important; color: #000 !important; }
    .send-btn::after { content: "▶" !important; }
    .send-btn span { display: none !important; }
}
</style>
```

### Termux Menu Integration

Updated **`~/pkn/scripts/termux_menu.sh`** to launch PKN Mobile:
```bash
PKN_MOBILE="$HOME/pkn-phone"
MOBILE_PORT=8010
MOBILE_URL="http://127.0.0.1:${MOBILE_PORT}"

start_pkn_mobile() {
    cd "$PKN_MOBILE"
    python3 divinenode_server.py &
    sleep 2
    # Cache-busting URL with timestamp
    am start -a android.intent.action.VIEW -d "${MOBILE_URL}?v=$(date +%s)"
}
```

Menu options added:
- `PKN Mobile` - Start server and open in browser with cache-busting
- `PKN Server Only` - Start server without opening browser

### Known Issues (as of 2026-01-07)

**CRITICAL - Still Unresolved**:
1. **UI Overlap** - User reports "a lot of overlap still" with mobile layout
   - Elements may be overlapping despite CSS fixes
   - Hard to debug without visual access to phone screen
   - May require additional CSS refinements or `!important` flags

**Resolved Issues**:
- ✓ Service worker caching old versions - Disabled `sw.js`
- ✓ External CSS caching - Switched to inline CSS
- ✓ 405 errors on chat endpoint - Added all missing API endpoints
- ✓ Menu button halfway visible - Fixed with CSS positioning
- ✓ Elements too large/too small - Iterated multiple versions to find readable sizes
- ✓ Sidebar not fully hiding - Set `transform: translateX(-105%)`

### Mobile vs Desktop Build

**IMPORTANT**: Two separate deployments maintained:
- **PC Build**: `/home/gh0st/pkn/` - Full multi-agent system, all features intact
- **Phone Build**: `~/pkn-phone/` - Lightweight single-agent, mobile-optimized UI

**DO NOT** mix files between these two locations. PC build is production-quality and should not be overwritten by mobile experiments.

### Debugging Mobile Layout Issues

When fixing mobile CSS:
1. **DO**: Edit `~/pkn-phone/pkn.html` inline `<style>` block directly
2. **DO**: Use SSH to restart server: `pkill -f divinenode_server.py && cd ~/pkn-phone && python3 divinenode_server.py &`
3. **DO**: Open with cache-busting: `http://127.0.0.1:8010?v=TIMESTAMP`
4. **DON'T**: Rely on external CSS files - they cache aggressively
5. **DON'T**: Forget to use `!important` flags - mobile browsers are stubborn
6. **DON'T**: Modify PC build files when working on mobile deployment

### Browser Cache Clearing Commands

User tested in both browsers on Android:
- **Firefox Nightly**: Settings → Clear browsing data → Cached images and files
- **Chrome**: Settings → Privacy → Clear browsing data → Cached images and files

Even with manual clearing, inline CSS proved more reliable than external files.

### Next Steps for Mobile (When Resumed)

1. Get visual screenshot from user to identify overlap issues
2. Refine inline CSS in `~/pkn-phone/pkn.html` based on specific overlap problems
3. Test in both Firefox Nightly and Chrome to ensure cross-browser compatibility
4. Consider adding user agent detection to serve different CSS for different mobile browsers
5. Document final working mobile CSS once layout issues are fully resolved
