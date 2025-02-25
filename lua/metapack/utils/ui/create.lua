local m = {
    logo = {
        "███╗   ███╗ ███████╗ ████████╗  █████╗  ██████╗   █████╗   ██████╗ ██╗  ██╗",
        "████╗ ████║ ██╔════╝ ╚══██╔══╝ ██╔══██╗ ██╔══██╗ ██╔══██╗ ██╔════╝ ██║ ██╔╝",
        "██╔████╔██║ █████╗      ██║    ███████║ ██████╔╝ ███████║ ██║      █████╔╝ ",
        "██║╚██╔╝██║ ██╔══╝      ██║    ██╔══██║ ██╔═══╝  ██╔══██║ ██║      ██╔═██╗ ",
        "██║ ╚═╝ ██║ ███████╗    ██║    ██║  ██║ ██║      ██║  ██║ ╚██████╗ ██║  ██╗",
        "╚═╝     ╚═╝ ╚══════╝    ╚═╝    ╚═╝  ╚═╝ ╚═╝      ╚═╝  ╚═╝  ╚═════╝ ╚═╝  ╚═╝",
        "                                                                           ",
    },
    menus = { "[m]ain    [p]ackages    [q]uit", "", "                              " },
}

function m.center(input, width)
    local output = vim.deepcopy(input)
    ---@type string
    local indent = ""
    for _ = 1, math.floor((width - #output[#output]) / 2) do
        indent = indent .. " "
    end

    for i = 1, #output do
        output[i] = indent .. output[i]
    end

    return output
end

return m
