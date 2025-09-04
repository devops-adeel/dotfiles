# AI Context Integration for Neovim

## Overview
This configuration creates a lightweight bridge between your sophisticated starship prompt and minimal Neovim setup, allowing Neovim to consume AI context without becoming bloated.

## Philosophy
- **Starship**: Environmental sensor layer (monitoring, context tracking)
- **Neovim**: Fast action layer (editing with selective context consumption)
- **Bridge**: Minimal overhead data pipe between the two

## Features

### 1. Lualine Status Components
Custom statusline components that display:
- 🤖 Claude session indicator
- 📋 Current GTD task (truncated to 30 chars)
- 🔥/🌡️ Thermal state warnings
- 🧠/💭 Memory pressure indicators
- API availability status

### 2. AI Memory Search
Telescope pickers for searching:
- **Memory search** (`<leader>am` or `<leader>mm`)
  - Search historical solutions and patterns
  - Shows confidence scores and age
  - Insert as comment or virtual text
- **GTD tasks** (`<leader>ag` or `<leader>mt`)
  - Browse and insert current tasks

### 3. Virtual Text Hints
Contextual hints displayed inline:
- `<leader>ah` - Show hints for current buffer
- `<leader>ac` - Clear all hints
- Automatic hints for errors and TODOs

### 4. Performance-Aware Features
- `<leader>ap` - Toggle performance mode
- Auto-disables heavy features when:
  - Thermal state > 80°C
  - Memory usage > 80%
- Graceful degradation preserves editing speed

### 5. Environment Bridge
Starship updates `/tmp/nvim-context.json` with:
- System thermal state
- Memory usage
- Current GTD task
- Performance metrics
- AI model availability

## Key Bindings

| Key | Description |
|-----|-------------|
| `<leader>am` | Search AI memories |
| `<leader>ag` | Browse GTD tasks |
| `<leader>ah` | Show buffer hints |
| `<leader>ac` | Clear hints |
| `<leader>ap` | Toggle performance mode |
| `<leader>as` | Show AI context status |

## Commands

- `:AIContext hints` - Show inline hints
- `:AIContext clear` - Clear hints
- `:AIContext performance` - Toggle performance mode
- `:AIContext status` - Display current context

## Architecture

```
┌─────────────┐       ┌──────────────┐       ┌─────────────┐
│  Starship   │──────▶│ Bridge File  │◀──────│   Neovim    │
│  (sensors)  │       │   (JSON)     │       │  (display)  │
└─────────────┘       └──────────────┘       └─────────────┘
      │                                             │
      ▼                                             ▼
 System Metrics                              Context Display
 API Detection                               Memory Hints
 GTD Context                                 Performance Mode
```

## Configuration

The system is configured through:
- `/lua/ai-context.lua` - Core context module
- `/lua/plugins/lualine.lua` - Statusline components
- `/lua/telescope/_extensions/ai_memory.lua` - Search pickers
- `/scripts/update-nvim-context.sh` - Bridge updater

## Performance Impact

Minimal by design:
- Cache updates max every 5 seconds
- Event-driven updates only
- No background processes
- Automatic feature degradation under load

## Integration Points

### With Memory System (Future)
The mock functions in `ai_memory.lua` are ready to integrate with:
- `mcp__graphiti-mcp__search_memory`
- `mcp__graphiti-mcp__get_gtd_context`

### With Starship
Starship's `custom.nvim_bridge` module runs the update script on each prompt, keeping context fresh without polling.

## Troubleshooting

1. **No context showing**: Check if `/tmp/nvim-context.json` exists
2. **Performance issues**: Use `<leader>ap` to toggle performance mode
3. **Bridge not updating**: Verify script is executable: `chmod +x ~/.config/nvim/scripts/update-nvim-context.sh`

## Future Enhancements

- Real MCP integration for memory search
- Langfuse trace analysis overlays
- Project-specific context rules
- Automatic solution application from memories