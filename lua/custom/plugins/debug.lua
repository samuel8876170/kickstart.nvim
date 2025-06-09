-- https://github.com/Shatur/neovim-tasks
return {
  'Shatur/neovim-tasks',
  dependencies = { 'nvim-lua/plenary.nvim', 'nvim-lualine/lualine.nvim' },
  event = 'VeryLazy',
  config = function()
    local Path = require 'plenary.path'
    require('tasks').setup {
      default_params = { -- Default module parameters with which `neovim.json` will be created.
        cmake = {
          cmd = 'cmake', -- CMake executable to use, can be changed using `:Task set_module_param cmake cmd`.
          build_type = 'Debug', -- Build type, can be changed using `:Task set_module_param cmake build_type`.
          build_kit = 'default', -- default build kit, can be changed using `:Task set_module_param cmake build_kit`.
          dap_name = 'codelldb', -- DAP configuration name from `require('dap').configurations`. If there is no such configuration, a new one with this name as `type` will be created.
          build_dir = tostring(Path:new('{cwd}', 'build')), -- '{build_kit}', '{build_type}')), -- Build directory. The expressions `{cwd}`, `{build_kit}` and `{build_type}` will be expanded with the corresponding text values. Could be a function that return the path to the build directory.
          cmake_kits_file = nil, -- set path to JSON file containing cmake kits
          cmake_build_types_file = nil, -- set path to JSON file containing cmake kits
          clangd_cmdline = {
            'clangd',
            '--background-index',
            '--clang-tidy',
            '--header-insertion=never',
            '--completion-style=detailed',
            '--offset-encoding=utf-8',
            '--pch-storage=memory',
            '--cross-file-rename',
            '-std=c++26',
            '-j=4',
          }, -- command line for invoking clangd - this array will be extended with --compile-commands-dir and --query-driver after each cmake configure with parameters inferred from build_kit, build_type and build_dir
        },
        zig = {
          cmd = 'zig', -- zig command which will be invoked
          dap_name = 'codelldb', -- DAP configuration name from `require('dap').configurations`. If there is no such configuration, a new one with this name as `type` will be created.
          build_type = 'Debug', -- build type, can be changed using `:Task set_module_param zig build_type`
          build_step = 'install', -- build step, cah be changed using `:Task set_module_param zig build_step`
        },
        cargo = {
          dap_name = 'codelldb', -- DAP configuration name from `require('dap').configurations`. If there is no such configuration, a new one with this name as `type` will be created.
        },
        npm = {
          cmd = 'npm', -- npm command which will be invoked. If using yarn or pnpm, change here.
          working_directory = vim.loop.cwd(), -- working directory in which NPM will be invoked
        },
        make = {
          cmd = 'make', -- make command which will be invoked
          args = {
            all = { '-j10', 'all' }, -- :Task start make all   → make -j10 all
            build = {}, -- :Task start make build → make
            nuke = { 'clean' }, -- :Task start make nuke  → make clean
          },
        },
      },
      save_before_run = true,
      params_file = 'neovim.json',
      quickfix = {
        pos = 'botright',
        height = 12,
        only_on_error = false,
      },
      dap_open_command = function()
        return require('dap').repl.open()
      end,
    }

    vim.keymap.set('n', '<leader>cC', [[:Task start cmake configure<cr>]], { silent = true })
    vim.keymap.set('n', '<leader>cD', [[:Task start cmake configureDebug<cr>]], { silent = true })
    vim.keymap.set('n', '<leader>cP', [[:Task start cmake reconfigure<cr>]], { silent = true })
    vim.keymap.set('n', '<leader>cT', [[:Task start cmake ctest<cr>]], { silent = true })
    vim.keymap.set('n', '<leader>cK', [[:Task start cmake clean<cr>]], { silent = true })
    vim.keymap.set('n', '<leader>ct', [[:Task set_module_param cmake target<cr>]], { silent = true })
    vim.keymap.set('n', '<C-c>', [[:Task cancel<cr>]], { silent = true })
    vim.keymap.set('n', '<leader>cr', [[:Task start cmake run<cr>]], { silent = true })
    vim.keymap.set('n', '<F7>', [[:Task start cmake debug<cr>]], { silent = true })
    vim.keymap.set('n', '<leader>cb', [[:Task start cmake build<cr>]], { silent = true })
    vim.keymap.set('n', '<leader>cB', [[:Task start cmake build_all<cr>]], { silent = true })

    -- open ccmake in embedded terminal
    local function openCCMake()
      local build_dir = tostring(require('tasks.cmake_utils.cmake_utils').getBuildDir())
      vim.cmd([[bo sp term://ccmake ]] .. build_dir)
    end
    vim.keymap.set('n', '<leader>cc', openCCMake, { silent = true })

    -- if project is using presets, provide preset selection for both <leader>cv and <leader>ck
    -- if not, provide build type (<leader>cv) and kit (<leader>ck) selection

    local function selectPreset()
      local availablePresets = cmake_presets.parse 'buildPresets'

      vim.ui.select(availablePresets, { prompt = 'Select build preset' }, function(choice, idx)
        if not idx then
          return
        end
        local projectConfig = ProjectConfig:new()
        if not projectConfig['cmake'] then
          projectConfig['cmake'] = {}
        end

        projectConfig['cmake']['build_preset'] = choice

        -- autoselect will invoke projectConfig:write()
        cmake_utils.autoselectConfigurePresetFromCurrentBuildPreset(projectConfig)
      end)
    end

    local function selectBuildKitOrPreset()
      if cmake_utils.shouldUsePresets() then
        selectPreset()
      else
        tasks.set_module_param('cmake', 'build_kit')
      end
    end

    vim.keymap.set('n', '<leader>ck', selectBuildKitOrPreset, { silent = true })

    local function selectBuildTypeOrPreset()
      if cmake_utils.shouldUsePresets() then
        selectPreset()
      else
        tasks.set_module_param('cmake', 'build_type')
      end
    end

    vim.keymap.set('n', '<leader>cv', selectBuildTypeOrPreset, { silent = true })

    local lualine = require 'lualine'
    local ProjectConfig = require 'tasks.project_config'

    local function cmakeStatus()
      local cmake_config = ProjectConfig:new()['cmake']
      local cmakelists_dir = cmake_config.source_dir and cmake_config.source_dir or vim.loop.cwd()
      if (Path:new(cmakelists_dir) / 'CMakeLists.txt'):exists() then
        local cmake_utils = require 'tasks.cmake_utils.cmake_utils'

        if cmake_utils.shouldUsePresets(cmake_config) then
          local preset = cmake_config.build_preset or 'not selected'
          local cmakeTarget = cmake_config.target and cmake_config.target or 'all'

          return 'CMake preset: ' .. preset .. ', target: ' .. cmakeTarget
        else
          local cmakeBuildType = cmake_config.build_type or 'not selected'
          local cmakeKit = cmake_config.build_kit or 'not selected'
          local cmakeTarget = cmake_config.target or 'all'

          return 'CMake variant: ' .. cmakeBuildType .. ', kit: ' .. cmakeKit .. ', target: ' .. cmakeTarget
        end
      else
        return ''
      end
    end

    lualine.setup {
      sections = {
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { 'encoding', 'fileformat', 'filetype', cmakeStatus },
      },
    }
  end,
}
