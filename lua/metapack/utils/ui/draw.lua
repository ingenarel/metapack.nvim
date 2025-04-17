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
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
    vim.bo[buf].modifiable = false
end

function m.showPackageMenu(buf, width)
    local lines = {}
    local menus = create.center(create.menus, width)
    for i = 1, #menus do
        table.insert(lines, menus[i])
    end
    local graph = create.center(create.createDataBaseGraph(), width)
    for i = 1, #graph do
        table.insert(lines, graph[i])
    end
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
    vim.bo[buf].modifiable = false
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
    local bufID = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_open_win(bufID, true, {
        relative = "editor",
        width = win_width,
        height = win_height,
        col = math.floor((vim.o.columns - win_width - 2) / 2),
        row = math.floor((vim.o.lines - win_height - 2) / 2),
        border = "rounded",
        style = "minimal",
    })
    m.showMainMenu(bufID, win_width)
    vim.keymap.set("n", "<ESC>", "<CMD>q<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set("n", "q", "<CMD>q<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set("n", "m", function()
        require("metapack.utils.ui.draw").showMainMenu(bufID, win_width)
    end, { noremap = true, silent = true, buffer = true })
    vim.keymap.set("n", "p", function()
        require("metapack.utils.ui.draw").showPackageMenu(bufID, win_width)
    end, { noremap = true, silent = true, buffer = true })
    vim.fn.matchadd("metapackKeymapRest", "\\[.\\]\\S\\+")
    vim.fn.matchadd("metapackKeymap", "\\[.\\]")
    vim.fn.matchadd("metapackBracket", "\\(\\[\\|\\]\\)")
    vim.fn.matchadd("metapackPackageBorders", "\\(╭\\|─\\|┬\\|╮\\|├\\|┼\\|┤\\|│\\|╰\\|┴\\|╯\\)")
end

return m
