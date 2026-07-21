-- ~/.config/nvim/lua/pywal.lua
-- Lee ~/.cache/wal/colors.json en vivo y arma un colorscheme básico.
-- Uso: require("pywal").load() en tu init.lua, o llamalo desde un autocmd
-- de ColorScheme para poder hacer :colorscheme pywal

local M = {}

local function read_colors()
  local path = vim.fn.expand("~/.cache/wal/colors.json")
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    vim.notify("pywal: no pude leer " .. path, vim.log.levels.WARN)
    return nil
  end
  local ok2, decoded = pcall(vim.fn.json_decode, table.concat(lines, "\n"))
  if not ok2 then
    vim.notify("pywal: colors.json invalido", vim.log.levels.WARN)
    return nil
  end
  return decoded
end

function M.load()
  local data = read_colors()
  if not data then return end

  local c = data.colors
  local bg = data.special.background
  local fg = data.special.foreground
  local cursor = data.special.cursor

  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end
  vim.o.background = "dark"
  vim.g.colors_name = "pywal"
  vim.o.termguicolors = true

  local hl = vim.api.nvim_set_hl

  -- Base
  hl(0, "Normal",       { fg = fg, bg = bg })
  hl(0, "NormalFloat",  { fg = fg, bg = c.color0 })
  hl(0, "FloatBorder",  { fg = c.color4, bg = c.color0 })
  hl(0, "CursorLine",   { bg = c.color0 })
  hl(0, "CursorLineNr", { fg = c.color4, bold = true })
  hl(0, "LineNr",       { fg = c.color8 })
  hl(0, "SignColumn",   { bg = bg })
  hl(0, "ColorColumn",  { bg = c.color0 })
  hl(0, "VertSplit",    { fg = c.color8 })
  hl(0, "WinSeparator", { fg = c.color8 })
  hl(0, "Visual",       { bg = c.color8 })
  hl(0, "Search",       { fg = bg, bg = c.color3 })
  hl(0, "IncSearch",    { fg = bg, bg = c.color1 })
  hl(0, "Pmenu",        { fg = fg, bg = c.color0 })
  hl(0, "PmenuSel",     { fg = bg, bg = c.color4 })
  hl(0, "StatusLine",   { fg = fg, bg = c.color0 })
  hl(0, "StatusLineNC", { fg = c.color8, bg = c.color0 })
  hl(0, "TabLineSel",   { fg = bg, bg = c.color4 })
  hl(0, "MatchParen",   { fg = c.color3, bold = true })

  -- Sintaxis
  hl(0, "Comment",      { fg = c.color8, italic = true })
  hl(0, "Constant",     { fg = c.color5 })
  hl(0, "String",       { fg = c.color2 })
  hl(0, "Character",    { fg = c.color2 })
  hl(0, "Number",       { fg = c.color5 })
  hl(0, "Boolean",      { fg = c.color5 })
  hl(0, "Identifier",   { fg = c.color6 })
  hl(0, "Function",     { fg = c.color4, bold = true })
  hl(0, "Statement",    { fg = c.color1, bold = true })
  hl(0, "Keyword",      { fg = c.color1 })
  hl(0, "Conditional",  { fg = c.color1 })
  hl(0, "Repeat",       { fg = c.color1 })
  hl(0, "PreProc",      { fg = c.color3 })
  hl(0, "Type",         { fg = c.color3 })
  hl(0, "Special",      { fg = c.color6 })
  hl(0, "Underlined",   { fg = c.color4, underline = true })
  hl(0, "Error",        { fg = c.color1, bold = true })
  hl(0, "Todo",         { fg = bg, bg = c.color3, bold = true })

  -- Diagnostics (LSP)
  hl(0, "DiagnosticError", { fg = c.color1 })
  hl(0, "DiagnosticWarn",  { fg = c.color3 })
  hl(0, "DiagnosticInfo",  { fg = c.color4 })
  hl(0, "DiagnosticHint",  { fg = c.color6 })

  -- Git signs (si usás gitsigns.nvim)
  hl(0, "GitSignsAdd",    { fg = c.color2 })
  hl(0, "GitSignsChange", { fg = c.color3 })
  hl(0, "GitSignsDelete", { fg = c.color1 })

  vim.api.nvim_set_hl(0, "AlphaHeader",  { fg = c.color4 })
  vim.api.nvim_set_hl(0, "AlphaButtons", { fg = fg })
  vim.api.nvim_set_hl(0, "AlphaFooter",  { fg = c.color8, italic = true })
end

-- Listen for SIGUSR1 and reload the pywal colorscheme live when it arrives
-- (send it from your wallpaper script: pkill -USR1 nvim)
local signal = vim.loop.new_signal()
if signal then
  signal:start("sigusr1", vim.schedule_wrap(function()
    M.load()
    vim.notify("pywal colors reloaded", vim.log.levels.INFO)
  end))
end

return M
