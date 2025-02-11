---@type table
local m = {}

--variables{{{
---@type string
m._osData = vim.system({ "grep", "-i", "-E", '^(id|id_like|name|pretty_name)="?.+"?', "/etc/os-release" }):wait().stdout
---@type table
m._portagePackages = {}
---@type table
m._masonPackages = {}
---@type table
m._pacmanPackages = {}
---@type table
m._aurPackages = {}
---@type table
m._aptPackages = {}

---@type string
m._masonCommand = ""
---@type string
m._aurHelperCommand = ""
---@type string
m._aurHelper = ""
---@type string
m._aptCommand = ""
-- }}}

-- ---@return boolean
-- ---@param name string
-- function m._ifDistro(name)
--     if string.find(m._osData, name) then
--         return true
--     else
--         return false
--     end
-- end

---@return nil
function m._setAurHelper()
    if vim.fn.executable("paru") == 1 then
        m._aurHelper = "paru"
    elseif vim.fn.executable("yay") == 1 then
        m._aurHelper = "yay"
    end
    m._aurHelperCommand = m._aurHelper .. " -S "
end

---function m._ifInPath(packageName, executableName)-- {{{
---@return boolean
---@param packageName string
---@param executableName string?
function m._ifInPath(packageName, executableName) -- {{{
    if executableName == nil then
        executableName = packageName
    end
    if vim.fn.executable(executableName) == 1 or require("mason-registry").is_installed(packageName) == true then
        return true
    end
    return false -- }}}
end -- }}}

-- function m._ifPackageExistInRepos(packageName, packageManager){{{
---@param packageName string{{{
---@param packageManager string
---@return boolean}}}
function m._ifPackageExistInRepos(packageName, packageManager)
    local commands = {
        portage = function() -- {{{
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

        paru = function() -- {{{
            if vim.system({ "paru", "-Ssx", "^" .. packageName .. "$" }):wait().code == 0 then
                return true
            else
                return false
            end
        end, -- }}}

        yay = function()
            if
                vim.system({ "sh", "-c", "yay -Ss " .. packageName .. ' | grep -E "^.+/' .. packageName .. ' .+$"' })
                    :wait().code == 0
            then
                return true
            else
                return false
            end
        end,

        apt = function()
            if vim.system({ "apt-cache", "search", "^" .. packageName .. "$" }):wait().code == 0 then
                return true
            else
                return false
            end
        end,
    }

    if commands[packageManager] then
        return commands[packageManager]()
    else
        return false
    end
end -- }}}

---@param packageData table | string
---@return nil
function m._catagorizePackages(packageData)
    if type(packageData) == "string" then
        if m._ifInPath(packageData) == false then
            vim.notify("Searching for " .. packageData, vim.log.levels.INFO)
            if string.find(m._osData, "gentoo") and m._ifPackageExistInRepos(packageData, "portage") then
                table.insert(m._portagePackages, packageData)
                return
            elseif string.find(m._osData, "arch") then
                if m._ifPackageExistInRepos(packageData, "pacman") then
                    table.insert(m._pacmanPackages, packageData)
                    return
                else
                    m._setAurHelper()
                    if m._aurHelper ~= nil and m._ifPackageExistInRepos(packageData, m._aurHelper) then
                        table.insert(m._aurPackages, packageData)
                        return
                    end
                end
            elseif string.find(m._osData, "debian") then
                if m._ifPackageExistInRepos(packageData, "apt") then
                    table.insert(m._aptPackages, packageData)
                end
            end
            if require("mason-registry").has_package(packageData) then
                table.insert(m._masonPackages, packageData)
            else
                vim.notify("Can't find " .. packageData .. " on any known package database!", vim.log.levels.WARN)
            end
        end
    elseif type(packageData) == "table" then
        if packageData.execName == nil then
            packageData.execName = packageData.name
        end
        if m._ifInPath(packageData.execName) == false then
            if packageData.os == nil or string.find(m._osData, packageData.os) then
                if packageData.portage then
                    table.insert(m._portagePackages, packageData.name)
                end
                if packageData.mason then
                    table.insert(m._masonPackages, packageData.name)
                end
                if packageData.pacman then
                    table.insert(m._pacmanPackages, packageData.name)
                end
                if packageData.aur then
                    m._setAurHelper()
                    table.insert(m._aurPackages, packageData.name)
                end
                if packageData.apt then
                    table.insert(m._aptPackages, packageData.name)
                end
            end
        end
    end
end

---@param packagesData table
---@param doas boolean?
function m.ensure_installed(packagesData, doas)
    -- NOTE: use this after i try to implement windows and mac{{{
    -- if osData.sysname == "Linux" then
    -- end}}}

    for i = 1, #packagesData do
        m._catagorizePackages(packagesData[i])
    end

    if #m._portagePackages > 0 then -- {{{
        ---@type string
        m._portageCommand = "sudo"

        if doas == true then
            m._portageCommand = "doas"
        end

        m._portageCommand = m._portageCommand .. " emerge --ask y --verbose --color y --quiet-build y"

        for i = 1, #m._portagePackages do
            m._portageCommand = m._portageCommand .. " " .. m._portagePackages[i]
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
            m._pacmanCommand = m._pacmanCommand .. " " .. m._pacmanPackages[i]
        end

        vim.cmd("bot split|" .. "resize 10|" .. "terminal " .. m._pacmanCommand)
    end

    if #m._aurPackages > 0 then
        ---@type string
        m._aurCommand = m._aurHelperCommand

        for i = 1, #m._aurPackages do
            m._aurCommand = m._aurCommand .. " " .. m._aurPackages[i]
        end
        vim.cmd("bot split|" .. "resize 10|" .. "terminal " .. m._aurCommand)
    end

    if #m._aptPackages > 0 then
        m._aptCommand = "sudo apt-get install "
        for i = 1, #m._aptPackages do
            m._aptcommand = m._aptCommand .. " " .. m._aptPackages[i]
        end
        vim.cmd("bot split|" .. "resize 10|" .. "terminal " .. m._aptCommand)
    end

    if #m._masonPackages > 0 then -- {{{
        for i = 1, #m._masonPackages do
            m._masonCommand = m._masonCommand .. " " .. m._masonPackages[i]
        end
        vim.cmd("MasonInstall" .. m._masonCommand)
    end -- }}}
end

return m
