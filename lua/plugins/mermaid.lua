return {
  {
    "kevalin/mermaid.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
    config = function(_, opts)
      require("mermaid").setup(opts)

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "mermaid",
        callback = function()
          local map = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = 0, desc = desc })
          end

          map("<leader>mp", "<cmd>MermaidPreview<CR>", "Mermaid Preview")
          map("<leader>mf", "<cmd>MermaidFormat<CR>", "Mermaid Format")
          map("<leader>mr", "<cmd>MermaidRender<CR>", "Mermaid Render")
          map("<leader>mc", "<cmd>MermaidCopyURL<CR>", "Mermaid Copy URL")
          map("<leader>mx", "<cmd>MermaidPreviewStop<CR>", "Mermaid Stop Preview")
        end,
      })
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
