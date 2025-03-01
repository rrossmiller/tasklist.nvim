-- credit https://github.com/folke/persistence.nvim/blob/main/lua/persistence/config.lua
local M = {}

---@class Opts
local defaults = {
    dir = vim.fn.expand(vim.fn.stdpath("state") .. "/todos/"), -- directory where todo files are saved
    style = "",
    border = "rounded",
}

---@type Opts
M.options = {}

function M.setup(opts)
    M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})

    -- if the storage directory doesn't exist, create it
    local is_directory = vim.fn.isdirectory(M.options.dir)
    if is_directory == 0 then
        vim.fn.mkdir(M.options.dir, "p")
    end
end

-- Example usage
-- if M.is_git_repo() then
--     print("The current directory is a Git repository.")
-- else
--     print("The current directory is not a Git repository.")
-- end
--
return M
