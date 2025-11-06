# buf-mark

A Neovim plugin that provides vim-like marks for buffers, allowing you to quickly jump between buffers while preserving cursor positions.

## Problem

When working with multiple files in Neovim, there are typically two main approaches to switch between buffers:

1. **Sequential navigation**: Using `:bnext`, `:bprev`, and `:b#` to cycle through buffers
2. **Fuzzy finding**: Using tools like Telescope or fzf to search and select files

Both approaches have limitations:
- Sequential navigation becomes tedious when you have many buffers open - you end up spamming `:bprev` and `:bnext` to find the file you want
- Fuzzy finders require you to type out enough of the filename to narrow the results down

## Solution
Unlike vim's traditional marks which remember positions within a file, buffer marks remember entire buffers. When
you jump to a buffer mark the cursor position is automatically restored to where you last left it.

### Features
- **Buffer Marks**: Set marks to buffers using single characters (similar to vim's global marks)
- **Cursor Position Preservation**: Automatically saves and restores cursor position when leaving and entering marked buffers
- **Mark Persistence**: Optionally persist marks across Neovim sessions, saved per working directory
- **Simple API**: Easy-to-use functions for setting, deleting, and jumping to buffer marks
- **Customizable Keymaps**: Default keymaps provided, but can be disabled for custom configuration

### Differences from Native Vim Marks

| Feature | native marks | buf-marks |
|---------|------------------|----------|
| **Scope** | Position within a single file | Entire buffer/file |
| **Navigation** | Jump to specific line/column | Jump to buffer + restore cursor position |
| **Persistence** | Lost when buffer is deleted | Optionally persists across sessions |
| **Use Case** | Bookmarking locations within files | Quick buffer switching |

### Differences from Harpoon

While both buf-mark and [Harpoon](https://github.com/ThePrimeagen/harpoon) solve the buffer navigation problem, they take different approaches:

| Feature | Harpoon | buf-mark |
|---------|---------|----------|
| **Organization** | Ordered list (1, 2, 3...) | Character-based mapping (a, b, c...) |
| **Navigation** | Navigate by position in list | Navigate by mnemonic character |
| **Maintenance** | Manual ordering and list management | Set and forget individual marks |
| **Memory Aid** | Remember position in list | Remember meaningful character associations |
| **Flexibility** | Fixed positions, requires reordering | Independent marks, no ordering constraints |

## Usage

### Default Keymaps

The default keymaps mirror native marks but are prefixed with `<leader>`:
- `<leader>m{char}` - Set a buffer mark for the current buffer
- `<leader>'{char}` - Jump to the buffer associated with the mark

### Example Workflow

1. Open a file (e.g., `config.lua`)
2. Press `<leader>mc` to mark this buffer with character `c`
3. Navigate to another file
4. Press `<leader>'c` to instantly jump back to `config.lua` at the exact cursor position you left

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "ryanburda/buf-mark",
  config = function()
    require("buf-mark").setup()
  end,
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "ryanburda/buf-mark",
  config = function()
    require("buf-mark").setup()
  end,
}
```

## Configuration

### Setup Options

```lua
require("buf-mark").setup({
  -- Set to false to disable default keymaps
  keymaps = true,
  -- Set to true to persist marks between Neovim sessions
  -- Marks will be saved per working directory
  persist = true,
})
```

#### Buffer Mark Persistence

Enable buffer marks to be saved between Neovim sessions:

```lua
require("buf-mark").setup({
  persist = true,
})
```

When enabled:
- Marks are automatically saved when set or deleted
- Marks are loaded when the plugin initializes
- Each working directory has its own set of marks (e.g., marks in `~/project-a` are separate from `~/project-b`)
- Marks are stored in `~/.local/share/nvim/buf-mark/` as JSON files

### Custom Keymaps

If you prefer custom keymaps, disable the defaults and set your own:

```lua
require("buf-mark").setup({
  keymaps = false,
})

local buf_mark = require("buf-mark")

-- Custom Keymap Examples
--
-- Dynamically mapped:
-- Similar to the default keymaps, this uses `vim.fn.getcharstr()` to
-- get the buffer mark character after invoking the keymap.
-- `<leader>B{char}` to set a buffer mark
vim.keymap.set(
  'n',
  '<leader>B', function()
    -- The next character typed will be the character the buffer mark is mapped to
    local char = vim.fn.getcharstr()
    buf_mark.set(char)
  end,
  { desc = "Set buffer mark" }
)
-- `<leader>b{char}` to go to a buffer mark
vim.keymap.set(
  'n',
  '<leader>b',
  function()
    -- The next character typed will be the buffer mark to go to
    local char = vim.fn.getcharstr()
    buf_mark.goto(char)
  end,
  { desc = 'Go to buffer mark' }
)

-- Explicitly mapped:
-- If you know you are only going to use a fixed set of buffer
-- marks -- then you can configure keymaps to reflect that.
vim.keymap.set('n', '<leader>!', function() buf_mark.set('1') end)
vim.keymap.set('n', '<leader>1', function() buf_mark.goto('1') end)

vim.keymap.set('n', '<leader>@', function() buf_mark.set('2') end)
vim.keymap.set('n', '<leader>2', function() buf_mark.goto('2') end)

vim.keymap.set('n', '<leader>#', function() buf_mark.set('3') end)
vim.keymap.set('n', '<leader>3', function() buf_mark.goto('3') end)
```

## Commands

### `:BufMarkList`

Lists all buffer marks with their associated files. The output displays:
- Mark character
- File path (relative to current directory)

Example output:
```
mark  file
 a    src/config.lua
 b    README.md
 c    /path/to/file.txt
```

### `:BufMarkSet <char>`

Set a buffer mark for the current buffer using the specified character.

**Example:**
```
:BufMarkSet a
```

### `:BufMarkDelete <char>`

Delete the buffer mark for the specified character.

**Example:**
```
:BufMarkDelete a
```

### `:BufMarkGoto <char>`

Jump to the buffer associated with the specified mark character.

**Example:**
```
:BufMarkGoto a
```

### `:BufMarkDeleteAll`

Delete all buffer marks for the current project. This will clear all marks in the current working directory if buffer marks are being persisted.

**Example:**
```
:BufMarkDeleteAll
```

## API

### `setup(opts)`

Initialize the plugin with optional configuration.

**Parameters:**
- `opts` (table, optional): Configuration options
  - `keymaps` (boolean): Enable/disable default keymaps (default: `true`)
  - `persist` (boolean): Enable mark persistence between sessions, saved per working directory (default: `true`)

**Example:**
```lua
require("buf-mark").setup({
  keymaps = true,
  persist = true,
})
```

### `list()`

Display all buffer marks with their associated buffer information.

**Example:**
```lua
require("buf-mark").list()
```

### `set(char)`

Set a buffer mark for the current buffer.

**Parameters:**
- `char` (string): A single character to use as the mark identifier

**Example:**
```lua
require("buf-mark").set('a')
```

### `delete(char)`

Delete a buffer mark.

**Parameters:**
- `char` (string): The mark character to delete

**Example:**
```lua
require("buf-mark").delete('a')
```

### `goto(char)`

Jump to the buffer associated with the given mark.

**Parameters:**
- `char` (string): The mark character to jump to

**Example:**
```lua
require("buf-mark").goto('a')
```

### `delete_all()`

Delete all buffer marks for the current project.

**Example:**
```lua
require("buf-mark").delete_all()
```

## Events

### `BufMarkChanged`

A custom User autocommand event that fires whenever the set of buffer marks changes. This event is triggered after marks are set, deleted, or cleared.

**Use cases:**
- Update a statusline component showing current marks
- Display notifications when marks change
- Implement custom mark visualization

**Example:**
```lua
-- Listen for mark changes and print a message
vim.api.nvim_create_autocmd('User', {
  pattern = 'BufMarkChanged',
  callback = function()
    local buf_mark = require('buf-mark')
    local count = 0
    for _ in pairs(buf_mark.marks) do
      count = count + 1
    end
    print('Buffer marks changed. Total marks: ' .. count)
  end,
})
```

**Example - Update a custom statusline:**
```lua
-- Global variable to store current buffer's mark for statusline
_G.buf_mark_current = ''

-- Function to get the mark character for current buffer
function _G.get_current_buffer_mark()
  local buf_mark = require('buf-mark')
  local current_file = vim.api.nvim_buf_get_name(0)
  
  for char, path in pairs(buf_mark.marks) do
    if path == current_file then
      return '[' .. char .. ']'
    end
  end
  return ''
end

-- Update current buffer mark whenever marks change
vim.api.nvim_create_autocmd('User', {
  pattern = 'BufMarkChanged',
  callback = function()
    _G.buf_mark_current = _G.get_current_buffer_mark()
  end,
})

-- Also update when entering a buffer
vim.api.nvim_create_autocmd('BufEnter', {
  callback = function()
    _G.buf_mark_current = _G.get_current_buffer_mark()
  end,
})

-- Use in statusline - shows mark character if current buffer has one
vim.o.statusline = '%f %m %=%{v:lua.buf_mark_current}'
```

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
