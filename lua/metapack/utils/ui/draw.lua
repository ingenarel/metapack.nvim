local m = {}

local create = require("metapack.utils.ui.create")

function m.showMainMenu(buf, width)
    local lines = {}
    local logo = create.center(create.logo, width)
    local menus = create.center(create.menus, width)
    for i = 1, #menus do
        table.insert(lines, menus[i])
    end
    for i = 1, #logo do
        table.insert(lines, logo[i])
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
end

function m.createDataBaseGraph()
    local graph = {}
    local dataBase = require("metapack.utils.json").readDataBase()

    local longestPackageNameLen = 0
    for key, _ in pairs(dataBase) do
        if #key > longestPackageNameLen then
            longestPackageNameLen = #key
        end
    end
    -- Default: { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

    local packageSplit = ""
    local lastLine = ""
    for i = 1, longestPackageNameLen do
        packageSplit = packageSplit .. "─"
        lastLine = lastLine .. " "
    end

    local i = 1
    graph[i] = "╭" .. packageSplit .. "┬" .. "─────────" .. "┬"
    i = i + 1
    local packageSpaces = ""
    for _ = 4, longestPackageNameLen - 1 do
        packageSpaces = packageSpaces .. " "
    end
    graph[i] = "│" .. "Name" .. packageSpaces .. "│" .. "Installed" .. "│"
    i = i + 1
    graph[i] = "│" .. packageSplit .. "┼" .. "─────────" .. "┼"
    i = i + 1
    for key, _ in pairs(dataBase) do
        packageSpaces = ""
        for _ = #key, longestPackageNameLen - 1 do
            packageSpaces = packageSpaces .. " "
        end
        graph[i] = "│" .. key .. packageSpaces .. "│"
        if dataBase[key].installed == true then
            graph[i] = graph[i] .. "    ✓    " .. "│"
        else
            graph[i] = graph[i] .. "    X    " .. "│"
        end
        i = i + 1
        graph[i] = "├" .. packageSplit .. "┼" .. "─────────" .. "┼"
        i = i + 1
    end

    graph[i - 1] = "╰" .. packageSplit .. "┴" .. "─────────" .. "╯"
    graph[i] = " " .. lastLine .. " " .. "         " .. " "

    return graph
end

function m.showPackageMenu(buf, width)
    local lines = {}
    local menus = create.center(create.menus, width)
    for i = 1, #menus do
        table.insert(lines, menus[i])
    end
    local graph = create.center(m.createDataBaseGraph(), width)
    for i = 1, #graph do
        table.insert(lines, graph[i])
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
end

---@param opts? UIOpts
function m.showUI(opts)
    if opts == nil then
        opts = {}
    end
    if opts.width == nil then
        opts.width = 80
    end
    if opts.height == nil then
        opts.height = 80
    end

    ---@type integer
    local win_width = math.floor(vim.o.columns / 100 * opts.width)
    ---@type integer
    local win_height = math.floor(vim.o.lines / 100 * opts.height)
    ---@type integer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = win_width,
        height = win_height,
        col = math.floor((vim.o.columns - win_width - 2) / 2),
        row = math.floor((vim.o.lines - win_height - 2) / 2),
        border = "rounded",
        style = "minimal",
    })
    m.showMainMenu(buf, win_width)
    -- vim.bo[buf].modifiable = false
    vim.keymap.set("n", "<ESC>", "<CMD>q<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set("n", "q", "<CMD>q<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set("n", "m", function()
        require("metapack.utils.ui.draw").showMainMenu(buf, win_width)
    end, { noremap = true, silent = true, buffer = true })
    vim.keymap.set("n", "p", function()
        require("metapack.utils.ui.draw").showPackageMenu(buf, win_width)
    end, { noremap = true, silent = true, buffer = true })
end

return m
