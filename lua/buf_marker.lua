---Get the buffer number from a file path.
---@param path string: The full path of the file.
---@return number|nil: The buffer number or nil if not found.
local get_bufnr_by_path = function(path)
  -- Get the list of all buffer numbers
  local buffers = vim.api.nvim_list_bufs()

  -- Iterate through each buffer
  for _, buf in ipairs(buffers) do
    -- Check if the buffer has a name and compare it to the file_name
    if vim.api.nvim_buf_is_loaded(buf) then
      -- Get the buffer name (full path)
      local buf_name = vim.api.nvim_buf_get_name(buf)
      if buf_name == path then
        return buf
      end
    end
  end

  -- Return nil if no matching buffer is found
  return nil
end

T = {}

-- Dictionary mapping single characters to file paths
T.marks = {}

-- Set a mark for a character to a filepath
T.set_mark = function(char)
  T.marks[char] = vim.api.nvim_buf_get_name(0)
end

-- Deletes a mark for a character to a filepath
T.delete_mark = function(char)
  T.marks[char] = nil
end

-- Goes to the buffer associated with a character
T.goto_mark = function(char)
  local path = T.marks[char]
  local bufnr = get_bufnr_by_path(path)

  if bufnr then
    -- If the buffer exists, switch to it
    vim.api.nvim_set_current_buf(bufnr)
  else
    -- Otherwise, open the file in a new buffer
    vim.cmd('edit ' .. vim.fn.fnameescape(path))
  end
end

T.setup = function()
  -- Cursor position autocommands.
  vim.api.nvim_create_augroup('BufMarkerSaveCursorPos', { clear = true })

  -- Create an autocommand to update the last known cursor position
  vim.api.nvim_create_autocmd({'BufLeave'}, {
    group = 'BufMarkerSaveCursorPos',
    pattern = '*',
    callback = function()
      -- Get the current buffer number and the cursor position
      local bufnr = vim.api.nvim_get_current_buf()
      local cursor_position = vim.api.nvim_win_get_cursor(0)

      -- Save the cursor position to a buffer variable
      if not vim.b[bufnr].buf_marker then
        vim.b[bufnr].buf_marker = {}
      end

      vim.b[bufnr].buf_marker.last_cursor_position = cursor_position
    end,
  })
end

return T
