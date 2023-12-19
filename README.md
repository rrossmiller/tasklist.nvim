# Tasklist.nvim
A floating window plugin for easy access to todos and other notes

The todos for a project...

<img src="assets/prj-todos.png" alt="project todos" width="800"/>

... are separate from the "global" todos. The todo's that can't be associated with a single project.

<img src="assets/glbl-todos.png" alt="global todos" width="800"/>

If the directory that you open neovim from is a part of a git repo, the todos will be associated with the repo. Otherwise, the todos are associated with the directory you're in.

## 📦 Installation

Install the plugin with your preferred package manager:

### [Lazy](https://github.com/folke/lazy.nvim)

```lua
-- Lua
return {
  "rrossmiller/tasklist.nvim",
  config = function(opts)
    local todo = require("tasklist")
    vim.keymap.set("n", "<leader>tt", function() todo.toggle_window() end, { desc = 'Open global TODOs window' })
    vim.keymap.set("n", "<leader>tp", function() todo.toggle_proj_window() end, { desc = 'Open project TODOs window' })
    todo.setup()
  end
},
```


## ⚙️  Configuration

**Tasklist** comes with the following defaults:
```lua
{
    dir = vim.fn.expand(vim.fn.stdpath("state") .. "/todos/"), -- directory where todo files are saved. ~/.local/store/nvim/todos/
    style = '', -- neovim supports blank, or simple
    border = 'rounded', -- nvim allows these: https://neovim.io/doc/user/api.html#api-win_config:~:text=%27winhighlight%27.-,border
}
```

## 🛠️ Roadmap
- [x] read and write todos in buffer from/to a file
- [x] project/repo-level vs global todo 
- [x] sync the instances/open windows (rpc)
  - [x] update the window whenever any todo window/file was updated
  - [x] only update the window if the underlying file was updated
- [ ] fancy icons marking doneness?
    - change a prefix of a line to mean that the todo is done and the style of the line should change to reflect that
