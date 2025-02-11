local win_width = vim.fn.floor(vim.o.columns / 100 * 80)
local win_height = vim.fn.floor(vim.o.lines / 100 * 80)
local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = win_width,
    height = win_height,
    col = vim.fn.floor((vim.o.columns - win_width - 2) / 2),
    row = vim.fn.floor((vim.o.lines - win_height - 2) / 2),
    border = "rounded",
    style = "minimal",
})
vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "your mom" })
