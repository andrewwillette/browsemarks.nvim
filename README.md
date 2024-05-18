# browsemarks.nvim
A neovim plugin to create browser plugins.

```lua
local browsemarks = require("browsemarks")
browsemarks.setup({
  selected_browser = "brave"
})
vim.keymap.set(
  "n",
  "<Leader>bm",
  browsemarks.add_bookmark,
  { noremap = true, silent = true }
)
```
