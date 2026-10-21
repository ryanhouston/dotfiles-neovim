return {
  {
    "obsidian-nvim/obsidian.nvim",
    opts = function(_, opts)
      -- Add the work vault on top of the shared workspaces
      table.insert(opts.workspaces, {
        name = "compass",
        path = "~/Documents/Wiki/CompassPKM",
      })
    end,
  },
}
