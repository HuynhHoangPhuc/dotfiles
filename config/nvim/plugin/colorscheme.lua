require("catppuccin").setup({
  integrations = {
    fzf = true,
    mini = { enable = true },
    -- copilot_vim = true,
  },
  styles = {
    conditionals = { "italic" },
    keywords = { "italic" },
    loops = { "italic" },
  },
  color_overrides = {
    mocha = {
      base = "#000000",
      mantle = "#000000",
      crust = "#000000",
    },
  }
})

vim.cmd.colorscheme("catppuccin")

-- vim.cmd.colorscheme("kanso-zen")
