return {
  'coder/claudecode.nvim',
  dependencies = { 'folke/snacks.nvim' },
  opts = {
    terminal = {
      provider = 'external',
      provider_opts = {
        external_terminal_cmd = 'echo %s',
      },
    },
    auto_start = true,
    port_range = {
      min = 30000,
      max = 30199,
    },
    focus_after_send = true,
    log_level = 'info',
    diff_opts = {
      layout = 'vertical',
    },
  },
  keys = {
    { '<leader>ac', '<cmd>ClaudeCodeStart<cr>', desc = 'Claude Code Start' },
    { '<leader>aq', '<cmd>ClaudeCodeStop<cr>', desc = 'Claude Code Stop' },
    { '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', desc = 'Send Buffer to Claude' },
    { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send Selection to Claude' },
    { '<leader>ast', '<cmd>ClaudeCodeStatus<cr>', desc = 'Claude Code Status' },
    { '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Claude Code Accept Diff' },
    { '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Claude code Deny Diff' },
  },
}
