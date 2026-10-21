-- LazyVim extras that should only load in the work profile.
--
-- This module is imported before the shared `plugins` module (see
-- `lua/config/lazy.lua`) so lazy.nvim's import-order check stays valid.
-- `lang.java` lives here instead of `lazyvim.json` so the personal machine
-- does not load Java tooling.
return {
  { import = "lazyvim.plugins.extras.lang.java" },
}
