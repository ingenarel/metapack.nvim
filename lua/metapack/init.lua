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

function m._checkPackageExistInGentooRepos(name)
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
            name,
        })
            :wait().code == 0
    then
        return true
    else
        return false
    end
end

---@param packagesData table
---@param doas boolean?
function m.ensure_installed(packagesData, doas)
    ---@type table
    local osData = vim.uv.os_uname()

    -- NOTE: use this after i try to implement windows and mac
    -- if osData.sysname == "Linux" then
    -- end

    ---@type table
    local portagePackages = {}
    ---@type table
    local masonPackages = {}

    for i = 1, #packagesData do
        if type(packagesData[i]) == "string" then
            if m._checkInPath(packagesData[i]) == false then
                print("searching for " .. packagesData[i])
                if string.find(osData.release, "gentoo") and m._checkPackageExistInGentooRepos(packagesData[i]) then
                    table.insert(portagePackages, packagesData[i])
                elseif require("mason-registry").has_package(packagesData[i]) then
                    table.insert(masonPackages, packagesData[i])
                else
                    vim.notify(
                        "Can't find " .. packagesData[i] .. " on any known package database!",
                        vim.log.levels.WARN
                    )
                end
            end
        end
        if type(packagesData[i]) == "table" then
            if m._checkInPath(packagesData[i].name) == false then
                if packagesData[i].os == nil or string.find(osData.release, packagesData[i].os) then
                    if packagesData[i].portage then
                        table.insert(portagePackages, packagesData[i].name)
                    end
                    if packagesData[i].mason then
                        table.insert(masonPackages, packagesData[i].name)
                    end
                end
            end
        end
    end

    ---@type string
    local portageCommand = ""
    if #portagePackages > 0 then
        if doas == true then
            portageCommand = portageCommand .. "doas"
        else
            portageCommand = portageCommand .. "sudo"
        end
        portageCommand = portageCommand .. " emerge --ask y --verbose --color y --quiet-build y"
        for i = 1, #portagePackages do
            portageCommand = portageCommand .. " " .. portagePackages[i]
        end
    end

    ---@type string
    local masonCommand = ""
    if #masonPackages > 0 then
        for i = 1, #masonPackages do
            masonCommand = masonCommand .. " " .. masonPackages[i]
        end
        vim.cmd("MasonInstall" .. masonCommand)
    end

    if #portageCommand > 0 then
        vim.cmd("bot split|" .. "resize 10|" .. "terminal " .. portageCommand)
    end
end

return m
