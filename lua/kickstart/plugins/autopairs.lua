-- autopairs
-- https://github.com/windwp/nvim-autopairs

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  opts = {},
  config = function(_, opts)
    local npairs = require("nvim-autopairs")
    npairs.setup(opts)

    -- Disable backtick and single-quote pairing for q/k files
    for _, char in ipairs({ "`", "'" }) do
      for _, rule in ipairs(npairs.get_rules(char)) do
        rule.not_filetypes = rule.not_filetypes or {}
	vim.list_extend(rule.not_filetypes, { "q", "k" })
      end
    end
    return opts
  end,
}
