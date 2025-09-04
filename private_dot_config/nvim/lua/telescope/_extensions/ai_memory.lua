-- Telescope extension for AI memory search
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local previewers = require('telescope.previewers')

local M = {}

-- Mock memory search (would integrate with MCP in production)
local function search_memories(query)
  -- In production, this would call mcp__graphiti-mcp__search_memory
  return {
    {
      id = '1',
      content = 'Docker multi-stage builds reduce image size',
      confidence = 0.85,
      age_days = 2,
      context = 'Solved slow container startup issue',
      tags = {'docker', 'optimization'}
    },
    {
      id = '2', 
      content = 'Use PYTORCH_ENABLE_MPS_FALLBACK=0 for M3 Pro',
      confidence = 0.92,
      age_days = 5,
      context = 'Fixed Metal performance issues',
      tags = {'m3pro', 'pytorch', 'performance'}
    },
    {
      id = '3',
      content = 'pytest fixtures with async support need pytest-asyncio',
      confidence = 0.78,
      age_days = 10,
      context = 'Resolved async test failures',
      tags = {'python', 'testing', 'async'}
    }
  }
end

-- Format memory entry for display
local function format_memory(memory)
  local confidence_icon = ''
  if memory.confidence > 0.8 then
    confidence_icon = '✓'
  elseif memory.confidence > 0.6 then
    confidence_icon = '?'
  else
    confidence_icon = '⚠'
  end
  
  local age_str = memory.age_days .. 'd ago'
  local tags_str = table.concat(memory.tags or {}, ', ')
  
  return string.format('%s %.0f%% [%s] %s | %s',
    confidence_icon,
    memory.confidence * 100,
    age_str,
    memory.content,
    tags_str
  )
end

-- Main picker function
M.memory_search = function(opts)
  opts = opts or {}
  local query = opts.query or ''
  
  -- Get memories
  local memories = search_memories(query)
  
  pickers.new(opts, {
    prompt_title = '🧠 AI Memory Search',
    finder = finders.new_table {
      results = memories,
      entry_maker = function(memory)
        return {
          value = memory,
          display = format_memory(memory),
          ordinal = memory.content .. ' ' .. table.concat(memory.tags or {}, ' '),
        }
      end
    },
    sorter = conf.generic_sorter(opts),
    previewer = previewers.new_buffer_previewer {
      title = 'Memory Details',
      define_preview = function(self, entry)
        local memory = entry.value
        local lines = {
          '# Memory Details',
          '',
          '**Content:** ' .. memory.content,
          '',
          '**Confidence:** ' .. string.format('%.0f%%', memory.confidence * 100),
          '**Age:** ' .. memory.age_days .. ' days ago',
          '**Context:** ' .. (memory.context or 'N/A'),
          '',
          '**Tags:** ' .. table.concat(memory.tags or {}, ', '),
          '',
          '---',
          '',
          'Press <CR> to insert as comment',
          'Press <C-v> to view as virtual text',
        }
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
        vim.api.nvim_buf_set_option(self.state.bufnr, 'filetype', 'markdown')
      end
    },
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          -- Insert as comment in current buffer
          local memory = selection.value
          local comment = string.format('-- Memory (%.0f%%): %s', 
            memory.confidence * 100, memory.content)
          vim.api.nvim_put({comment}, 'l', false, true)
        end
      end)
      
      -- Additional mapping for virtual text
      map('i', '<C-v>', function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          local memory = selection.value
          local ai_context = require('ai-context')
          local line = vim.fn.line('.')
          ai_context.show_memory_hint(line, memory.content, memory.confidence)
        end
      end)
      
      return true
    end,
  }):find()
end

-- GTD task picker
M.gtd_tasks = function(opts)
  opts = opts or {}
  
  -- Mock GTD tasks (would integrate with MCP in production)
  local tasks = {
    { id = '1', title = 'Implement caching layer', project = 'Backend', priority = 'high' },
    { id = '2', title = 'Write unit tests for API', project = 'Backend', priority = 'medium' },
    { id = '3', title = 'Update documentation', project = 'Docs', priority = 'low' },
  }
  
  pickers.new(opts, {
    prompt_title = '📋 GTD Tasks',
    finder = finders.new_table {
      results = tasks,
      entry_maker = function(task)
        local priority_icon = task.priority == 'high' and '🔴' or 
                            task.priority == 'medium' and '🟡' or '🟢'
        return {
          value = task,
          display = string.format('%s [%s] %s', priority_icon, task.project, task.title),
          ordinal = task.title .. ' ' .. task.project,
        }
      end
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          -- Insert as TODO comment
          local task = selection.value
          local comment = string.format('-- TODO: %s [%s]', task.title, task.project)
          vim.api.nvim_put({comment}, 'l', false, true)
        end
      end)
      return true
    end,
  }):find()
end

return M