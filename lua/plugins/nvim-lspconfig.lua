return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {},
        -- pylsp = {
        --   settings = {
        --     pylsp = {
        --       plugins = {
        --         autopep8 = { enabled = false },
        --         mccabe = { enabled = false },
        --         pycodestyle = {
        --           enabled = true,
        --           maxLineLength = 100,
        --         },
        --         pydocstyle = { enabled = true },
        --         pyflakes = { enabled = true },
        --         pylint = { enabled = false },
        --         yapf = { enabled = false },
        --       },
        --     },
        --   },
        -- },
        jdtls = {
          -- Custom setup function to handle Bazel workspace
          setup = function()
            local util = require("lspconfig.util")

            -- Find WORKSPACE file to identify Bazel workspace root
            local function find_workspace_root(fname)
              return util.root_pattern("WORKSPACE", "WORKSPACE.bazel")(fname) or util.root_pattern(".git")(fname)
            end

            -- Generate classpath from Bazel
            local function get_bazel_classpath(workspace_root)
              local handle =
                io.popen('cd "' .. workspace_root .. '" && find bazel-bin -name "*.jar" 2>/dev/null | head -100')
              local jars = {}
              if handle then
                for line in handle:lines() do
                  table.insert(jars, workspace_root .. "/" .. line)
                end
                handle:close()
              end

              -- Add external dependencies
              local external_handle = io.popen(
                'cd "'
                  .. workspace_root
                  .. '" && find bazel-urbancompass/external -name "*.jar" 2>/dev/null | head -100'
              )
              if external_handle then
                for line in external_handle:lines() do
                  table.insert(jars, workspace_root .. "/" .. line)
                end
                external_handle:close()
              end

              return jars
            end

            -- Get source paths
            local function get_source_paths(workspace_root)
              return {
                workspace_root .. "/src/java",
                workspace_root .. "/tests/java",
                workspace_root .. "/bazel-bin/src/java",
              }
            end

            local root_dir = find_workspace_root(vim.fn.expand("%:p"))
            if not root_dir then
              root_dir = vim.fn.getcwd()
            end

            local classpath = get_bazel_classpath(root_dir)
            local source_paths = get_source_paths(root_dir)

            return {
              cmd = {
                vim.fn.expand("~/.local/share/nvim/mason/bin/jdtls"),
                "-data",
                vim.fn.expand("~/.cache/jdtls-workspace/") .. vim.fn.fnamemodify(root_dir, ":t"),
                "-configuration",
                vim.fn.expand("~/.cache/jdtls-config"),
                "--add-modules=ALL-SYSTEM",
                "--add-opens",
                "java.base/java.util=ALL-UNNAMED",
                "--add-opens",
                "java.base/java.lang=ALL-UNNAMED",
                "--add-opens",
                "java.base/java.io=ALL-UNNAMED",
                "--add-opens",
                "java.base/java.nio=ALL-UNNAMED",
              },
              root_dir = root_dir,
              settings = {
                java = {
                  configuration = {
                    runtimes = {
                      {
                        name = "JavaSE-11",
                        path = vim.fn.expand("~/.jenv/shims/java"),
                      },
                      {
                        name = "JavaSE-17",
                        path = vim.fn.expand("~/.jenv/shims/java"),
                      },
                    },
                  },
                  project = {
                    referencedLibraries = classpath,
                    sourcePaths = source_paths,
                  },
                  compile = {
                    nullAnalysis = {
                      mode = "automatic",
                    },
                  },
                  eclipse = {
                    downloadSources = true,
                  },
                  maven = {
                    downloadSources = true,
                  },
                  format = {
                    enabled = true,
                    settings = {
                      url = vim.fn.stdpath("config") .. "/lang-servers/intellij-java-google-style.xml",
                      profile = "GoogleStyle",
                    },
                  },
                  saveActions = {
                    organizeImports = true,
                  },
                },
              },
            }
          end,
        },
      },
    },
  },
}
