---@class initModule
local m = {
    sharedData = {
        portagePackages = {},
        masonPackages = {},
        pacmanPackages = {},
        aurPackages = {},
        aurHelper = "",
        aptPackages = {},
        nixPackages = {},
        rootCommand = "sudo ",
        masonCommand = "",
        enableLuix = false,
        enableMason = false,
        enableLuse = false,
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
            -- vim.notify("Searching for " .. packageData, vim.log.levels.INFO)
            if packageManager.packageInsert(packageData, m.sharedData, packageDataBase) then
            elseif m.sharedData.enableMason and require("mason-registry").has_package(packageData) then
                table.insert(m.sharedData.masonPackages, packageData)
                lowLevel.tableUpdate(packageDataBase, { [packageData] = { installers = { mason = true } } })
            else
                -- vim.notify("Can't find " .. packageData .. " on any known package database!", vim.log.levels.WARN)
                lowLevel.tableUpdate(packageDataBase, { [packageData] = { installable = false } })
            end
        else
            lowLevel.tableUpdate(packageDataBase, { [packageData] = { installed = true } })
        end
    elseif type(packageData) == "table" then
        --[[
        {
            gentoo = {"bash-language-server", mason = true}
            default = "bash-language-server"
        }
        --]]
        local foundOs = false
        for key, value in pairs(packageData) do
            if key == m.sharedData.osName then
                value.execName = value.execName or value[1]
                if value.force or packageManager.ifInPath(value.execName) == false then
                    lowLevel.tableUpdate(packageDataBase, { [value[1]] = { installed = false } })
                    if value.portage then
                        table.insert(m.sharedData.portagePackages, value[1])
                        lowLevel.tableUpdate(packageDataBase, { [value[1]] = { installers = { portage = true } } })
                    end
                    if m.sharedData.enableMason and value.mason then
                        table.insert(m.sharedData.masonPackages, value[1])
                        lowLevel.tableUpdate(packageDataBase, { [value[1]] = { installers = { mason = true } } })
                    end
                    if value.pacman then
                        table.insert(m.sharedData.pacmanPackages, value[1])
                        lowLevel.tableUpdate(packageDataBase, { [value[1]] = { installers = { pacman = true } } })
                    end
                    if value.aur then
                        m.sharedData.aurHelper = packageManager.setAurHelper()
                        table.insert(m.sharedData.aurPackages, value[1])
                        lowLevel.tableUpdate(packageDataBase, { [value[1]] = { installers = { aur = true } } })
                    end
                    if value.apt then
                        table.insert(m.sharedData.aurPackages, value[1])
                        lowLevel.tableUpdate(packageDataBase, { [value[1]] = { installers = { apt = true } } })
                    end
                    if value.nix then
                        table.insert(m.sharedData.nixPackages, value[1])
                        lowLevel.tableUpdate(packageDataBase, { [value[1]] = { installers = { nix = true } } })
                    end
                foundOs = true
                break
            end
        end
        if foundOs == false then
            m._catagorizePackages(packageData.default)
        end
        -- packageData.execName = packageData.execName or packageData[1]
        -- if packageData.force or packageManager.ifInPath(packageData.execName) == false then
        -- lowLevel.tableUpdate(packageDataBase, { [packageData[1]] = { installed = false } })
        -- if m.sharedData.osName == packageData.os then

        -- elseif packageData.os == nil and lowLevel.tableDeepSearch(m.sharedData, packageData[i]) == false then
        --     print("yes")
        --     vim.print(m.sharedData)
        --     m._catagorizePackages(packageData[1])
        -- end
        -- else
        --     lowLevel.tableUpdate(packageDataBase, { [packageData[1]] = { installed = true } })
        -- end
    end
end

function m.setup(opts)
    -- NOTE: use this after i try to implement windows and mac{{{
    -- if osData.sysname == "Linux" then
    -- end}}}
    m.sharedData.enableMason, _ = pcall(function()
        require("mason")
    end)
    m.sharedData.enableLuix, _ = pcall(function()
        require("luix")
    end)
    m.sharedData.enableLuse, _ = pcall(function()
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
        m.sharedData.rootCommand = "doas "
    end

    if m.sharedData.enableLuse and #m.sharedData.portagePackages > 0 then
        local installCommand = m.sharedData.rootCommand
            .. " "
            .. os.getenv("SHELL")
            .. " -c \"echo '# THIS FILE HAS BEEN AUTOMATICALLY GENERATED BY METAPACK.NVIM!!!\n# YOU SHOULD NOT EDIT THIS FILE, INSTEAD EDIT YOUR METAPACK.NVIM CONFIGURATION!!!\n\n\n"
            .. require("luse").generateFile(m.sharedData.portagePackages)
            .. "' > /etc/portage/package.use/metapack.nvim && emerge --ask y --verbose --color y --quiet-build y"

        for i = 1, #m.sharedData.portagePackages do
            installCommand = installCommand .. " " .. m.sharedData.portagePackages[i]
        end
        installCommand = installCommand .. '"'

        require("smart-term").openSpliTerm(installCommand)
    end
    packageManager.installPackages(m.sharedData.pacmanPackages, m.sharedData.rootCommand .. " pacman -S ")
    packageManager.installPackages(m.sharedData.aurPackages, m.sharedData.aurHelper .. " -S ")
    packageManager.installPackages(m.sharedData.aptPackages, m.sharedData.rootCommand .. " apt-get install ")

    if m.sharedData.enableMason and #m.sharedData.masonPackages > 0 then -- {{{
        for i = 1, #m.sharedData.masonPackages do
            m.sharedData.masonCommand = m.sharedData.masonCommand .. " " .. m.sharedData.masonPackages[i]
        end
        vim.cmd("MasonInstall" .. m.sharedData.masonCommand)
    end -- }}}

    if m.sharedData.enableLuix and #m.sharedData.nixPackages > 0 then
        for key, value in pairs(packageDataBase) do
            local success, output = pcall(function()
                return value.installers.nix
            end)
            if value.installed and success and output then
                table.insert(m.sharedData.nixPackages, packageManager.nameSubstitute(key, "nix"))
            end
        end

        local packages = {}
        packages.python313Packages = {}
        packages.python312Packages = {}
        for i = 1, #m.sharedData.nixPackages do
            local packageName = packageManager.nameSubstitute(m.sharedData.nixPackages[i], "nix")
            if vim.startswith(packageName, "python313Packages.") then
                table.insert(packages.python313Packages, m.sharedData.nixPackages[i])
            elseif vim.startswith(packageName, "python312Packages.") then
                table.insert(packages.python312Packages, m.sharedData.nixPackages[i])
            else
                table.insert(packages, m.sharedData.nixPackages[i])
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
                .. m.sharedData.rootCommand
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
