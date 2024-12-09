return {
  -- add gruvbox
  { "ellisonleao/gruvbox.nvim" },
  -- add material
  { "marko-cerovac/material.nvim" },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "material",
      materiial_style = "oceanic",
    },
  },
}
