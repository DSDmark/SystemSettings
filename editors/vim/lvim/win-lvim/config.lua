-- Enable powershell as your default shell
vim.opt.shell = "pwsh.exe -NoLogo"
vim.opt.shellcmdflag =
"-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
vim.cmd [[
		let &shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
		let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
		set shellquote= shellxquote=
  ]]

-- variables
local current_project_path = vim.fn.getcwd()
local format = require "lvim.lsp.null-ls.formatters"
local lint = require "lvim.lsp.null-ls.linters"

-- plugins
lvim.plugins = {
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle",
  },
  {
    "mrjones2014/nvim-ts-rainbow",
  },
  { "dracula/vim" },
  {
    "norcalli/nvim-colorizer.lua",
    event = "BufRead",
    config = function()
      vim.defer_fn(function()
        require("colorizer").setup({
          "css",
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact"
        }, { mode = "foreground" })
      end, 100)
    end,
  },
  {
    "sindrets/diffview.nvim",
    event = "BufRead",
  },
  {
    "f-person/git-blame.nvim",
    event = "BufRead",
    config = function()
      vim.cmd "highlight default link gitblame SpecialComment"
      require("gitblame").setup { enabled = false }
    end,
  },
}

table.insert(lvim.plugins, {
  "zbirenbaum/copilot-cmp",
  event = "InsertEnter",
  dependencies = { "zbirenbaum/copilot.lua" },
  config = function()
    vim.defer_fn(function()
      require("copilot").setup()
      require("copilot_cmp").setup()
    end, 100)
  end,
})

-- set a formatter, this will override the language server formatting capabilities (if it exists)
format.setup {
  { command = "black", filetypes = { "python" } },
  { command = "isort", filetypes = { "python" } },
  {
    command = "prettier",
    -- extra_args = { "--line-width=80", "--double-quote", "--semi", "--jsx-double-quote",
    --   "--bracket-same-line", "--arrow-parens=avoid", },
    filetypes = {
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "vue",
      "css",
      "scss",
      "less",
      "html",
      "json",
      "jsonc",
      "yaml",
      "markdown",
      "markdown.mdx",
      "graphql",
      "handlebars",
    },
  },
}

-- linting for js and ts files using eslint
lint.setup {
  {
    command = "eslint",
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "html", "yaml", "markdown", "markdown.mdx", "graphql", "handlebars" },
  }
}

vim.cmd [[
  autocmd FileType lua nnoremap <buffer> <leader>l :Codi<CR>
]]

--[[
Set a compatible clipboard manager
Note: if clipboard not work then install xclip like  sudo apt install xclip
]]

vim.g.clipboard = {
  copy = {
    ["+"] = "win32yank.exe -i --crlf",
    ["*"] = "win32yank.exe -i --crlf",
  },
  paste = {
    ["+"] = "win32yank.exe -o --lf",
    ["*"] = "win32yank.exe -o --lf",
  },
}

-- auto completion tag for jsx and html
lvim.keys.normal_mode["<C-s>"] = "<cmd>echo 'This is <C-s> in normal mode'<CR>"
lvim.keys.visual_mode["<C-s>"] = "<cmd>echo 'This is <C-s> in visual mode'<CR>"
lvim.keys.insert_mode["<C-s>"] = [[<C-\><C-n>yiwi<lt><esc>ea></><esc>hpF>i<C-\><C-n>:normal zz<CR>]]

-- general theme configuration
-- lvim.use_icons = false
lvim.log.level = "warn"
lvim.colorscheme = "lunar"
lvim.builtin.nvimtree.setup.view.width = 10
lvim.format_on_save.enabled = true
lvim.builtin.lualine.options.fontSize = 10
lvim.builtin.treesitter.rainbow.enable = true

-- keymapping configuration
lvim.leader = ","
-- adding the jj key for normal_mode
lvim.keys.insert_mode["jj"] = "<Esc>"
-- toggling terminal popup
lvim.keys.normal_mode["<leader>3"] = ":ToggleTerm<CR>"
-- adding the save file key
lvim.keys.normal_mode["<leader>w"] = ":w<CR>"

lvim.keys.normal_mode["<leader>c"] = ":x<CR>"
-- add your own keymapping
lvim.keys.normal_mode["<leader>t"] = ":tabedit %<CR>:NvimTreeToggle<CR>"
-- toggle the text wrap
lvim.keys.normal_mode["<leader>z"] = ":set wrap!<CR>"
-- jumptotab function
lvim.keys.normal_mode["<leader><Tab>"] = ":lua JumpToTab()<CR>"
-- showing all message including error and others
lvim.keys.normal_mode["<leader>m"] = ":lua ShowWarningMess()<CR>"
-- toggle git blame keymapping
lvim.keys.normal_mode["<leader>bg"] = ":GitBlameToggle<CR>"
-- menu keymappings for incearing and decearing
lvim.keys.normal_mode["<C-A>"] = ":vertical resize +2<CR>"
lvim.keys.normal_mode["<C-S>"] = ":vertical resize -2<CR>"

--[[ Customs function used above keymappings. function for see and copy the error messages ]]
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
