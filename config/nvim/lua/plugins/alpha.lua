-- ~/.config/nvim/lua/plugins/alpha.lua
-- Requiere lazy.nvim. Dashboard con banner ASCII + colores pywal.
return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    dashboard.section.header.val = {
      " ▗▄▄▖▗▖ ▗▖ ▗▄▄▖▗▖ ▗▖▗▖   ▗▄▄▄▖ ▗▄▄▖  ▄▄▄▖   ▗▖  ▗▖▗▄▄▄▖▗▖  ▗▖",
      "▐▌   ▐▌ ▐▌▐▌   ▐▌▗▞▘▐▌   ▐▌   ▐▌   ▐▌       ▐▌  ▐▌  █  ▐▛▚▞▜▌",
      " ▝▀▚▖▐▌ ▐▌▐▌   ▐▛▚▖ ▐▌   ▐▛▀▀▘ ▝▀▚▖ ▝▀▚▖    ▐▌  ▐▌  █  ▐▌  ▐▌",
      "▗▄▄▞▘▝▚▄▞▘▝▚▄▄▖▐▌ ▐▌▐▙▄▄▖▐▙▄▄▖▗▄▄▞▘▗▄▄▞▘     ▝▚▞▘ ▗▄█▄▖▐▌  ▐▌",
      "",
      "",
    }
    dashboard.section.header.opts.hl = "AlphaHeader"

    dashboard.section.buttons.val = {
      dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
      dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
      dashboard.button("g", "  Live grep", ":Telescope live_grep <CR>"),
      dashboard.button("r", "  Recent files", ":Telescope oldfiles <CR>"),
      dashboard.button("c", "  Config", ":e $MYVIMRC <CR>"),
      dashboard.button("q", "  Quit", ":qa<CR>"),
    }
    for _, button in ipairs(dashboard.section.buttons.val) do
      button.opts.hl = "AlphaButtons"
      button.opts.hl_shortcut = "AlphaHeader"
    end

    dashboard.section.footer.val = "vim ricing setup"
    dashboard.section.footer.opts.hl = "AlphaFooter"

    dashboard.opts.opts.noautocmd = true
    alpha.setup(dashboard.opts)
  end,
}
