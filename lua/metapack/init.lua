---@class initModule
local m = {
    _portagePackages = {},
    _masonPackages = {},
    _pacmanPackages = {},
    _aurPackages = {},
    _aurHelper = "",
    _aptPackages = {},
    _nixPackages = {},
    _osData = "",
    _rootCommand = "sudo ",
    _masonCommand = "",
}

local packageManager = require("metapack.utils.packageManager")
local json = require("metapack.utils.json")
local lowLevel = require("metapack.utils.lowLevel")

local oldPackageDataBase = json.readDataBase()
local packageDataBase = vim.deepcopy(oldPackageDataBase)

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
        if packageManager.ifInPath(packageData) == false then
            packageDataBase = lowLevel.tableUpdate(packageDataBase, { [packageData] = { installed = false } })
            vim.notify("Searching for " .. packageData, vim.log.levels.INFO)
            if string.find(m._osData, "gentoo") and packageManager.ifPackageExistInRepos(packageData, "portage") then
                table.insert(m._portagePackages, packageData)
                packageDataBase =
                    lowLevel.tableUpdate(packageDataBase, { [packageData] = { installers = { portage = true } } })
                return
            elseif string.find(m._osData, "arch") then
                if packageManager.ifPackageExistInRepos(packageData, "pacman") then
                    table.insert(m._pacmanPackages, packageData)
                    packageDataBase =
                        lowLevel.tableUpdate(packageDataBase, { [packageData] = { installers = { pacman = true } } })
                    return
                else
                    m._aurHelper = packageManager.setAurHelper()
                    if m._aurHelper ~= "" and packageManager.ifPackageExistInRepos(packageData, m._aurHelper) then
                        table.insert(m._aurPackages, packageData)
                        packageDataBase =
                            lowLevel.tableUpdate(packageDataBase, { [packageData] = { installers = { aur = true } } })
                        return
                    end
                end
            elseif string.find(m._osData, "debian") then
                if packageManager.ifPackageExistInRepos(packageData, "apt") then
                    table.insert(m._aptPackages, packageData)
                    packageDataBase =
                        lowLevel.tableUpdate(packageDataBase, { [packageData] = { installers = { apt = true } } })
                end
                return
            end
            if require("mason-registry").has_package(packageData) then
                table.insert(m._masonPackages, packageData)
                packageDataBase =
                    lowLevel.tableUpdate(packageDataBase, { [packageData] = { installers = { mason = true } } })
            else
                vim.notify("Can't find " .. packageData .. " on any known package database!", vim.log.levels.WARN)
                packageDataBase = lowLevel.tableUpdate(packageDataBase, { [packageData] = { installable = false } })
            end
        else
            packageDataBase = lowLevel.tableUpdate(packageDataBase, { [packageData] = { installed = true } })
        end
    elseif type(packageData) == "table" then
        if packageData.execName == nil then
            packageData.execName = packageData[1]
        end
        if packageData.force == true or packageManager.ifInPath(packageData.execName) == false then
            packageDataBase = lowLevel.tableUpdate(packageDataBase, { [packageData[1]] = { installed = false } })
            if packageData.os == nil or string.find(m._osData, packageData.os) then
                if packageData.portage then
                    table.insert(m._portagePackages, packageData[1])
                    packageDataBase = lowLevel.tableUpdate(
                        packageDataBase,
                        { [packageData[1]] = { installers = { portage = true } } }
                    )
                end
                if packageData.mason then
                    table.insert(m._masonPackages, packageData[1])
                    packageDataBase =
                        lowLevel.tableUpdate(packageDataBase, { [packageData[1]] = { installers = { mason = true } } })
                end
                if packageData.pacman then
                    table.insert(m._pacmanPackages, packageData[1])
                    packageDataBase =
                        lowLevel.tableUpdate(packageDataBase, { [packageData[1]] = { installers = { pacman = true } } })
                end
                if packageData.aur then
                    m._aurHelper = packageManager.setAurHelper()
                    table.insert(m._aurPackages, packageData[1])
                    packageDataBase =
                        lowLevel.tableUpdate(packageDataBase, { [packageData[1]] = { installers = { aur = true } } })
                end
                if packageData.apt then
                    table.insert(m._aptPackages, packageData[1])
                    packageDataBase =
                        lowLevel.tableUpdate(packageDataBase, { [packageData[1]] = { installers = { apt = true } } })
                end
            end
        else
            packageDataBase = lowLevel.tableUpdate(packageDataBase, { [packageData[1]] = { installed = true } })
        end
    end
end

function m.setup(opts)
    -- NOTE: use this after i try to implement windows and mac{{{
    -- if osData.sysname == "Linux" then
    -- end}}}

    for i = 1, #opts.ensure_installed do
        m._catagorizePackages(opts.ensure_installed[i])
    end

    if vim.deep_equal(oldPackageDataBase, packageDataBase) == false then
        json.writeDataBase(packageDataBase)
    end

    if opts.doas == true then
        m._rootCommand = "doas "
    end

    packageManager.installPackages(
        m._portagePackages,
        m._rootCommand .. " emerge --ask y --verbose --color y --quiet-build y "
    )
    packageManager.installPackages(m._pacmanPackages, m._rootCommand .. " pacman -S ")
    packageManager.installPackages(m._aurPackages, m._aurHelper .. " -S ")
    packageManager.installPackages(m._aurPackages, m._rootCommand .. " apt-get install ")

    if #m._masonPackages > 0 then -- {{{
        for i = 1, #m._masonPackages do
            m._masonCommand = m._masonCommand .. " " .. m._masonPackages[i]
        end
        vim.cmd("MasonInstall" .. m._masonCommand)
    end -- }}}

    vim.api.nvim_create_user_command("Metapack", function()
        require("metapack.utils.ui.draw").showUI()
    end, { desc = "Calls the metapack ui" })
end

return m
