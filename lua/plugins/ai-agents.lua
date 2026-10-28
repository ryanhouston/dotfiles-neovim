return {
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

    local opencode_cmd = "opencode"
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

    vim.keymap.set({ "n", "x" }, "<leader>aa", function()
      require("opencode").ask("@this: ")
    end, { desc = "Ask opencode" })
    vim.keymap.set({ "n", "x" }, "<leader>as", function()
      require("opencode").select()
    end, { desc = "Select opencode" })
    vim.keymap.set({ "n", "t" }, "<leader>at", function()
      require("snacks.terminal").toggle(opencode_cmd, terminal_opts)
    end, { desc = "Toggle opencode" })

    vim.keymap.set({ "n", "x" }, "go", function()
      return require("opencode").operator("@this ")
    end, { desc = "Add range to opencode", expr = true })
    vim.keymap.set("n", "goo", function()
      return require("opencode").operator("@this ") .. "_"
    end, { desc = "Add line to opencode", expr = true })
  end,
}
