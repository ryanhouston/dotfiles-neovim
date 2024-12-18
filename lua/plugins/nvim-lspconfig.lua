return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pylsp = {
          settings = {
            java = {
              configuration = {
                runtimes = {
                  {
                    name = "JavaSE-11",
                    path = "~/.jenv/shims/java",
                  },
                },
              },
            },
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
