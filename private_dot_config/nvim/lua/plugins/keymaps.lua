-- AI Context Keymaps
return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    config = function()
      local wk = require("which-key")
      
      wk.setup()
      
      -- AI Context mappings
      wk.add({
        { "<leader>a", group = "AI Context" },
        { "<leader>am", "<cmd>Telescope ai_memory memory<cr>", desc = "Search Memories" },
        { "<leader>ag", "<cmd>Telescope ai_memory gtd<cr>", desc = "GTD Tasks" },
        { "<leader>ah", "<cmd>AIContext hints<cr>", desc = "Show Hints" },
        { "<leader>ac", "<cmd>AIContext clear<cr>", desc = "Clear Hints" },
        { "<leader>ap", "<cmd>AIContext performance<cr>", desc = "Toggle Performance Mode" },
        { "<leader>as", "<cmd>AIContext status<cr>", desc = "Show Status" },
        
        -- Quick access
        { "<leader>mm", "<cmd>Telescope ai_memory memory<cr>", desc = "Memory Search" },
        { "<leader>mt", "<cmd>Telescope ai_memory gtd<cr>", desc = "GTD Tasks" },
      })
    end,
  }
}