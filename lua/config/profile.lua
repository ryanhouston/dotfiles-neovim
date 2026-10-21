-- Determines which environment-specific profile is active.
--
-- This repo is shared between machines, but some plugins/settings only make
-- sense in one environment (e.g. work). Profile-specific specs live in
-- `lua/profiles/<name>/` and are only imported for the active profile.
--
-- Precedence:
--   1. `$NVIM_PROFILE` environment variable
--   2. `<config>/profile.local` (gitignored, one line: the profile name)
--   3. hostname map below
--   4. "personal" (default)
local M = {}

local hostname_map = {
  ["harpua-t14"] = "personal",
  -- ["work-machine-hostname"] = "work",
}

---@return string?
local function from_env()
  local profile = vim.env.NVIM_PROFILE
  return (profile and profile ~= "") and profile or nil
end

---@return string?
local function from_file()
  local path = vim.fn.stdpath("config") .. "/profile.local"
  if vim.fn.filereadable(path) == 1 then
    local line = vim.fn.readfile(path)[1]
    local profile = line and vim.trim(line) or ""
    return profile ~= "" and profile or nil
  end
end

---@return string?
local function from_hostname()
  return hostname_map[vim.uv.os_gethostname()]
end

M.name = from_env() or from_file() or from_hostname() or "personal"

return M
