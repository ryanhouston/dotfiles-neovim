-- Render Mermaid diagrams in a floating window via snacks.image.
--
-- mermaid.nvim only renders a whole `mermaid` buffer and its chafa path
-- discards the ANSI output, so `:MermaidRender` is replaced here:
--   * `mermaid` buffers render the whole buffer
--   * markdown buffers render the fenced ```mermaid block at/nearest the cursor
-- The diagram is rendered to a PNG with mmdc and shown with snacks.image.
local M = {}

local function notify(msg, level)
  vim.notify("Mermaid: " .. msg, level)
end

--- Fenced mermaid blocks in `lines`: `{ open, close, first, last }` (1-based).
---@param lines string[]
---@return {[1]:number, [2]:number, [3]:number, [4]:number}[]
local function fences(lines)
  local found = {}
  local i = 1
  while i <= #lines do
    local marker, info = lines[i]:match("^%s*(`+%s*)(%S*)")
    if not marker then
      marker, info = lines[i]:match("^%s*(~+%s*)(%S*)")
    end
    if marker and info:lower():match("^mermaid") then
      local fence = vim.trim(marker)
      local j = i + 1
      while j <= #lines and not lines[j]:match("^%s*" .. fence .. "%s*$") do
        j = j + 1
      end
      if j > #lines then
        break -- unterminated fence
      end
      found[#found + 1] = { i, j, i + 1, j - 1 }
      i = j + 1
    else
      i = i + 1
    end
  end
  return found
end

--- Mermaid source for `buf`, or nil when there is nothing to render.
---@param buf number
---@return string?
function M.source(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  if vim.bo[buf].filetype == "mermaid" then
    return table.concat(lines, "\n")
  end

  local blocks = fences(lines)
  if #blocks == 0 then
    return nil
  end

  local cursor = vim.api.nvim_win_get_cursor(0)[1]
  local pick ---@type {[1]:number, [2]:number, [3]:number, [4]:number}
  for _, block in ipairs(blocks) do
    if cursor >= block[1] and cursor <= block[2] then
      pick = block
      break
    end
  end
  if not pick then
    -- first block below the cursor, else the last one
    for _, block in ipairs(blocks) do
      if block[1] > cursor then
        pick = block
        break
      end
    end
  end
  pick = pick or blocks[#blocks]
  return table.concat(lines, "\n", pick[3], pick[4])
end

---@param png string
local function show(png)
  local term = require("snacks.image.terminal")
  term.detect(function()
    if not term.env().supported then
      vim.ui.open(png)
      return notify("terminal lacks kitty graphics support, opened the image externally", vim.log.levels.WARN)
    end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "wipe"
    local width = math.max(20, math.floor(vim.o.columns * 0.8))
    local height = math.max(10, math.floor(vim.o.lines * 0.8))
    local win = vim.api.nvim_open_win(buf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
      col = math.max(0, math.floor((vim.o.columns - width) / 2)),
      border = "rounded",
      title = " Mermaid ",
      title_pos = "center",
      style = "minimal",
    })

    local function close()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end
    vim.keymap.set("n", "q", close, { buffer = buf, nowait = true, desc = "Close Mermaid diagram" })
    vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true, desc = "Close Mermaid diagram" })

    require("snacks").image.buf.attach(buf, { src = png, inline = false, auto_resize = true })
  end)
end

function M.render()
  local buf = vim.api.nvim_get_current_buf()
  local source = M.source(buf)
  if not source or source:match("^%s*$") then
    return notify("no Mermaid source found", vim.log.levels.WARN)
  end
  if vim.fn.executable("mmdc") == 0 then
    return notify("mmdc not found (npm install -g @mermaid-js/mermaid-cli)", vim.log.levels.ERROR)
  end

  local dir = vim.fn.stdpath("cache") .. "/mermaid"
  vim.fn.mkdir(dir, "p")
  local id = vim.fn.sha256(source):sub(1, 16)
  local src = ("%s/%s.mmd"):format(dir, id)
  local png = ("%s/%s.png"):format(dir, id)
  vim.fn.writefile(vim.split(source, "\n"), src)
  pcall(os.remove, png)

  local theme = vim.o.background == "light" and "neutral" or "dark"
  local out = vim.fn.system({ "mmdc", "-i", src, "-o", png, "-b", "transparent", "-t", theme, "-s", "2" })
  if vim.v.shell_error ~= 0 or vim.fn.filereadable(png) == 0 then
    return notify("render failed: " .. (out or ""):gsub("%s+$", ""), vim.log.levels.ERROR)
  end

  show(png)
end

function M.setup()
  vim.api.nvim_create_user_command("MermaidRender", function()
    M.render()
  end, { force = true, desc = "Render the Mermaid diagram in a floating window" })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "mermaid",
    callback = function()
      local map = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { buffer = 0, desc = desc })
      end

      map("<leader>mp", "<cmd>MermaidPreview<CR>", "Mermaid Preview")
      map("<leader>mf", "<cmd>MermaidFormat<CR>", "Mermaid Format")
      map("<leader>mr", function()
        M.render()
      end, "Mermaid Render")
      map("<leader>mc", "<cmd>MermaidCopyURL<CR>", "Mermaid Copy URL")
      map("<leader>mx", "<cmd>MermaidPreviewStop<CR>", "Mermaid Stop Preview")
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown" },
    callback = function()
      vim.keymap.set("n", "<leader>mr", function()
        M.render()
      end, { buffer = 0, desc = "Mermaid Render" })
    end,
  })
end

return M
