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
    _enableLuix = false,
    _enableMason = false,
    sharedData = {
        portagePackages = {},
        masonPackages = {},
        pacmanPackages = {},
        aurPackages = {},
        aurHelper = "",
        aptPackages = {},
        nixPackages = {},
        osData = "",
        rootCommand = "sudo ",
        masonCommand = "",
        enableLuix = false,
        enableMason = false,
        osName = "",
    },
}

local packageManager = require("metapack.utils.packageManager")
local json = require("metapack.utils.json")
local lowLevel = require("metapack.utils.lowLevel")
local system = require("metapack.utils.system")

local oldPackageDataBase = json.readDataBase()
local packageDataBase = vim.deepcopy(oldPackageDataBase)

---@param packageData (string|PackageData)
---@return nil
---@nodoc FIXME: this function is an unoptimized peice of shit, and i need to rewrite it when i'm not thinking about killing myself
function m._catagorizePackages(packageData)
    if type(packageData) == "string" then
        if packageManager.ifInPath(packageData) == false then
            lowLevel.tableUpdate(packageDataBase, { [packageData] = { installed = false } })
            vim.notify("Searching for " .. packageData, vim.log.levels.INFO)
            packageManager.packageInsert(packageData, m.sharedData, packageDataBase)
            if m._enableMason and require("mason-registry").has_package(packageData) then
                table.insert(m._masonPackages, packageData)
                lowLevel.tableUpdate(packageDataBase, { [packageData] = { installers = { mason = true } } })
            else
                vim.notify("Can't find " .. packageData .. " on any known package database!", vim.log.levels.WARN)
                lowLevel.tableUpdate(packageDataBase, { [packageData] = { installable = false } })
            end
        else
            lowLevel.tableUpdate(packageDataBase, { [packageData] = { installed = true } })
        end
    elseif type(packageData) == "table" then
        packageData.execName = packageData.execName or packageData[1]
        if packageData.force or packageManager.ifInPath(packageData.execName) == false then
            lowLevel.tableUpdate(packageDataBase, { [packageData[1]] = { installed = false } })
            if packageData.os == nil or string.find(m._osData, packageData.os) then
                if packageData.portage then
                    table.insert(m._portagePackages, packageData[1])
                    lowLevel.tableUpdate(packageDataBase, { [packageData[1]] = { installers = { portage = true } } })
                end
                if m._enableMason and packageData.mason then
                    table.insert(m._masonPackages, packageData[1])
                    lowLevel.tableUpdate(packageDataBase, { [packageData[1]] = { installers = { mason = true } } })
                end
                if packageData.pacman then
                    table.insert(m._pacmanPackages, packageData[1])
                    lowLevel.tableUpdate(packageDataBase, { [packageData[1]] = { installers = { pacman = true } } })
                end
                if packageData.aur then
                    m._aurHelper = packageManager.setAurHelper()
                    table.insert(m._aurPackages, packageData[1])
                    lowLevel.tableUpdate(packageDataBase, { [packageData[1]] = { installers = { aur = true } } })
                end
                if packageData.apt then
                    table.insert(m._aptPackages, packageData[1])
                    lowLevel.tableUpdate(packageDataBase, { [packageData[1]] = { installers = { apt = true } } })
                end
                if packageData.nix then
                    table.insert(m._nixPackages, packageData[1])
                    lowLevel.tableUpdate(packageDataBase, { [packageData[1]] = { installers = { nix = true } } })
                end
            end
        else
            lowLevel.tableUpdate(packageDataBase, { [packageData[1]] = { installed = true } })
        end
    end
end

function m.setup(opts)
    -- NOTE: use this after i try to implement windows and mac{{{
    -- if osData.sysname == "Linux" then
    -- end}}}
    m._enableMason, _ = pcall(function()
        require("mason")
    end)
    m._enableLuix, _ = pcall(function()
        require("luix")
    end)
    m._enableLuse, _ = pcall(function()
        require("luse")
    end)

    m.sharedData.osName = system.setOS()

    for i = 1, #opts.ensure_installed do
        m._catagorizePackages(opts.ensure_installed[i])
    end

    if vim.deep_equal(oldPackageDataBase, packageDataBase) == false then
        json.writeDataBase(packageDataBase)
    end

    if opts.doas then
        m._rootCommand = "doas "
    end

    if m._enableLuse and #m._portagePackages > 0 then
        local installCommand = m._rootCommand
            .. " "
            .. os.getenv("SHELL")
            .. " -c \"echo '# THIS FILE HAS BEEN AUTOMATICALLY GENERATED BY METAPACK.NVIM!!!\n# YOU SHOULD NOT EDIT THIS FILE, INSTEAD EDIT YOUR METAPACK.NVIM CONFIGURATION!!!\n\n\n"
            .. require("luse").generateFile(m._portagePackages)
            .. "' > /etc/portage/package.use/metapack.nvim && emerge --ask y --verbose --color y --quiet-build y"

        for i = 1, #m._portagePackages do
            installCommand = installCommand .. " " .. m._portagePackages[i]
        end
        installCommand = installCommand .. '"'

        require("smart-term").openSpliTerm(installCommand)
    end
    packageManager.installPackages(m._pacmanPackages, m._rootCommand .. " pacman -S ")
    packageManager.installPackages(m._aurPackages, m._aurHelper .. " -S ")
    packageManager.installPackages(m._aptPackages, m._rootCommand .. " apt-get install ")

    if m._enableMason and #m._masonPackages > 0 then -- {{{
        for i = 1, #m._masonPackages do
            m._masonCommand = m._masonCommand .. " " .. m._masonPackages[i]
        end
        vim.cmd("MasonInstall" .. m._masonCommand)
    end -- }}}

    if m._enableLuix and #m._nixPackages > 0 then
        for key, value in pairs(packageDataBase) do
            local success, output = pcall(function()
                return value.installers.nix
            end)
            if value.installed and success and output then
                table.insert(m._nixPackages, packageManager.nameSubstitute(key, "nix"))
            end
        end

        local packages = {}
        packages.python313Packages = {}
        packages.python312Packages = {}
        for i = 1, #m._nixPackages do
            local packageName = packageManager.nameSubstitute(m._nixPackages[i], "nix")
            if vim.startswith(packageName, "python313Packages.") then
                table.insert(packages.python313Packages, m._nixPackages[i])
            elseif vim.startswith(packageName, "python312Packages.") then
                table.insert(packages.python312Packages, m._nixPackages[i])
            else
                table.insert(packages, m._nixPackages[i])
            end
        end

        table.sort(packages)

        local luix = require("luix")
        luix.saveFile(
            "# THIS FILE HAS BEEN AUTOMATICALLY GENERATED BY METAPACK.NVIM!!!\n# YOU SHOULD NOT EDIT THIS FILE, INSTEAD EDIT YOUR METAPACK.NVIM CONFIGURATION!!!\n\n\n"
                .. luix.parse({ "pkgs", "inputs", "..." }, { systemPackages = packages }),
            opts.nixOutputFile
        )
        require("smart-term").openSpliTerm(
            "git -C "
                .. opts.nixFlakeDir
                .. " add "
                .. opts.nixOutputFile
                .. " && "
                .. m._rootCommand
                .. ' nixos-rebuild switch --flake "'
                .. opts.nixFlakeDir
                .. "?submodules=1#"
                .. vim.fn.hostname()
		.. '"'
        )
    end

    vim.api.nvim_create_user_command("Metapack", function()
        require("metapack.utils.ui.draw").showUI()
    end, { desc = "Calls the metapack ui" })
end

return m
