---@type table
local m = {}

---function m._checkInPath(packageName, executableName)-- {{{
---@return boolean
---@param packageName string
---@param executableName string?
function m._checkInPath(packageName, executableName) -- {{{
    if executableName == nil then
        executableName = packageName
    end
    if vim.fn.executable(executableName) == 1 or require("mason-registry").is_installed(packageName) then
        return true
    end
    return false -- }}}
end -- }}}

-- function m._checkPackageExistInRepos(packageName, packageManager){{{
---@param packageName string{{{
---@param packageManager string
---@return boolean}}}
function m._checkPackageExistInRepos(packageName, packageManager)
    local commands = {
        emerge = function() -- {{{
            if
                vim.system({
                    "emerge",
                    "--ask",
                    "n",
                    "--pretend",
                    "--oneshot",
                    "--nodeps",
                    "--verbose",
                    "n",
                    "--color",
                    "n",
                    packageName,
                })
                    :wait().code == 0
            then
                return true
            else
                return false
            end
        end, -- }}}

        pacman = function() -- {{{
            if vim.system({ "pacman", "-Ss", "^" .. packageName .. "$" }):wait().code == 0 then
                return true
            else
                return false
            end
        end, -- }}}
    }

    if commands[packageManager] then
        return commands[packageManager]()
    else
        return false
    end
end -- }}}

---@param packagesData table
---@param doas boolean?
function m.ensure_installed(packagesData, doas)
    -- NOTE: use this after i try to implement windows and mac{{{
    -- if osData.sysname == "Linux" then
    -- end}}}

    --variables{{{
    ---@type table
    local osData = vim.uv.os_uname()
    ---@type table
    m._portagePackages = {}
    ---@type table
    m._masonPackages = {}
    ---@type table
    m._pacmanPackages = {}

    ---@type string
    m._masonCommand = ""
    -- }}}

    for i = 1, #packagesData do -- {{{
        if type(packagesData[i]) == "string" then -- {{{
            if m._checkInPath(packagesData[i]) == false then
                vim.notify("Searching for " .. packagesData[i], vim.log.levels.INFO)
                if string.find(osData.release, "gentoo") and m._checkPackageExistInRepos(packagesData[i], "emerge") then
                    table.insert(m._portagePackages, packagesData[i])
                elseif
                    string.find(osData.release, "arch") and m._checkPackageExistInRepos(packagesData[i], "pacman")
                then
                    table.insert(m._pacmanPackages, packagesData[i])
                elseif require("mason-registry").has_package(packagesData[i]) then
                    table.insert(m._masonPackages, packagesData[i])
                else
                    vim.notify(
                        "Can't find " .. packagesData[i] .. " on any known package database!",
                        vim.log.levels.WARN
                    )
                end
            end
        end -- }}}
        if type(packagesData[i]) == "table" then -- {{{
            if m._checkInPath(packagesData[i].name) == false then
                if packagesData[i].os == nil or string.find(osData.release, packagesData[i].os) then
                    if packagesData[i].portage then
                        table.insert(m._portagePackages, packagesData[i].name)
                    end
                    if packagesData[i].mason then
                        table.insert(m._masonPackages, packagesData[i].name)
                    end
                    if packagesData[i].pacman then
                        table.insert(m._pacmanPackages, packagesData[i].name)
                    end
                end
            end
        end -- }}}
    end -- }}}

    if #m._portagePackages > 0 then -- {{{
        ---@type string
        m._portageCommand = "sudo"

        if doas == true then
            m._portageCommand = "doas"
        end

        m._portageCommand = m._portageCommand .. " emerge --ask y --verbose --color y --quiet-build y"

        for i = 1, #m._portagePackages do
            m._portageCommand = m._portageCommand .. m._portagePackages[i]
        end

        vim.cmd("bot split|" .. "resize 10|" .. "terminal " .. m._portageCommand)
    end -- }}}

    if #m._pacmanPackages > 0 then
        ---@type string
        m._pacmanCommand = "sudo"

        if doas == true then
            m._pacmanCommand = "doas"
        end

        m._pacmanCommand = m._pacmanCommand .. " pacman -S "
        for i = 1, #m._pacmanPackages do
            m._pacmanCommand = m._pacmanCommand .. m._pacmanPackages[i]
        end

        vim.cmd("bot split|" .. "resize 10|" .. "terminal " .. m._pacmanCommand)
    end

    if #m._masonPackages > 0 then -- {{{
        for i = 1, #m._masonPackages do
            m._masonCommand = m._masonCommand .. " " .. m._masonPackages[i]
        end
        vim.cmd("MasonInstall" .. m._masonCommand)
    end -- }}}
end

return m
