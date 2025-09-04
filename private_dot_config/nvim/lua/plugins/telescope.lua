
return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local telescope = require('telescope')
    
    telescope.setup {
      defaults = {
        layout_strategy = 'horizontal',
        layout_config = {
          horizontal = {
            preview_width = 0.5,
          },
        },
      },
    }
    
    -- Register AI memory extension
    telescope.register_extension {
      exports = {
        memory = require('telescope._extensions.ai_memory').memory_search,
        gtd = require('telescope._extensions.ai_memory').gtd_tasks,
      }
    }
  end
}
