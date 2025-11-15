local T = {}

T.setup = function()
  local buf_mark = require('buf-mark')

  vim.keymap.set(
    'n',
    '<leader>m',
    function()
      -- The next character typed will be the buffer mark character to use
      local char = vim.fn.getcharstr()
      buf_mark.set(char)
    end,
    { desc = 'BufMark: Set' }
  )

  vim.keymap.set(
    'n',
    '<leader>M',
    function()
      -- The next character typed will be the buffer mark character to use
      local char = vim.fn.getcharstr()
      buf_mark.delete(char)
    end,
    { desc = 'BufMark: Delete' }
  )

  vim.keymap.set(
    'n',
    "<leader>'",
    function()
      -- The next character typed will be the buffer mark character to use
      local char = vim.fn.getcharstr()
      buf_mark.goto(char)
    end,
    { desc = 'BufMark: Goto' }
  )

  vim.keymap.set(
    'n',
    "<leader>'/",
    ':b#<cr>',
    { desc = 'BufMark: Goto alternate buffer' }
  )

  vim.keymap.set(
    'n',
    "<leader>'?",
    buf_mark.list_pretty,
    { desc = 'BufMark: List' }
  )
end

return T
