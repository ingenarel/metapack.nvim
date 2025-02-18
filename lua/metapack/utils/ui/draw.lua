local m = {}

function m.showMainMenu(buf, height, width)
    local logo = require("metapack.utils.ui.create").createLogo()
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, logo)
end

---@class UIOpts
---@field height integer?
---@field width integer?

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
    m.showMainMenu(buf, win_height, win_width)
    vim.bo[buf].modifiable = false
    vim.api.nvim_buf_set_keymap(buf, "n", "<ESC>", "<CMD>q<CR>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, "n", "q", "<CMD>q<CR>", { noremap = true, silent = true })
end

m.showUI()

return m
