return {
  -- add thrift syntax
  { "nvim-treesitter", opts = { ensure_installed = { "thrift" } } },
  {
    "nvim-lspconfig",
    optional = true,
    opts = {
      servers = {
        thriftls = {
          root_markers = { ".root.thrift" },
          ".git",
        },
      },
    },
  },
}
