return {
  'juselara1/tmutils.nvim',
  dependencies = {
    --NOTE: you can optionally add one of these dependencies if you
    --want to use a custom selector different from the default vim.ui
    --selector.
    -- 'MunifTanjim/nui.nvim',
    'nvim-telescope/telescope.nvim',
    -- 'vijaymarupudi/nvim-fzf',
  },
  config = function()
    local selectors = require 'tmutils.selectors'
    require('tmutils').setup {
      selector = {
        -- selector = selectors.vim_ui_selector,
        selector = function(opts, message, callback)
          return selectors.telescope_selector(opts, message, callback)
        end,
      },
      window = {
        repls = {
          python = {
            syntax = 'python',
            commands = function()
              return {
                ('cd %s'):format(vim.fn.getcwd()),
                'clear',
                'python',
              }
            end,
          },
          ipython = {
            syntax = 'python',
            commands = function()
              return {
                ('cd %s'):format(vim.fn.getcwd()),
                'ipython',
                'clear',
              }
            end,
          },
          compose = {
            syntax = 'sh',
            commands = function()
              return {
                ('cd %s'):format(vim.fn.getcwd()),
                'docker compose up -d',
                'docker exec -it `docker compose config --services` bash',
                'clear',
              }
            end,
          },
          kdb = {
            syntax = 'q',
            commands = function()
              return {
                ('cd %s'):format(vim.fn.getcwd()),
                'q',
                'clear',
              }
            end,
          },
        },
      },
    }

    vim.keymap.set('n', '<leader>tc', ':TmutilsConfig<CR>', {
      noremap = true,
      silent = true,
      desc = 'Setups the Tmutils pane.',
    })
    vim.keymap.set('n', '<leader>ta', ':TmutilsCapture newbuffer<CR>', {
      noremap = true,
      silent = true,
      desc = 'Captures the content of a Tmutils pane.',
    })
    vim.keymap.set('n', '<leader>tt', ':TmutilsWindow terminal<CR>', {
      noremap = true,
      silent = true,
      desc = 'Launches a Tmutils terminal.',
    })
    vim.keymap.set('n', '<leader>tr', ':TmutilsWindow repl<CR>', {
      noremap = true,
      silent = true,
      desc = 'Shows a menu to select and launch a Tmutils repl.',
    })
    vim.keymap.set('n', '<leader>td', ':TmutilsWindow delete<CR>', {
      noremap = true,
      silent = true,
      desc = 'Deletes the configured Tmutils pane.',
    })
    vim.keymap.set('n', '<leader>ts', ':TmutilsScratchToggle<CR>', {
      noremap = true,
      silent = true,
      desc = 'Opens Tmutils Scratch',
    })
    vim.keymap.set('n', '<leader>tx', ':.TmutilsSend<CR>', {
      noremap = true,
      silent = true,
      desc = 'Sends a visual selection to a Tmutils pane.',
    })
    vim.keymap.set('v', '<leader>tv', ':TmutilsSend<CR>', {
      noremap = true,
      silent = true,
      desc = 'Sends a visual selection to a Tmutils pane.',
    })
  end,
}
