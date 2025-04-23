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
    for _ = 1, longestPackageNameLen do
        packageSplit = packageSplit .. "─"
        lastLine = lastLine .. " "
    end

    local lineNumber = 1
    graph[lineNumber] = "╭"
        .. packageSplit
        .. "┬─────────┬───────┬──────┬───┬───┬─────┬───╮"
    lineNumber = lineNumber + 1
    local packageSpaces = ""
    for _ = 4, longestPackageNameLen - 1 do
        packageSpaces = packageSpaces .. " "
    end
    graph[lineNumber] = "│Name" .. packageSpaces .. "│Installed│Portage│Pacman│AUR│APT│Mason│Nix│"
    lineNumber = lineNumber + 1
    graph[lineNumber] = "├"
        .. packageSplit
        .. "┼─────────┼───────┼──────┼───┼───┼─────┼───┤"

    lineNumber = lineNumber + 1

    local ticks = {
        portage = { "   ✓   │", "       │" },
        pacman = { "   ✓  │", "      │" },
        aur = { " ✓ │", "   │" },
        apt = { "   │", "   │" },
        mason = { "  ✓  │", "     │" },
        nix = { "   │", "   │" },
    }

    local function addTickIfInstalled(packageName, packageManagerName)
        local success, functionOutput = pcall(function()
            return dataBase[packageName].installers[packageManagerName] == true
        end)
        if success and functionOutput then
            graph[lineNumber] = graph[lineNumber] .. ticks[packageManagerName][1]
        else
            graph[lineNumber] = graph[lineNumber] .. ticks[packageManagerName][2]
        end
    end

    for key, _ in pairs(dataBase) do
        packageSpaces = ""
        for _ = #key, longestPackageNameLen - 1 do
            packageSpaces = packageSpaces .. " "
        end
        graph[lineNumber] = "│" .. key .. packageSpaces .. "│"
        if dataBase[key].installed then
            graph[lineNumber] = graph[lineNumber] .. "    ✓    │"
        else
            graph[lineNumber] = graph[lineNumber] .. "    X    │"
        end
        addTickIfInstalled(key, "portage")
        addTickIfInstalled(key, "pacman")
        addTickIfInstalled(key, "aur")
        addTickIfInstalled(key, "apt")
        addTickIfInstalled(key, "mason")
        addTickIfInstalled(key, "nix")
        i = i + 1
        graph[i] = "├"
        lineNumber = lineNumber + 1
        graph[lineNumber] = "├"
            .. packageSplit
            .. "┼─────────┼───────┼──────┼───┼───┼─────┼───┤"
        lineNumber = lineNumber + 1
    end

    graph[lineNumber - 1] = "╰"
        .. packageSplit
        .. "┴─────────┴───────┴──────┴───┴───┴─────┴───╯"
    graph[lineNumber] = " " .. lastLine .. "                                        "

    return graph
end

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
