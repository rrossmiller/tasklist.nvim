-- much of the credit goes to: https://dev.to/2nit/how-to-write-neovim-plugins-in-lua-5cca
-- also folke's https://github.com/folke/persistence.nvim
-- also gpt 3.5
local config = require("tasklist.config")
local api = vim.api
local buf, win
local win_open = false
local global_todo = true
local suffix = ".todo"

local M = {}

local function update_buffer(chan_id, data, name)
    -- https://neovim.io/doc/user/channel.html#on_stdout
    local fname = "todo" .. suffix
    if not global_todo then
        fname = M.get_proj_name() .. suffix
    end

    local ok, is_valid = pcall(vim.api.nvim_buf_is_valid, buf)
    if not ok then
        return
    end
    if is_valid and data[1]:find(fname) then
        local content = M.read_content()
        if #content == 0 then
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" })
        else
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
        end
    end
end

function M.open_window()
    -- create new empty buffer
    buf = api.nvim_create_buf(false, true)

    api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    -- get dimensions
    local width = api.nvim_get_option("columns")
    local height = api.nvim_get_option("lines")

    -- calculate our floating window size
    local win_height = math.ceil(height * 0.8 - 4)
    local win_width = math.ceil(width * 0.8)

    -- and its starting position
    local row = math.ceil((height - win_height) / 2 - 1)
    local col = math.ceil((width - win_width) / 2)

    local title = "TODO"
    if not global_todo then
        -- get the root of the git repo, or the name of the directory if it's not a repo
        title = M.get_proj_name()
    end
    -- set some options
    local opts = {
        title = title,
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
    local fname = "todo" .. suffix
    if not global_todo then
        fname = M.get_proj_name() .. suffix
    end
    local f = io.open(config.options.dir .. fname, "r")
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
    local fname = "todo" .. suffix
    if not global_todo then
        fname = M.get_proj_name() .. suffix
    end
    local file = io.open(config.options.dir .. fname, "w")
    if not file then
        print("uh oh") -- TODO:
    else
        local todo_content = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        if next(todo_content) ~= nil then
            for _, l in ipairs(todo_content) do
                file:write(l .. "\n")
            end
        end
        file:close()
    end
end

-- toggle_window and toggle_proj_window are the same, just with inverted global_todo logic
-- toggle global todo
function M.toggle_window()
    -- the project window is open. close that and open the global todo window
    if win_open and not global_todo then
        M.close_window()
        global_todo = true
        M.open_window()
        win_open = true
    elseif win_open then -- the todo window is open... close it
        M.close_window()
        win_open = false
    else -- nothing is open yet
        global_todo = true
        M.open_window()
        win_open = true
    end
end

-- toggle project todo
function M.toggle_proj_window()
    -- the global window is open. close it and open the project window
    if win_open and global_todo then
        M.close_window()
        global_todo = false
        M.open_window()
        win_open = true
    elseif win_open then -- proj window is open... close it
        M.close_window()
        win_open = false
    else -- nothing is open yet
        global_todo = false
        M.open_window()
        win_open = true
    end
    global_todo = false
end

function M.get_proj_name()
    -- get the current directory
    local result = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null")
    -- if it's a git repo. get the name of the repo/root dir
    if result and result ~= "" then
        -- Neovim is in a Git repository, get the repository name or root dir

        -- if there's a remote, use that as the name
        -- otherwise use the name of the file
        local repo_path = vim.fn.system("git remote -v")
        repo_path = string.match(repo_path, "^.*/(.*)%.git.*push")
        if not repo_path or repo_path ~= "" then
            repo_path = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null")
        end

        return repo_path and vim.fn.fnamemodify(repo_path:gsub("\n", ""), ":t") or ""
    else -- else get the name of the directory
        -- Neovim is not in a Git repository, get the current directory's name
        return vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    end
end

function M.setup(opts)
    config.setup(opts)

    vim.api.nvim_create_autocmd({ "VimLeavePre", "TextChanged", "TextChangedI" }, {
        -- group = vim.api.nvim_create_augroup("todo_content", { clear = true }),
        callback = function()
            if win_open then
                -- if Config.options.pre_save then
                --     Config.options.pre_save()
                -- end
                M.save_todos()
            end
        end,
    })

    local pth = config.options.dir .. "/*.todo"
    -- update window whenever todo list is updated
    vim.fn.jobstart("fswatch -x -i " .. pth, {
        on_stdout = update_buffer,
    })
end

return M
