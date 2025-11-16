# Author's Keymaps

This document describes an alternative keymap configuration that I prefer, which may serve as inspiration for your own setup.

## Philosophy

In typical Neovim usage, I rarely find myself using local marks. Most of the time I only mark a few locations per
session and want to be able to jump to those marks from any buffer. This is why I generally prefer global marks.

This keymap configuration repurposes the local mark keybindings for buf-marks instead, making buffer navigation more ergonomic.

## Keymap Strategy

- `m{lowercase}` - Set a buf-mark
- `m{other}` - Set a native global mark (normal behavior)
- `'{lowercase}` - Jump to a buf-mark
- `'{other}` - Jump to a native mark (normal behavior)
- `M{lowercase}` - Delete a buf-mark
- `M{other}` - Delete a native mark
- `'/` - Jump to alternate buffer
- `'?` - List all buf-marks
- `<leader>m{char}` - Set a native mark (fallback for local marks if needed)
- `<leader>'{char}` - Jump to a native mark (fallback for local marks if needed)

## Implementation

```lua
vim.keymap.set(
  'n',
  'm',
  function()
    local char = vim.fn.getcharstr()
    if char:match("%l") then
      -- set a buf-mark
      require('buf-mark').set(char)
    else
      -- set a global mark
      local ok, err = pcall(vim.cmd, 'normal! m' .. char)
      if not ok then
        local vim_err = err:match("Vim%([^)]+%):(.*)") or err
        vim.api.nvim_echo({{vim_err, "ErrorMsg"}}, true, {})
      end
    end
  end,
  { desc = 'Set buf-mark/global mark' }
)

vim.keymap.set(
  'n',
  "'",
  function()
    local char = vim.fn.getcharstr()
    if char:match("%l") then
      -- goto a buf-mark
      require('buf-mark').goto(char)
    else
      -- goto a global mark
      local ok, err = pcall(vim.cmd, "normal! '" .. char)
      if not ok then
        local vim_err = err:match("Vim%([^)]+%):(.*)") or err
        vim.api.nvim_echo({{vim_err, "ErrorMsg"}}, true, {})
      end
    end
  end,
  { desc = 'Goto buf-mark/global mark' }
)

vim.keymap.set(
  'n',
  'M',
  function()
    local char = vim.fn.getcharstr()
    if char:match("%l") then
      -- delete a buf-mark
      require('buf-mark').delete(char)
    else
      -- delete a global mark
      local ok, err = pcall(vim.cmd, 'delmarks ' .. char)
      if not ok then
        local vim_err = err:match("Vim%([^)]+%):(.*)") or err
        vim.api.nvim_echo({{vim_err, "ErrorMsg"}}, true, {})
      end
    end
  end,
  { desc = 'Delete buf-mark/global mark' }
)

-- `/` and `?` are in the same area of the keyboard as some
-- of the other vim-maintained marks so this feels right.
vim.keymap.set(
  'n',
  "'/",
  ':b#<cr>',
  { desc = 'Alternate buffer' }
)

vim.keymap.set(
  'n',
  "'?",
  require('buf-mark').list_pretty,
  { desc = 'List buf-marks' }
)

-- set these just in case you need local marks
vim.keymap.set(
  'n',
  '<leader>m',
  function()
    local char = vim.fn.getcharstr()
    -- set mark
    local ok, err = pcall(vim.cmd, 'normal! m' .. char)
    if not ok then
      local vim_err = err:match("Vim%([^)]+%):(.*)") or err
      vim.api.nvim_echo({{vim_err, "ErrorMsg"}}, true, {})
    end
  end,
  { desc = 'Set mark' }
)

vim.keymap.set(
  'n',
  "<leader>'",
  function()
    local char = vim.fn.getcharstr()
    -- goto mark
    local ok, err = pcall(vim.cmd, "normal! '" .. char)
    if not ok then
      local vim_err = err:match("Vim%([^)]+%):(.*)") or err
      vim.api.nvim_echo({{vim_err, "ErrorMsg"}}, true, {})
    end
  end,
  { desc = 'Goto mark' }
)
```

## Setup Configuration

When using this keymap approach, disable the default keymaps in your buf-mark setup:

```lua
require("buf-mark").setup({
  keymaps = false,  -- Disable default keymaps
  persist = true,
})
```
