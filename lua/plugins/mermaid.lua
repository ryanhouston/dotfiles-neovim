return {
  {
    "kevalin/mermaid.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
    config = function(_, opts)
      require("mermaid").setup(opts)
      require("config.mermaid").setup()
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "mermaid" } },
  },

  {
    "folke/which-key.nvim",
    opts = { spec = { { "<leader>m", group = "Mermaid" } } },
  },
}
