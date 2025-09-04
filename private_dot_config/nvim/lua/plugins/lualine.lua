return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    -- Cache for external data to avoid repeated calls
    local cache = {
      thermal_state = nil,
      memory_usage = nil,
      gtd_task = nil,
      claude_session = nil,
      last_update = 0
    }

    -- Update cache every 5 seconds max
    local function update_cache()
      local now = vim.loop.now()
      if now - cache.last_update < 5000 then return end
      cache.last_update = now
      
      -- Read from environment bridge file if it exists
      local bridge_file = '/tmp/nvim-context.json'
      local ok, content = pcall(vim.fn.readfile, bridge_file)
      if ok and #content > 0 then
        local data = vim.fn.json_decode(table.concat(content, '\n'))
        if data then
          cache.thermal_state = data.thermal_state
          cache.memory_usage = data.memory_usage
          cache.gtd_task = data.gtd_task
        end
      end
      
      -- Check environment variables
      cache.claude_session = vim.env.CLAUDE_SESSION
    end

    -- Custom component: Claude session indicator
    local function claude_session()
      update_cache()
      if cache.claude_session then
        return '🤖'
      end
      return ''
    end

    -- Custom component: GTD task
    local function gtd_task()
      update_cache()
      if cache.gtd_task and cache.gtd_task ~= '' then
        return '📋 ' .. string.sub(cache.gtd_task, 1, 30)
      end
      return ''
    end

    -- Custom component: Thermal state
    local function thermal_state()
      update_cache()
      if cache.thermal_state then
        if cache.thermal_state > 80 then
          return '🔥' .. cache.thermal_state .. '°C'
        elseif cache.thermal_state > 60 then
          return '🌡️' .. cache.thermal_state .. '°C'
        end
      end
      return ''
    end

    -- Custom component: Memory pressure
    local function memory_pressure()
      update_cache()
      if cache.memory_usage then
        if cache.memory_usage > 80 then
          return '🧠' .. cache.memory_usage .. '%'
        elseif cache.memory_usage > 60 then
          return '💭' .. cache.memory_usage .. '%'
        end
      end
      return ''
    end

    -- Custom component: API status
    local function api_status()
      local apis = {}
      if vim.env.ANTHROPIC_API_KEY then table.insert(apis, '🧠') end
      if vim.env.OPENAI_API_KEY then table.insert(apis, '🔧') end
      if #apis > 0 then
        return table.concat(apis, '')
      end
      return ''
    end

    require('lualine').setup {
      options = {
        theme = 'catppuccin',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = { 'NvimTree', 'neo-tree', 'dashboard' },
        },
        globalstatus = true,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        }
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 
          'branch',
          {
            'diff',
            colored = true,
            symbols = { added = '+', modified = '~', removed = '-' },
          }
        },
        lualine_c = {
          {
            'filename',
            path = 1,  -- Relative path
            symbols = {
              modified = '[+]',
              readonly = '[-]',
              unnamed = '[No Name]',
            }
          },
          gtd_task,
        },
        lualine_x = {
          thermal_state,
          memory_pressure,
          'encoding',
          'fileformat',
          'filetype'
        },
        lualine_y = {
          api_status,
          claude_session,
          'progress'
        },
        lualine_z = { 'location' }
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {}
      },
      extensions = { 'fugitive', 'nvim-tree', 'lazy' }
    }

    -- Auto-refresh on focus to get latest context
    vim.api.nvim_create_autocmd({'FocusGained', 'BufEnter'}, {
      callback = function()
        cache.last_update = 0  -- Force cache update
      end
    })
  end
}