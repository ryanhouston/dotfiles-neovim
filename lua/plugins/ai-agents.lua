return {
  {
    "nickjvandyke/opencode.nvim",
    -- Tracks "main": supports OpenCode v2. `version = "*"` pins the v1 line (v1.0.2).
    dependencies = {
      {
        "folke/snacks.nvim",
        optional = true,
        opts = {
          input = {},
          picker = {
            actions = {
              opencode_send = function(picker)
                local items = vim.tbl_map(function(item)
                  return item.file
                      and require("opencode").format({ path = item.file, from = item.pos, to = item.end_pos })
                    or item.text
                end, picker:selected({ fallback = true }))

                require("opencode").prompt(table.concat(items, ", ") .. " ")
              end,
            },
            win = {
              input = {
                keys = {
                  ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
                },
              },
            },
          },
        },
      },
    },
    config = function()
      vim.o.autoread = true

      -- `--continue` resumes the last session for this project, so the TUI and
      -- Neovim's prompts (which target the most recently updated session) stay aligned.
      local opencode_cmd = "opencode --continue"
      ---@type snacks.terminal.Opts
      local terminal_opts = {
        win = {
          position = "right",
          enter = false,
        },
      }

      ---@type opencode.Opts
      vim.g.opencode_opts = {
        server = {
          start = function()
            require("snacks.terminal").open(opencode_cmd, terminal_opts)
          end,
        },
      }

      -- Reveal the TUI when OpenCode starts executing a prompt from Neovim.
      vim.api.nvim_create_autocmd("User", {
        pattern = { "OpencodeEvent:session.execution.started" },
        callback = function()
          local win = require("snacks.terminal").get(opencode_cmd, { create = false })
          if win then
            win:show()
          end
        end,
        desc = "Show OpenCode terminal when execution starts",
      })

      vim.keymap.set({ "n", "x" }, "<leader>aa", function()
        require("opencode").ask("@this: ")
      end, { desc = "Ask opencode" })
      vim.keymap.set({ "n", "x" }, "<leader>as", function()
        require("opencode").select()
      end, { desc = "Select opencode" })
      -- Toggle in normal mode, and in terminal mode via a non-leader key: a
      -- leader-prefixed terminal mapping would add a `timeoutlen` pause to every
      -- `,` typed inside the TUI.
      vim.keymap.set("n", "<leader>at", function()
        require("snacks.terminal").toggle(opencode_cmd, terminal_opts)
      end, { desc = "Toggle opencode" })
      vim.keymap.set("t", "<C-.>", function()
        require("snacks.terminal").toggle(opencode_cmd, terminal_opts)
      end, { desc = "Toggle opencode" })

      -- One-shot prompts: send immediately, no input popup. In normal mode `@this`
      -- is only a cursor point, so normal mode uses a real scope (`@buffer` /
      -- `@visible`) while visual mode sends just the selection via `@this`.
      vim.keymap.set("n", "<leader>aE", function()
        require("opencode").prompt("Explain @visible and its context")
      end, { desc = "Explain visible in opencode" })
      vim.keymap.set("x", "<leader>aE", function()
        require("opencode").prompt("Explain @this and its context")
      end, { desc = "Explain selection in opencode" })
      vim.keymap.set("n", "<leader>aR", function()
        require("opencode").prompt("Review @buffer for correctness and readability")
      end, { desc = "Review buffer in opencode" })
      vim.keymap.set("x", "<leader>aR", function()
        require("opencode").prompt("Review @this for correctness and readability")
      end, { desc = "Review selection in opencode" })
      vim.keymap.set("n", "<leader>aT", function()
        require("opencode").prompt("Add tests for @buffer")
      end, { desc = "Test buffer in opencode" })
      vim.keymap.set("x", "<leader>aT", function()
        require("opencode").prompt("Add tests for @this")
      end, { desc = "Test selection in opencode" })
      vim.keymap.set({ "n", "x" }, "<leader>aD", function()
        require("opencode").prompt("Fix @diagnostics")
      end, { desc = "Fix diagnostics in opencode" })

      vim.keymap.set({ "n", "x" }, "go", function()
        return require("opencode").operator("@this ")
      end, { desc = "Add range to opencode", expr = true })
      vim.keymap.set("n", "goo", function()
        return require("opencode").operator("@this ") .. "_"
      end, { desc = "Add line to opencode", expr = true })

      -- Group the opencode keymaps under one which-key "AI" entry.
      LazyVim.on_load("which-key.nvim", function()
        require("which-key").add({ { "<leader>a", group = "AI", mode = { "n", "x" } } })
      end)
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, {
        function()
          return require("opencode").statusline()
        end,
        -- Hidden until the plugin has connected (i.e. after the first ask/select).
        cond = function()
          return require("opencode.events.status").url ~= nil
        end,
      })
    end,
  },
}
