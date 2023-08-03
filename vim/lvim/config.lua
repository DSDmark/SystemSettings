-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

-- Pluging configurations
-- Plugins for troubleshotinP
lvim.plugins = {
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle",
  },
  { "dracula/vim" },
  {
    "rrethy/vim-hexokinase",
    cmd = "",

  },
}

lvim.builtin.hexokinase = {
  enabled = true,
  options = {
    highlighters = { "virtual" },
  }
}

-- general theme configuration
lvim.log.level = "warn"
lvim.colorscheme = "lunar"
lvim.builtin.nvimtree.setup.view.width = 10
lvim.format_on_save.enabled = true
lvim.builtin.lualine.options.fontSize = 10

-- lvim.use_icons = false
-- note if clipboard not work then install xclip like  sudo apt install xclip

-- keymapping configuration
lvim.leader = ","
-- adding the jj key for normal_mode
lvim.keys.insert_mode["jj"] = "<Esc>"
-- toggling terminal popup
lvim.keys.normal_mode["<leader>3"] = ":ToggleTerm<CR>"
-- adding the save file key
lvim.keys.normal_mode["<leader>w"] = ":w<CR>"
-- add your own keymapping
lvim.keys.normal_mode["<leader>t"] = ":tabedit %<CR>:NvimTreeToggle<CR>"
-- toggle the text wrap
lvim.keys.normal_mode["<leader>z"] = ":set wrap!<CR>"
-- jumptotab function
lvim.keys.normal_mode["<leader><Tab>"] = ":lua JumpToTab()<CR>"
-- showing all message including error and others
lvim.keys.normal_mode["<leader>m"] = ":lua ShowWarningMess()<CR>"
-- menu keymappings for incearing and decearing
lvim.keys.normal_mode["<C-A>"] = ":vertical resize +2<CR>"
lvim.keys.normal_mode["<C-S>"] = ":vertical resize -2<CR>"

-- set a formatter, this will override the language server formatting capabilities (if it exists)
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { command = "black", filetypes = { "python" } },
  { command = "isort", filetypes = { "python" } },
  {
    command = "prettier",
    ---@usage arguments to pass to the formatter
    extra_args = { "--line-width=80", "--single-quote", "--no-semi", "--jsx-single-quote",
      "--bracket-same-line", "--arrow-parens=avoid" },
    ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "css", "scss", "less", "html",
      "json", "jsonc", "yaml", "markdown", "markdown.mdx", "graphql", "handlebars" },
  },
}

-- function used above keymappings
-- function for see and copy the error messages
function ShowWarningMess()
  local line_number = vim.fn.line('.')
  local diagnostics = vim.diagnostic.get(0, { lnum = line_number - 1 })
  if diagnostics and #diagnostics > 0 then
    local output = diagnostics[1].message
    print(output)
    -- copying into system clipboard through register
    vim.fn.setreg("+", output)
  else
    print("No diagnostics found for line " .. line_number)
  end
end

-- function for jumping defferent opened tabs in lvim
function JumpToTab()
  local tabNum = vim.fn.input("😋 Enter you tab:")

  if tabNum ~= "" then
    vim.cmd(":bn" .. tabNum)
  else
    vim.cmd(":bp")
  end
end
