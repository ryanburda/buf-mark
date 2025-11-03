# buf_marker.nvim

A Neovim plugin that provides vim-like marks for buffers, allowing you to quickly jump between buffers while preserving cursor positions.

## Features

- **Buffer Marks**: Set marks to buffers using single characters (similar to vim's global marks)
- **Cursor Position Preservation**: Automatically saves and restores cursor position when leaving and entering buffers
- **Simple API**: Easy-to-use functions for setting, deleting, and jumping to buffer marks
- **Customizable Keymaps**: Default keymaps provided, but can be disabled for custom configuration

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "ryanburda/buf_marker.nvim",
  config = function()
    require("buf_marker").setup()
  end,
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "ryanburda/buf_marker.nvim",
  config = function()
    require("buf_marker").setup()
  end,
}
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'ryanburda/buf_marker.nvim'

lua << EOF
require("buf_marker").setup()
EOF
```

## Usage

### Default Keymaps

By default:
- `<leader>m{char}` - Set a buffer mark for the current buffer
- `<leader>'{char}` - Jump to the buffer associated with the mark

With `swap_native_mark_keymaps = true`:
- `m{char}` - Set a buffer mark for the current buffer
- `'{char}` - Jump to the buffer associated with the mark
- `<leader>m{char}` - Set a native vim mark
- `<leader>'{char}` - Jump to a native vim mark

This option allows for a more ergonomic workflow if you find yourself using buf marks more than
native vim marks while still allowing for native vim marks to be set in an intuitive way.

### Example Workflow

1. Open a file (e.g., `config.lua`)
2. Press `<leader>mc` to mark this buffer with character `c`
3. Navigate to another file
4. Press `<leader>'c` to instantly jump back to `config.lua` at the exact cursor position you left

### How It Works

Unlike vim's traditional marks which remember positions within a file, buffer marks remember entire buffers. When you jump to a buffer mark:

- If the buffer is already loaded, it switches to that buffer
- If the buffer is not loaded, it opens the file
- The cursor position is automatically restored to where you last left it

## Configuration

### Setup Options

```lua
require("buf_marker").setup({
  -- Set to false to disable default keymaps
  keymaps = true,

  -- Set to true to swap native mark keymaps with buffer mark keymaps
  -- (only works when keymaps = true)
  swap_native_mark_keymaps = false,

  -- Set to true to persist marks between Neovim sessions
  -- Marks will be saved per working directory
  persist = false,
})
```

#### Swapping Native Mark Keymaps

If you prefer to use `m` and `'` for buffer marks (instead of `<leader>m` and `<leader>'`), you can enable the swap:

```lua
require("buf_marker").setup({
  swap_native_mark_keymaps = true,
})
```

This will map:
- `m{char}` and `'{char}` to buffer marks
- `<leader>m{char}` and `<leader>'{char}` to native vim marks

#### Mark Persistence

Enable persistence to save marks between Neovim sessions:

```lua
require("buf_marker").setup({
  persist = true,
})
```

When enabled:
- Marks are automatically saved when set or deleted
- Marks are loaded when the plugin initializes
- Each working directory has its own set of marks (e.g., marks in `~/project-a` are separate from `~/project-b`)
- Marks are stored in `~/.local/share/nvim/buf_marker/` as JSON files

### Custom Keymaps

If you prefer custom keymaps, disable the defaults and set your own:

```lua
require("buf_marker").setup({
  keymaps = false,
})

local buf_marker = require("buf_marker")

-- Custom keymaps
vim.keymap.set(
  'n',
  '<leader>m', function()
    local char = vim.fn.getcharstr()
    buf_marker.set_mark(char)
  end,
  { desc = 'Set buffer mark' }
)

vim.keymap.set(
  'n',
  "<leader>'",
  function()
    local char = vim.fn.getcharstr()
    buf_marker.goto_mark(char)
  end,
  { desc = 'Go to buffer mark' }
)
```

## Commands

### `:BufMarkerList`

Lists all buffer marks with their associated files. The output displays:
- Mark character
- File path (relative to current directory)

Example output:
```
mark  file
 a    src/config.lua
 b    README.md
 c    /path/to/unloaded/file.txt
```

## API

### `setup(opts)`

Initialize the plugin with optional configuration.

**Parameters:**
- `opts` (table, optional): Configuration options
  - `keymaps` (boolean): Enable/disable default keymaps (default: `true`)
  - `swap_native_mark_keymaps` (boolean): Swap buffer mark and native mark keymaps (default: `false`, only works when `keymaps = true`)
  - `persist` (boolean): Enable mark persistence between sessions, saved per working directory (default: `false`)

### `set_mark(char)`

Set a buffer mark for the current buffer.

**Parameters:**
- `char` (string): A single character to use as the mark identifier

**Example:**
```lua
require("buf_marker").set_mark('a')
```

### `delete_mark(char)`

Delete a buffer mark.

**Parameters:**
- `char` (string): The mark character to delete

**Example:**
```lua
require("buf_marker").delete_mark('a')
```

### `goto_mark(char)`

Jump to the buffer associated with the given mark.

**Parameters:**
- `char` (string): The mark character to jump to

**Example:**
```lua
require("buf_marker").goto_mark('a')
```

### `list_marks()`

Display all buffer marks with their associated buffer information. This is the same as running `:BufMarks`.

**Example:**
```lua
require("buf_marker").list_marks()
```

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
