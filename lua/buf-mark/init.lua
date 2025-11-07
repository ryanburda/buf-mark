local T = {}

-- Dictionary mapping single characters to file paths (private)
local marks = {}

-- Configuration options
T.config = {
  persist = true
}

-- Get the storage file path for current working directory
local function get_storage_path()
  local data_dir = vim.fn.stdpath('data')
  local storage_dir = data_dir .. '/buf_mark'

  -- Create directory if it doesn't exist
  vim.fn.mkdir(storage_dir, 'p')

  -- Generate a hash of the current working directory
  local cwd = vim.fn.getcwd()
  local hash = vim.fn.sha256(cwd)

  return storage_dir .. '/' .. hash .. '.json'
end

-- Save marks to disk
local function save_marks()
  if not T.config.persist then
    return
  end

  local storage_path = get_storage_path()
  local data = {
    cwd = vim.fn.getcwd(),
    marks = marks
  }

  local json_str = vim.json.encode(data)
  local file = io.open(storage_path, 'w')
  if file then
    file:write(json_str)
    file:close()
  end
end

-- Load marks from disk
local function load_marks()
  local storage_path = get_storage_path()
  local file = io.open(storage_path, 'r')
  if not file then
    return
  end

  local content = file:read('*all')
  file:close()

  if content and content ~= '' then
    local ok, data = pcall(vim.json.decode, content)
    if ok and data and data.marks then
      marks = data.marks
    end
  end
end

-- Trigger a custom autocommand event when marks change
local function trigger_marks_changed_event()
  vim.api.nvim_exec_autocmds('User', {
    pattern = 'BufMarkChanged',
    modeline = false,
  })
end

-- Set a mark for a character to a filepath
T.set = function(char)
  marks[char] = vim.api.nvim_buf_get_name(0)
  save_marks()
  trigger_marks_changed_event()
end

-- Deletes a mark for a character to a filepath
T.delete = function(char)
  marks[char] = nil
  save_marks()
  trigger_marks_changed_event()
end

-- Deletes all marks for the current project
T.delete_all = function()
  marks = {}
  save_marks()
  trigger_marks_changed_event()
end

-- Goes to the buffer associated with a character
T.goto = function(char)
  local path = marks[char]

  if not path then
    vim.api.nvim_echo({{"Buffer Mark not set", "ErrorMsg"}}, true, {})
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

-- Returns all buffer marks as a table
T.list = function()
  return marks
end

-- Lists all buffer marks with pretty formatting
T.list_pretty = function()
  -- Collect all marks and sort them
  local mark_list = {}
  for char, path in pairs(marks) do
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

  -- Update configuration
  T.config.persist = opts.persist or true

  -- Load existing marks for this directory if persistence is enabled
  if T.config.persist then
    load_marks()
  end

  -- Cursor position autocommands.
  vim.api.nvim_create_augroup('BufMarkSaveCursorPos', { clear = true })

  -- Create an autocommand to update the last known cursor position
  vim.api.nvim_create_autocmd({'BufLeave'}, {
    group = 'BufMarkSaveCursorPos',
    pattern = '*',
    callback = function()
      -- Get the current buffer number and the cursor position
      local bufnr = vim.api.nvim_get_current_buf()
      local cursor_position = vim.api.nvim_win_get_cursor(0)

      -- Save the cursor position to a buffer variable
      if not vim.b[bufnr].buf_mark then
        vim.b[bufnr].buf_mark = {}
      end

      vim.b[bufnr].buf_mark.last_cursor_position = cursor_position
    end,
  })

  -- Register the :BufMarks command
  vim.api.nvim_create_user_command('BufMarkList', function()
    T.list_pretty()
  end, { desc = 'List all buffer marks' })

  -- Register the :BufMarkSet command
  vim.api.nvim_create_user_command('BufMarkSet', function(opts)
    local char = opts.args
    if char == '' or #char ~= 1 then
      vim.api.nvim_echo({{"Please provide a single character", "ErrorMsg"}}, true, {})
      return
    end
    T.set(char)
  end, { nargs = 1, desc = 'Set buffer mark for character' })

  -- Register the :BufMarkDelete command
  vim.api.nvim_create_user_command('BufMarkDelete', function(opts)
    local char = opts.args
    if char == '' or #char ~= 1 then
      vim.api.nvim_echo({{"Please provide a single character", "ErrorMsg"}}, true, {})
      return
    end
    T.delete(char)
  end, { nargs = 1, desc = 'Delete buffer mark for character' })

  -- Register the :BufMarkGoto command
  vim.api.nvim_create_user_command('BufMarkGoto', function(opts)
    local char = opts.args
    if char == '' or #char ~= 1 then
      vim.api.nvim_echo({{"Please provide a single character", "ErrorMsg"}}, true, {})
      return
    end
    T.goto(char)
  end, { nargs = 1, desc = 'Go to buffer mark for character' })

  -- Register the :BufMarkDeleteAll command
  vim.api.nvim_create_user_command('BufMarkDeleteAll', function()
    T.delete_all()
    vim.api.nvim_echo({{"All buffer marks deleted", "WarningMsg"}}, true, {})
  end, { desc = 'Delete all buffer marks for current project' })

  -- Setup keymaps if not disabled
  if opts.keymaps ~= false then
    vim.keymap.set(
      'n',
      '<leader>m',
      function()
        local char = vim.fn.getcharstr()
        T.set(char)
      end,
      { desc = 'BufMark: Set' }
    )

    vim.keymap.set(
      'n',
      '<leader>M',
      function()
        local char = vim.fn.getcharstr()
        T.delete(char)
      end,
      { desc = 'BufMark: Delete' }
    )

    vim.keymap.set(
      'n',
      "<leader>'",
      function()
        local char = vim.fn.getcharstr()
        T.goto(char)
      end,
      { desc = 'BufMark: Goto' }
    )

    vim.keymap.set(
      'n',
      "<leader>''",
      ':b#<cr>',
      { desc = 'BufMark: Goto alternate buffer' }
    )

    vim.keymap.set(
      'n',
      "<leader>'\"",
      T.list_pretty,
      { desc = 'BufMark: List' }
    )
  end

end

return T
