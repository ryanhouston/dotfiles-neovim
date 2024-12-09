return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pylsp = {
          settings = {
            pylsp = {
              plugins = {
                autopep8 = { enabled = false },
                mccabe = { enabled = false },
                pycodestyle = {
                  enabled = true,
                  maxLineLength = 100,
                },
                pydocstyle = { enabled = true },
                pyflakes = { enabled = true },
                pylint = { enabled = false },
                yapf = { enabled = false },
              },
            },
          },
        },
      },
    },
  },
}
