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

    local i = 1
    graph[i] = "╭"
        .. packageSplit
        .. "┬─────────┬───────┬──────┬───┬───┬─────╮"
    i = i + 1
    local packageSpaces = ""
    for _ = 4, longestPackageNameLen - 1 do
        packageSpaces = packageSpaces .. " "
    end
    graph[i] = "│Name" .. packageSpaces .. "│Installed│Portage│Pacman│AUR│APT│Mason│"
    i = i + 1
    graph[i] = "├"
        .. packageSplit
        .. "┼─────────┼───────┼──────┼───┼───┼─────┤"

    i = i + 1
    for key, _ in pairs(dataBase) do
        packageSpaces = ""
        for _ = #key, longestPackageNameLen - 1 do
            packageSpaces = packageSpaces .. " "
        end
        graph[i] = "│" .. key .. packageSpaces .. "│"
        vim.fn.matchadd("MetapackPackageName", key)
        if dataBase[key].installed == true then
            graph[i] = graph[i] .. "    ✓    │"
        else
            graph[i] = graph[i] .. "        │"
        end

        local success, functionOutput = pcall(function()
            return dataBase[key].installers.portage == true
        end)
        if success == true and functionOutput == true then
            graph[i] = graph[i] .. "   ✓   │"
        else
            graph[i] = graph[i] .. "       │"
        end
        success, functionOutput = pcall(function()
            return dataBase[key].installers.pacman == true
        end)
        if success == true and functionOutput == true then
            graph[i] = graph[i] .. "   ✓  │"
        else
            graph[i] = graph[i] .. "      │"
        end
        success, functionOutput = pcall(function()
            return dataBase[key].installers.aur == true
        end)
        if success == true and functionOutput == true then
            graph[i] = graph[i] .. " ✓ │"
        else
            graph[i] = graph[i] .. "   │"
        end
        success, functionOutput = pcall(function()
            return dataBase[key].installers.apt == true
        end)
        if success == true and functionOutput == true then
            graph[i] = graph[i] .. " ✓ │"
        else
            graph[i] = graph[i] .. "   │"
        end
        success, functionOutput = pcall(function()
            return dataBase[key].installers.mason == true
        end)
        if success == true and functionOutput == true then
            graph[i] = graph[i] .. "  ✓  │"
        else
            graph[i] = graph[i] .. "     │"
        end
        i = i + 1
        graph[i] = "├"
            .. packageSplit
            .. "┼─────────┼───────┼──────┼───┼───┼─────┤"
        i = i + 1
    end

    graph[i - 1] = "╰"
        .. packageSplit
        .. "┴─────────┴───────┴──────┴───┴───┴─────╯"
    graph[i] = " " .. lastLine .. "                                        "

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
