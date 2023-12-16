-- much of the credit goes to: https://dev.to/2nit/how-to-write-neovim-plugins-in-lua-5cca
local config = require("tasklist.config")
local api = vim.api
local buf, win
local win_open = false

local M = {}

function M.setup(opts)
    config.setup(opts)

    vim.api.nvim_create_autocmd("VimLeavePre", {
        group = vim.api.nvim_create_augroup("todo_content", { clear = true }),
        callback = function()
            if win_open then
                -- if Config.options.pre_save then
                --     Config.options.pre_save()
                -- end
                M.save_todos()
            end
        end,
    })
end

function M.open_window()
    -- create new empty buffer
    buf = api.nvim_create_buf(false, true)

    api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    -- get dimensions
    local width = api.nvim_get_option("columns")
    local height = api.nvim_get_option("lines")

    -- calculate our floating window size
    local win_height = math.ceil(height * 0.8 - 4)
    local win_width = math.ceil(width * 0.8)

    -- and its starting position
    local row = math.ceil((height - win_height) / 2 - 1)
    local col = math.ceil((width - win_width) / 2)

    -- set some options
    local opts = {
        title = "TODO",
        title_pos = "center",
        style = config.options.style,
        relative = "editor",
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        border = config.options.border,
    }

    local content = M.read_content()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

    -- create it with buffer attached
    win = api.nvim_open_win(buf, true, opts)
end

function M.read_content()
    local f = io.open(config.options.dir .. 'todo', 'r')
    local lines = {}
    if f then
        for line in f:lines() do
            table.insert(lines, line)
        end
        f:close()
    end
    return lines
end

function M.close_window()
    M.save_todos()
    api.nvim_win_close(win, true)
end

function M.save_todos()
    -- write buffer to todofile
    local file = io.open(config.options.dir .. "todo", 'w')
    if not file then
        print('uh oh') -- TODO:
    else
        local todo_content = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        if next(todo_content) ~= nil then
            for _, l in ipairs(todo_content) do
                file:write(l .. '\n')
            end
        end
        file:close()
    end
end

function M.toggle_window()
    if win_open then
        M.close_window()
    else
        M.open_window()
    end
    win_open = not win_open
end

return M
