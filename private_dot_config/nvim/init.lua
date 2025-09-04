require('config.lazy')
require('plugins.first')

-- Initialize AI Context
require('ai-context').setup({
  bridge_file = '/tmp/nvim-context.json',
  cache_timeout = 5000,
  performance_thresholds = {
    thermal_critical = 80,
    thermal_warning = 60,
    memory_critical = 80,
    memory_warning = 60
  }
})

-- vim: ts=8 sts=2 sw=2 et
