-- bootstrap lazy.nvim, LazyVim and your plugins
local profile = require("config.profile")

-- apply any profile-specific setup before plugins load
local ok, spec = pcall(require, "profiles." .. profile.name)
if ok and spec.setup then
  spec.setup()
end

require("config.lazy")

vim.api.nvim_create_user_command("DiffOrig", function()
  vim.cmd("vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis")
end, {})
