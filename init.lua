-- init.lua for Neovim 0.9.0 with Lazy plugin manager

-- Prerequisites:
-- - ripgrep for Telescope live_grep
-- - tmux for vim-slime
-- - LSP servers: clangd for C/C++, pyright for Python
-- - Debug adapters: codelldb for C/C++, debugpy for Python
-- - Linters: clang for C/C++, flake8 for Python
-- Make sure these are installed and accessible in your PATH

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out, "WarningMsg" }, { "\nPress any key to exit..." } }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Set leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim with plugins
require("lazy").setup({
  -- Telescope: fuzzy file finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require('telescope').setup{
        defaults = {
          -- Default configuration for Telescope
        },
      }
      -- Keymaps for Telescope
      vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, {})
      vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, {})
    end,
  },
  -- vim-slime: send text to tmux terminal
  {
    "jpalardy/vim-slime",
    config = function()
      vim.g.slime_target = "tmux"
      vim.cmd([[
        let g:slime_no_mappings = 1
        xmap <leader>ss <Plug>SlimeRegionSend
        nmap <leader>sl <Plug>SlimeLineSend
      ]])
    end,
  },
  -- LSP: language server protocol
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require('lspconfig')
      -- Setup clangd for C/C++
      lspconfig.clangd.setup{}
      -- Setup pyright for Python
      lspconfig.pyright.setup{}
    end,
  },
  -- DAP: debugging
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require('dap')
      -- Example configuration for Python
      dap.adapters.python = {
        type = 'executable',
        command = 'python',
        args = { '-m', 'debugpy.adapter' },
      }
      dap.configurations.python = {
        {
          type = 'python',
          request = 'launch',
          name = "Launch file",
          program = "${file}",
          pythonPath = function()
            return '/usr/bin/python'
          end,
        },
      }
      -- For C/C++, you need to set up codelldb or another adapter
      -- Example:
      -- dap.adapters.codelldb = {
      --   type = 'server',
      --   port = "${port}",
      --   executable = {
      --     command = '/path/to/codelldb',
      --     args = {"--port", "${port}"},
      --   }
      -- }
      -- dap.configurations.cpp = {
      --   {
      --     name = "Launch",
      --     type = "codelldb",
      --     request = "launch",
      --     program = function()
      --       return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      --     end,
      --     cwd = '${workspaceFolder}',
      --     stopOnEntry = false,
      --   },
      -- }
      -- Keymaps for DAP
      vim.keymap.set('n', '<leader>dcon', dap.continue)
      vim.keymap.set('n', '<leader>dov', dap.step_over)
      vim.keymap.set('n', '<leader>din', dap.step_into)
      vim.keymap.set('n', '<leader>dou', dap.step_out)
      vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint)
    end,
  },
  -- ALE: linting
  {
    "dense-analysis/ale",
    config = function()
      vim.g.ale_linters = {
        cpp = {'clang'},
        python = {'flake8'},
      }
      -- Optionally, set fixers
      vim.g.ale_fixers = {
        ['*'] = {'remove_trailing_lines', 'trim_whitespace'},
        python = {'black'},
      }
    end,
  },
  -- Treesitter: syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require'nvim-treesitter.configs'.setup {
        ensure_installed = { "c", "cpp", "python" },
        highlight = { enable = true },
      }
    end,
  },
})

-- Additional configurations
-- Open a new tmux pane with <leader>t
vim.keymap.set('n', '<leader>tsw', ':!tmux split-window -h<CR>', { silent = true })
vim.keymap.set('n', '<C-d>', '<C-d>zz', {noremap = false, silent = true})
vim.keymap.set('n', '<C-u>', '<C-u>zz', {noremap = false, silent = true})
vim.keymap.set('n', 'n', 'nzzzv', {noremap = false, silent = true})
vim.keymap.set('n', 'N', 'Nzzzv', {noremap = false, silent = true})

-- You can add more settings here, such as:
vim.opt.number = true
vim.opt.relativenumber = true
-- etc.
