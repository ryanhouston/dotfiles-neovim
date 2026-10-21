-- Work-machine setup, run from `init.lua` before plugins load.
local M = {}

function M.setup()
  -- Force a global node version for the work toolchain within neovim
  vim.env.HNVM_NODE = "22.13.1"
end

return M
