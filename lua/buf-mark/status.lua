--[[
Shows buf-marks for buffers that are currently open.
  - Highlights the current buffers mark
  - Indicates if current buffer does not have a mark
  - Marks are shown in alphabetical order
  - Can be used in places like tabline or statusline
]]
local M = {}

Info = ''

local function update()
  local s = ''

  -- Get buf-marks
  local marks = require('buf-mark').list() or {}
  local sorted_marks = {}
  for mark_char, mark_path in pairs(marks) do
    table.insert(sorted_marks, {char = mark_char, path = mark_path})
  end
  table.sort(sorted_marks, function(a, b) return a.char < b.char end)

  -- Get buffers
  local open_bufs = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      table.insert(open_bufs, bufnr)
    end
  end

  local current_buf_name = vim.api.nvim_buf_get_name(0)
  local current_buf_is_marked = false

  -- Loop through marks
  for _, mark in ipairs(sorted_marks) do
    -- Loop through buffers
    for _, bufnr in ipairs(open_bufs) do
      local buf_name = vim.api.nvim_buf_get_name(bufnr)
      if mark.path == buf_name then
        if mark.path == current_buf_name then
          s = s .. '%#TabLineSel#'
          current_buf_is_marked = true
        else
          s = s .. '%#TabLine#'
        end
        s = s .. ' ' .. mark.char .. ' '
      end
    end
  end

  -- Show current buffer if not already shown
  if not current_buf_is_marked then
    s = s .. '%#DiffText#  '
  end

  Info = s .. '%*'
end

function M.setup()
  -- Listen for specific events to know when to update.
  vim.api.nvim_create_autocmd('User', {
    pattern = 'BufMarkChanged',
    callback = update
  })

  vim.api.nvim_create_autocmd('BufEnter', {
    callback = update
  })
end

function M.get()
  return Info
end

return M
