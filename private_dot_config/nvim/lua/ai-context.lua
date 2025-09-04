-- AI Context Module for Neovim
-- Provides lightweight context consumption from external AI tools

local M = {}

-- Configuration
M.config = {
  bridge_file = '/tmp/nvim-context.json',
  cache_timeout = 5000,  -- 5 seconds
  performance_thresholds = {
    thermal_critical = 80,
    thermal_warning = 60,
    memory_critical = 80,
    memory_warning = 60
  }
}

-- Cache for external data
M.cache = {
  data = {},
  last_update = 0
}

-- Virtual text namespace
M.ns_id = vim.api.nvim_create_namespace('ai_context_hints')

-- Update cache from bridge file
function M.update_cache()
  local now = vim.loop.now()
  if now - M.cache.last_update < M.config.cache_timeout then
    return M.cache.data
  end
  
  M.cache.last_update = now
  
  -- Read from environment bridge
  local ok, content = pcall(vim.fn.readfile, M.config.bridge_file)
  if ok and #content > 0 then
    local data = vim.fn.json_decode(table.concat(content, '\n'))
    if data then
      M.cache.data = data
    end
  end
  
  -- Add environment variables
  M.cache.data.claude_session = vim.env.CLAUDE_SESSION
  M.cache.data.anthropic_api = vim.env.ANTHROPIC_API_KEY ~= nil
  M.cache.data.openai_api = vim.env.OPENAI_API_KEY ~= nil
  
  return M.cache.data
end

-- Check if performance mode should be enabled
function M.should_limit_features()
  local data = M.update_cache()
  
  if data.thermal_state and data.thermal_state > M.config.performance_thresholds.thermal_critical then
    return true, 'thermal'
  end
  
  if data.memory_usage and data.memory_usage > M.config.performance_thresholds.memory_critical then
    return true, 'memory'
  end
  
  return false, nil
end

-- Display memory hint as virtual text
function M.show_memory_hint(line_num, hint_text, confidence)
  local bufnr = vim.api.nvim_get_current_buf()
  local prefix = ''
  
  if confidence then
    if confidence > 0.7 then
      prefix = '✓ '
    elseif confidence > 0.5 then
      prefix = '? '
    end
  end
  
  vim.api.nvim_buf_set_extmark(bufnr, M.ns_id, line_num - 1, 0, {
    virt_text = {{prefix .. hint_text, 'Comment'}},
    virt_text_pos = 'eol',
    priority = 100
  })
end

-- Clear all virtual hints
function M.clear_hints()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, M.ns_id, 0, -1)
end

-- Search memories (stub - would call MCP tools in real implementation)
function M.search_memories(query)
  -- This would integrate with mcp__graphiti-mcp__search_memory
  -- For now, return mock data
  return {
    {
      content = "Use Docker multi-stage builds for smaller images",
      confidence = 0.85,
      age_days = 2
    },
    {
      content = "Set PYTORCH_ENABLE_MPS_FALLBACK=0 for M3 Pro optimization",
      confidence = 0.92,
      age_days = 5
    }
  }
end

-- Get current GTD context
function M.get_gtd_context()
  local data = M.update_cache()
  return data.gtd_task or nil
end

-- Performance-aware feature toggle
function M.toggle_performance_mode()
  local limited, reason = M.should_limit_features()
  
  if limited then
    -- Disable heavy features
    vim.opt.cursorline = false
    vim.opt.cursorcolumn = false
    vim.opt.relativenumber = false
    vim.cmd('TSDisable highlight')
    vim.notify('Performance mode enabled due to ' .. reason .. ' pressure', vim.log.levels.WARN)
  else
    -- Re-enable features
    vim.opt.cursorline = true
    vim.opt.relativenumber = true
    vim.cmd('TSEnable highlight')
    vim.notify('Performance mode disabled', vim.log.levels.INFO)
  end
end

-- Show inline hints for current buffer
function M.show_buffer_hints()
  M.clear_hints()
  
  -- Get current buffer content
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  
  -- Look for patterns that might have memory matches
  for i, line in ipairs(lines) do
    if line:match('error') or line:match('Error') then
      M.show_memory_hint(i, "Check memory for similar errors", 0.6)
    elseif line:match('TODO') or line:match('FIXME') then
      local gtd = M.get_gtd_context()
      if gtd then
        M.show_memory_hint(i, "GTD: " .. gtd, 0.9)
      end
    end
  end
end

-- Setup function
function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})
  
  -- Create commands
  vim.api.nvim_create_user_command('AIContext', function(args)
    if args.args == 'hints' then
      M.show_buffer_hints()
    elseif args.args == 'clear' then
      M.clear_hints()
    elseif args.args == 'performance' then
      M.toggle_performance_mode()
    elseif args.args == 'status' then
      local data = M.update_cache()
      vim.notify(vim.inspect(data), vim.log.levels.INFO)
    end
  end, {
    nargs = 1,
    complete = function()
      return {'hints', 'clear', 'performance', 'status'}
    end
  })
  
  -- Auto-commands
  local group = vim.api.nvim_create_augroup('AIContext', { clear = true })
  
  -- Check performance on focus
  vim.api.nvim_create_autocmd('FocusGained', {
    group = group,
    callback = function()
      local limited, _ = M.should_limit_features()
      if limited then
        M.toggle_performance_mode()
      end
    end
  })
  
  -- Clear hints on buffer leave
  vim.api.nvim_create_autocmd('BufLeave', {
    group = group,
    callback = M.clear_hints
  })
end

return M