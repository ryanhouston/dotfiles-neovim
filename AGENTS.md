# Agent Guidelines for Neovim Configuration

This is a Neovim configuration using LazyVim. This document provides guidelines
for agents working on this codebase.

## Project Structure

```
~/.config/nvim/
├── init.lua              # Entry point - bootstraps lazy.nvim
├── lua/
│   ├── config/           # Core config: lazy, options, keymaps, autocmds, profile
│   ├── plugins/          # Shared plugin specs: conform, lspconfig, etc.
│   └── profiles/         # Machine-specific specs, one dir per profile
│       └── <name>/
│           ├── init.lua          # Optional early setup hook
│           ├── extras.lua        # Optional profile-only LazyVim extras
│           └── plugins/          # Plugin specs only loaded for this profile
├── stylua.toml           # Lua formatter config (2 spaces, 120 col)
└── lazyvim.json          # LazyVim extras manifest (shared across machines)
```

## Machine Profiles

This config is shared between machines (personal + work), so anything that only
makes sense in one environment belongs in a profile, not in `lua/plugins/`.

- The active profile is resolved by `lua/config/profile.lua`, in order:
  `$NVIM_PROFILE` env var → `profile.local` (gitignored, one line) → hostname
  map in that file → `personal`.
- `lua/config/lazy.lua` imports `profiles.<name>.extras` (before `plugins`, so
  lazy.nvim's import-order check stays valid) and `profiles.<name>.plugins`,
  skipping either if the profile doesn't define it.
- `init.lua` calls `profiles.<name>.setup()` (if present) before lazy starts,
  for early `vim.env`/option tweaks.
- To add a profile-specific plugin override, extend the shared spec, e.g.
  `opts = function(_, opts) table.insert(opts.workspaces, ...) end`, so shared
  config still applies.
- `lazyvim.json` extras are global. To make an extra load in only one profile,
  remove it from `lazyvim.json` and import it in `profiles/<name>/extras.lua`
  (e.g. `lang.java` is work-only). Setting `enabled = false` on an extra that
  `lazyvim.json` already enables does **not** work — lazy.nvim dedups by module
  name, so the first import wins.

## Build/Lint/Test Commands

```bash
stylua --check lua/       # Check Lua formatting (exit code 1 if not formatted)
stylua lua/               # Format all Lua files

:Lazy sync                # Sync plugins (in Neovim)
:Lazy                     # Open plugin manager UI
:checkhealth              # Run health checks
```

Test changes by restarting Neovim or running `:Lazy sync`.

## Code Style Guidelines

- **Language**: Lua | **Indent**: 2 spaces | **Column width**: 120 | **Line
  endings**: LF
- **Naming**: `snake_case` for variables/functions/modules; `kebab-case` for
  plugin names
- **Type Annotations**: Use EmmyLua (`---@param`, `---@class`, `---@type`)

```lua
local my_var = "value"                              -- Variables: snake_case
local function my_func() end                        -- Functions: snake_case
vim.keymap.set("n", "<leader>fp", fn, { desc = "..." })  -- Always use desc
opts = { auto_close = true }                        -- Config keys: snake_case

---@param opts table Configuration options
---@class MyPluginConfig
---@field enabled boolean
---@field timeout number
```

## lazy.nvim Plugin Management

### Plugin Spec Format

```lua
return {
  "author/plugin-name",              -- Simple plugin

  {
    "author/plugin-name",
    opts = {},                       -- Passed to setup()
    event = "VeryLazy",              -- Lazy-load on event
    cmd = "PluginCmd",               -- Lazy-load on command
    keys = { ... },                  -- Lazy-load on keymap
    enabled = true,                  -- or false to disable
    dependencies = { "dep/plugin" },
  },
}
```

### Merging Configurations

Options are deep-merged automatically with LazyVim defaults:

```lua
return {
  "folke/trouble.nvim",
  opts = { modes = { symbols = { win = { size = 40 } } } },
}
```

### Override Pattern

Use `opts` function to access merged defaults:

```lua
{
  "plugin/name",
  opts = function(_, defaults)
    return vim.tbl_deep_extend("force", defaults, { custom_option = true })
  end,
}
```

## LSP Configuration

### Server Setup Pattern

```lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      pyright = {},                                    -- Simple server
      jdtls = { setup = function() ... end },          -- Custom setup
    },
  },
}
```

### Custom LSP Setup Function

```lua
local _util = require("lspconfig.util")

return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      custom_server = {
        setup = function()
          local root_pattern = _util.root_pattern(".git", "package.json")
          return {
            cmd = { "custom-lsp", "--stdio" },
            root_dir = root_pattern(vim.fn.expand("%:p")),
            on_attach = function(client, buffer)
              vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = buffer, desc = "Go to Definition" })
            end,
          }
        end,
      },
    },
  },
}
```

## Error Handling

```lua
local ok, mymodule = pcall(require, "optional_module")
if ok then mymodule.setup() end

if vim.v.shell_error ~= 0 then
  vim.api.nvim_echo({{"Error\n", "ErrorMsg"}, {details, "WarningMsg"}}, true, {})
  vim.fn.getchar()
  os.exit(1)
end
```

## Best Practices

1. **Always format Lua with stylua** before committing
2. **Use `opts` for plugin configuration**, avoid `config` unless you need
   post-setup logic
3. **Use descriptive keymap descriptions** (`desc = "..."`)
4. **Lazy-load plugins** when possible using `event`, `cmd`, `keys`, or `ft`
5. **Use type annotations** for better IDE support
6. **Test changes** by restarting Neovim or running `:Lazy sync`
7. **Check `:checkhealth`** after plugin changes
