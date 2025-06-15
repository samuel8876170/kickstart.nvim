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
      local keymapper = require('nvim-keymapper')
      keymapper.set('n', '<leader>sf', require('telescope.builtin').find_files, {}, 'Find files')
      keymapper.set('n', '<leader>sg', require('telescope.builtin').live_grep, {}, 'Live grep')
    end,
  },
  -- nvim-keymapper: fuzzy search for keymaps
  {
    "bgrohman/nvim-keymapper",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension("nvim-keymapper")
      local keymapper = require('nvim-keymapper')
      vim.api.nvim_create_user_command('Keymaps', keymapper.keymaps_picker, {desc = 'Telescope: Show keymaps'})
      keymapper.set('n', '<leader>sk', ':Keymaps<CR>', {}, 'Search keymaps')
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
      local keymapper = require('nvim-keymapper')
      keymapper.set('n', '<leader>dcon', dap.continue, {}, 'Continue debugging')
      keymapper.set('n', '<leader>dov', dap.step_over, {}, 'Step over')
      keymapper.set('n', '<leader>din', dap.step_into, {}, 'Step into')
      keymapper.set('n', '<leader>dou', dap.step_out, {}, 'Step out')
      keymapper.set('n', '<leader>db', dap.toggle_breakpoint, {}, 'Toggle breakpoint')
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
local keymapper = require('nvim-keymapper')
keymapper.set('n', '<leader>tsw', ':!tmux split-window -h<CR>', { silent = true }, 'Open tmux terminal')
keymapper.set('n', '<C-d>', '<C-d>zz', {noremap = false, silent = true}, 'Page down to center')
keymapper.set('n', '<C-u>', '<C-u>zz', {noremap = false, silent = true}, 'Page up to center')
keymapper.set('n', 'n', 'nzzzv', {noremap = false, silent = true}, 'Next search to center')
keymapper.set('n', 'N', 'Nzzzv', {noremap = false, silent = true}, 'Previous search to center')

-- You can add more settings here, such as:
vim.opt.number = true
vim.opt.relativenumber = true
-- etc.
