return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre path/to/my-vault/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "compass",
        path = "~/Documents/Wiki/Compass",
      },
      {
        name = "personal",
        path = "~/Dropbox/Wiki/personal",
      },
    },

    notes_subdir = "Log",

    ---@param title string|?
    ---@return string
    note_id_func = function(title)
      -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
      -- In this case a note with the title 'My new note' will be given an ID that looks
      -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
      local suffix = ""
      if title ~= nil then
        -- If title is given, transform it into valid file name.
        suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        -- If title is nil, just add 4 random uppercase letters to the suffix.
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return tostring(os.date("%Y%m%d-%H%M%S", os.time())) .. "-" .. suffix
    end,

    preferred_link_style = "markdown",

    templates = {
      folder = "_templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
      -- A map for custom variables, the key should be the variable and the value a function
      substitutions = {},
    },

    -- Disable ui to prefer render-markdown.nvim
    ui = { enable = false },

    ---@param url string
    follow_url_func = function(url)
      -- Open the URL in the default web browser.
      vim.ui.open(url) -- need Neovim 0.10.0+
    end,
  },
  keys = {
    { "<leader>ob", "<cmd>ObsidianBacklinks<CR>", desc = "Obsidian Backlinks" },
    { "<leader>oll", "<cmd>ObsidianLink<CR>", desc = "Obsidian Link", mode = { "n", "v" } },
    { "<leader>oln", "<cmd>ObsidianLinkNew<CR>", desc = "Obsidian Link New", mode = { "n", "v" } },
    { "<leader>on", "<cmd>ObsidianNew<CR>", desc = "Obsidian New Note" },
    { "<leader>or", "<cmd>ObsidianRename<CR>", desc = "Obsidian Rename" },
    { "<leader>ot", "<cmd>ObsidianTags<CR>", desc = "Obsidian Matching Tags", mode = { "n", "v" } },
  },
}
