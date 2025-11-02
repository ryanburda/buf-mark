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

  if not path then
    vim.api.nvim_echo({{"Buf Mark not set", "ErrorMsg"}}, true, {})
    return
  end

  local bufnr = vim.fn.bufnr(path)

  if bufnr ~= -1 then
    -- If the buffer exists, switch to it
    vim.api.nvim_set_current_buf(bufnr)
  else
    -- Otherwise, open the file in a new buffer
    vim.cmd('edit ' .. vim.fn.fnameescape(path))
  end
end

-- Lists all buffer marks
T.list_marks = function()
  -- Collect all marks and sort them
  local mark_list = {}
  for char, path in pairs(T.marks) do
    table.insert(mark_list, {char = char, path = path})
  end

  -- Sort by character
  table.sort(mark_list, function(a, b) return a.char < b.char end)

  if #mark_list == 0 then
    vim.api.nvim_echo({{"No buffer marks set", "WarningMsg"}}, true, {})
    return
  end

  -- Build output lines
  local lines = {}
  for _, mark in ipairs(mark_list) do
    -- Get relative path or full path
    local display_path = vim.fn.fnamemodify(mark.path, ':~:.')

    local line = string.format(" %s    %s", mark.char, display_path)
    table.insert(lines, line)
  end

  -- Display in a message
  local output = {
    {"mark  file", "Title"},
    {"\n" .. table.concat(lines, "\n"), "Normal"}
  }
  vim.api.nvim_echo(output, true, {})
end

T.setup = function(opts)
  opts = opts or {}

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

  -- Register the :BufMarks command
  vim.api.nvim_create_user_command('BufMarks', function()
    T.list_marks()
  end, { desc = 'List all buffer marks' })

  -- Setup keymaps if not disabled
  if opts.keymaps ~= false then
    if opts.swap_native_mark_keymaps then
      -- Use m and ' for buffer marks
      vim.keymap.set('n', 'm', function()
        local char = vim.fn.getcharstr()
        T.set_mark(char)
      end, { desc = 'Set buffer mark' })

      vim.keymap.set('n', "'", function()
        local char = vim.fn.getcharstr()
        T.goto_mark(char)
      end, { desc = 'Go to buffer mark' })

      -- Remap native marks to use <leader>
      vim.keymap.set('n', '<leader>m', function()
        local char = vim.fn.getcharstr()
        local ok, err = pcall(vim.cmd, 'normal! m' .. char)
        if not ok then
          local vim_err = err:match("Vim%([^)]+%):(.*)") or err
          vim.api.nvim_echo({{vim_err, "ErrorMsg"}}, true, {})
        end
      end, { desc = 'Set native vim mark' })

      vim.keymap.set('n', "<leader>'", function()
        local char = vim.fn.getcharstr()
        local ok, err = pcall(vim.cmd, "normal! '" .. char)
        if not ok then
          local vim_err = err:match("Vim%([^)]+%):(.*)") or err
          vim.api.nvim_echo({{vim_err, "ErrorMsg"}}, true, {})
        end
      end, { desc = 'Go to native vim mark' })
    else
      -- Default: use <leader> for buffer marks
      vim.keymap.set('n', '<leader>m', function()
        local char = vim.fn.getcharstr()
        T.set_mark(char)
      end, { desc = 'Set buffer mark' })

      vim.keymap.set('n', "<leader>'", function()
        local char = vim.fn.getcharstr()
        T.goto_mark(char)
      end, { desc = 'Go to buffer mark' })
    end
  end
end

return T
