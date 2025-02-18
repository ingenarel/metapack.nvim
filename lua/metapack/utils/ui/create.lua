local m = {}

---@param width integer
---@return string[]
function m.createLogo(width)
    ---@type string[]
    local logo = {
        "███╗   ███╗ ███████╗ ████████╗  █████╗  ██████╗   █████╗   ██████╗ ██╗  ██╗",
        "████╗ ████║ ██╔════╝ ╚══██╔══╝ ██╔══██╗ ██╔══██╗ ██╔══██╗ ██╔════╝ ██║ ██╔╝",
        "██╔████╔██║ █████╗      ██║    ███████║ ██████╔╝ ███████║ ██║      █████╔╝ ",
        "██║╚██╔╝██║ ██╔══╝      ██║    ██╔══██║ ██╔═══╝  ██╔══██║ ██║      ██╔═██╗ ",
        "██║ ╚═╝ ██║ ███████╗    ██║    ██║  ██║ ██║      ██║  ██║ ╚██████╗ ██║  ██╗",
        "╚═╝     ╚═╝ ╚══════╝    ╚═╝    ╚═╝  ╚═╝ ╚═╝      ╚═╝  ╚═╝  ╚═════╝ ╚═╝  ╚═╝",
        "                                                                           ",
    }

    ---@type string
    local indent = ""
    for _ = 1, math.floor((width - #logo[#logo]) / 2) do
        indent = indent .. " "
    end

    for i = 1, #logo do
        logo[i] = indent .. logo[i]
    end

    return logo
end

return m
