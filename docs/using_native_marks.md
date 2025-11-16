# Using Native Marks

Marks in Vim natively support jumping between buffers while preserving cursor location.

## A Quick Overview of Marks

### Local marks
Local marks are bookmarks that work within a single buffer.
  - Created using lowercase letters (a-z): `ma`, `mb`, etc.
  - Jump to a local mark with `'a` (single quote) or `` `a ``
  - Remembers the exact position (line and column) within
  the current buffer
  - Only accessible within the buffer where they were set
  - Lost when the buffer is deleted

### Global Marks `<--- foreshadowing`
Global marks are bookmarks that work across different files.
  - Created using uppercase letters (A-Z): `mA`, `mB`, etc.
  - Jump to a global mark with `'A` (single quote) or `` `A ``
  - Remembers both the file and the exact position (line and column)
  - Can jump to them from any buffer

### Automatic Marks
Vim automatically keeps track of several marks for you.
  - `'` - Position before the latest jump within the current file
  - `` ` `` - Position of the cursor when last editing this file
  - `"` - Position where the cursor was when last exiting the file `<--- more foreshadowing`
  - `[` - First character of previously changed or yanked text
  - `]` - Last character of previously changed or yanked text
  - `<` - First character of last visual selection
  - `>` - Last character of last visual selection
  - `^` - Position where the cursor was last time when Insert mode was stopped
  - `.` - Position of last change

### Difference between `'` and `` ` `` when jumping to marks
Backtick (`` ` ``) jumps to the exact position (line and column) where the mark was set, while
single quote (`'`) jumps to the first non-blank character of that line.
- Use backtick for precise positioning `<--- even more foreshadowing!!`
- Use single quote when you only care about getting to the right line

**Example:**

Suppose you have a line of code with indentation:
```
    const myVariable = "hello world";
          ^
```
And you set mark `a` when your cursor is on the `m` in `myVariable` (shown by `^`).

- `` `a `` - Jumps directly to the `m` character (column 10)
- `'a` - Jumps to the `c` in `const` (first non-blank character on that line, column 4)

Both commands take you to the same line, but backtick preserves the exact column position while single quote moves to the start of the actual content.

### Solution
This means we can use a combination of:
- Global marks
- The `"` mark
- precise positioning, `` ` ``, when jumping to marks

to jump between buffers while preserving cursor location.

For example:
  - `mA` to set global mark `A`
  - `` 'A`" `` to jump to the buffer marked by `A` at the last cursor position
    - `'A` jumps to global mark `A`
    - `` `" `` jumps to the exact cursor position when last exiting the file

### Problems
Jumping between buffers should be easy since we plan on doing it often. The mark
based solution of typing `` '{mark}`" `` requires a bit of keyboard gymnastics.

... we can do better

### A Simple Keymap
We can create a keymap to make `'{mark}` perform `` '{mark}'` `` for us to make it more ergonomic.

```lua
vim.keymap.set(
  'n',
  "'",
  function()
    -- Get the next character that is typed
    local char = vim.fn.getcharstr()

    -- Go to mark
    local ok, err = pcall(vim.cmd, "normal! '" .. char)
    if not ok then
      local vim_err = err:match("Vim%([^)]+%):(.*)") or err
      vim.api.nvim_echo({{vim_err, "ErrorMsg"}}, true, {})
    end

    -- If we just jumped to a global mark (upper case character), go
    -- to the position where the cursor was when last exiting the file
    if char:match("%u") then
      vim.api.nvim_feedkeys('`"', 'n', false)
    end
  end,
  { desc = 'Go to buffer' }
)
```

Here's what it does:

1. Captures the next character: When you press `'`, it waits for you to type a mark character (like `'A` or `'b`).
2. Jumps to the specified mark.
3. Error handling: If the mark doesn't exist, it catches the error and displays a cleaned-up error message.
4. Special behavior for global marks: If the character is an uppercase letter, after jumping to the mark's line,
it additionally executes `` `" `` which jumps to the exact position where the cursor was when you last exited that file.

This effectively means:
- `'a` through `'z` - Jump to local mark (standard behavior)
- `'A` through `'Z` - Jump to global mark, then jump to last exit position in that file

This combines mark navigation with Vim's "last position" feature. In a way it makes global marks behave more
like "buffer marks".

**NOTE:** If you want to jump to the exact location of a global mark you can still use `` `<mark> ``.


## The why use `buf-mark`?

If marks work just fine, why should I use this plugin?
 
Sometimes the simple solution is the best solution. The keymap above acomplishes
what most people need and is what I recommend for most cases.

`buf-mark` should only be used if you think you'll take advantage of any of the following features:
- buf-mark persistence across sessions on a working directory level
- a buffer marking solution that is **not** built upon marks so that marks can continue to be used in the way they were intended 
- simple UI integrations with the built in [status](../README.md#status)
