M = {}

function M.check()
    vim.health.start("Checking that fswatch is installed")
    local ok = vim.fn.executable("fswatch")
    -- make sure setup function parameters are ok
    if ok ~= 0 then
        vim.health.ok("Setup is correct")
    else
        vim.health.error("fswatch is not installed or missing from path")
    end
end

return M
