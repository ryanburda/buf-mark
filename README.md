# buf-mark

A Neovim plugin that provides vim-like marks for buffers, allowing you to quickly jump between buffers while
preserving cursor positions.

## Features

- **Buffer Marks**: Set marks to buffers using single characters (similar to vim's global marks)
- **Cursor Position Preservation**: Automatically saves and restores cursor position when leaving and entering buffers
- **Simple API**: Easy-to-use functions for setting, deleting, and jumping to buffer marks
- **Customizable Keymaps**: Default keymaps provided, but can be disabled for custom configuration

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

### How It Works

Unlike vim's traditional marks which remember positions within a file, buffer marks remember entire buffers. When
you jump to a buffer mark the cursor position is automatically restored to where you last left it.

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
-- Similar to the default keymaps, this uses `vim.fn.getcharstr()` to get the buffer mark character after invoking the keymap.
-- `<leader>B{char}` to set a buffer mark
vim.keymap.set(
  'n',
  '<leader>B', function()
    -- The next character typed will be the character the buffer mark is mapped to
    local char = vim.fn.getcharstr()
    buf_mark.set_mark(char)
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
    buf_mark.goto_mark(char)
  end,
  { desc = 'Go to buffer mark' }
)

-- Explicitly mapped:
-- If you know you are only going to use a fixed set of buffer marks then you can configure keymaps to reflect that.
vim.keymap.set('n', '<leader>!', function() buf_mark.set_mark('1') end)
vim.keymap.set('n', '<leader>1', function() buf_mark.goto_mark('1') end)

vim.keymap.set('n', '<leader>@', function() buf_mark.set_mark('2') end)
vim.keymap.set('n', '<leader>2', function() buf_mark.goto_mark('2') end)

vim.keymap.set('n', '<leader>#', function() buf_mark.set_mark('3') end)
vim.keymap.set('n', '<leader>3', function() buf_mark.goto_mark('3') end)
```

## Commands

### `:BufMarks`

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

### `list_marks()`

Display all buffer marks with their associated buffer information.

**Example:**
```lua
require("buf-mark").list_marks()
```

### `set_mark(char)`

Set a buffer mark for the current buffer.

**Parameters:**
- `char` (string): A single character to use as the mark identifier

**Example:**
```lua
require("buf-mark").set_mark('a')
```

### `delete_mark(char)`

Delete a buffer mark.

**Parameters:**
- `char` (string): The mark character to delete

**Example:**
```lua
require("buf-mark").delete_mark('a')
```

### `goto_mark(char)`

Jump to the buffer associated with the given mark.

**Parameters:**
- `char` (string): The mark character to jump to

**Example:**
```lua
require("buf-mark").goto_mark('a')
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
- Sync marks to an external system
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
-- Global variable to store mark count for statusline
_G.buf_mark_count = 0

-- Update count whenever marks change
vim.api.nvim_create_autocmd('User', {
  pattern = 'BufMarkChanged',
  callback = function()
    local buf_mark = require('buf-mark')
    local count = 0
    for _ in pairs(buf_mark.marks) do
      count = count + 1
    end
    _G.buf_mark_count = count
  end,
})

-- Use in statusline
vim.o.statusline = '%f %m %=%{v:lua.buf_mark_count} marks'
```

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
