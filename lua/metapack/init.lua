---@class initModule
local m = {
    _portagePackages = {},
    _masonPackages = {},
    _pacmanPackages = {},
    _aurPackages = {},
    _aurHelper = "",
    _aptPackages = {},
    _osData = "",
    _rootCommand = "sudo ",
}

if vim.fn.has("win32") == 0 then -- {{{
    m._osData = vim.system({ "grep", "-i", "-E", '^(id|id_like|name|pretty_name)="?.+"?', "/etc/os-release" })
        :wait().stdout
else
    m._osData = "windows"
end -- }}}

---@param packageData (string|PackageData)
---@return nil
function m._catagorizePackages(packageData)
    if type(packageData) == "string" then
        if require("metapack.utils.packageManager").ifInPath(packageData) == false then
            vim.notify("Searching for " .. packageData, vim.log.levels.INFO)
            if
                string.find(m._osData, "gentoo")
                and require("metapack.utils.packageManager").ifPackageExistInRepos(packageData, "portage")
            then
                table.insert(m._portagePackages, packageData)
                return
            elseif string.find(m._osData, "arch") then
                if require("metapack.utils.packageManager").ifPackageExistInRepos(packageData, "pacman") then
                    table.insert(m._pacmanPackages, packageData)
                    return
                else
                    m._aurHelper = require("metapack.utils.packageManager").setAurHelper()
                    if
                        m._aurHelper ~= ""
                        and require("metapack.utils.packageManager").ifPackageExistInRepos(packageData, m._aurHelper)
                    then
                        table.insert(m._aurPackages, packageData)
                        return
                    end
                end
            elseif string.find(m._osData, "debian") then
                if require("metapack.utils.packageManager").ifPackageExistInRepos(packageData, "apt") then
                    table.insert(m._aptPackages, packageData)
                end
                return
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
        if require("metapack.utils.packageManager").ifInPath(packageData.execName) == false then
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
                    m._aurHelper = require("metapack.utils.packageManager").setAurHelper()
                    table.insert(m._aurPackages, packageData.name)
                end
                if packageData.apt then
                    table.insert(m._aptPackages, packageData.name)
                end
            end
        end
    end
end

---@param packagesData (string|PackageData)[]
---@param doas boolean?
function m.ensure_installed(packagesData, doas)
    -- NOTE: use this after i try to implement windows and mac{{{
    -- if osData.sysname == "Linux" then
    -- end}}}

    for i = 1, #packagesData do
        m._catagorizePackages(packagesData[i])
    end

    if doas == true then
        m._rootCommand = "doas "
    end

    local install = require("metapack.utils.packageManager").installPackages
    install(m._portagePackages, m._rootCommand .. " emerge --ask y --verbose --color y --quiet-build y ")
    install(m._pacmanPackages, m._rootCommand .. " pacman -S ")
    install(m._aurPackages, m._aurHelper .. " -S ")
    install(m._aurPackages, m._rootCommand .. " apt-get install ")

    if #m._masonPackages > 0 then -- {{{
        for i = 1, #m._masonPackages do
            m._masonCommand = m._masonCommand .. " " .. m._masonPackages[i]
        end
        vim.cmd("MasonInstall" .. m._masonCommand)
    end -- }}}
end

return m
