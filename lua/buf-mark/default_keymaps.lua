local T = {}

T.setup = function()
  local buf_mark = require('buf-mark')
  vim.keymap.set('n', "<leader>'", buf_mark.goto, { desc = 'BufMark: Goto' })
  vim.keymap.set('n', '<leader>m', buf_mark.set, { desc = 'BufMark: Set' })
  vim.keymap.set('n', "<leader>M", buf_mark.delete, { desc = 'BufMark: Delete' })
end

return T
