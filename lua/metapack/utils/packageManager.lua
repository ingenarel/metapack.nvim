local m = {}

local lowLevel = require("metapack.utils.lowLevel")

---Sets the AUR helper, currently supports yay, and paru
---If you want to add something just add it to the `aurHelperList`
---@return string # returns the aur helper name. just the name, so just `paru`, `yay` etc etc
function m.setAurHelper()
    local aurHelperList = {
        "paru",
        "yay",
    }
    for i = 1, #aurHelperList do
        if vim.fn.executable(aurHelperList[i]) == 1 then
            return aurHelperList[i]
        end
    end
    return ""
end

---Checks if package is in path
---uses |vim.fn.executable| to check if `packageName` or the `executableName` exists, if not, checks the mason registry
---too
---@return boolean # true if it could find package, or false if it couldn't find package
---@param packageName string the package name
---@param executableName string? optional executable name if the package name isn't the same as the executable name
function m.ifInPath(packageName, executableName)
    executableName = executableName or packageName
    if vim.fn.executable(executableName) == 1 or require("mason-registry").is_installed(packageName) then
        return true
    end
    return false
end

---checks if package exist in repos
---@param packageName string the package name
---@param packageManager string package manager name
---@return boolean # true if exists, false if doesn't
function m.ifPackageExistInRepos(packageName, packageManager)
    --TODO: make stuff work in the background without using a blocking call like vim.system():wait()
    local commands = {
        portage = function()
            if vim.fn.executable("eix") == 1 then
                if vim.system({ "eix", "-r", "^" .. packageName .. "$" }):wait().code == 0 then
                    return true
                else
                    return false
                end
            elseif
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
        end,

        pacman = function()
            if vim.system({ "pacman", "-Ss", "^" .. packageName .. "$" }):wait().code == 0 then
                return true
            else
                return false
            end
        end,

        paru = function()
            if vim.system({ "paru", "-Ssx", "^" .. packageName .. "$" }):wait().code == 0 then
                return true
            else
                return false
            end
        end,

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

        nix = function()
            if
                vim.system({ "sh", "-c", "nix-search -n " .. packageName .. " | grep -E '^" .. packageName .. " '" })
                    :wait().code == 0
            then
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
end

function m.installPackages(packageList, installCommandPrefix)
    if #packageList > 0 then
        local installCommand = installCommandPrefix

        for i = 1, #packageList do
            installCommand = installCommand .. " " .. packageList[i]
        end
        require("smart-term").openSpliTerm(installCommand)
    end
end

function m.nameSubstitute(packageName, packageManagerName)
    local managers = {
        nix = {
            clangd = function()
                return "clang-tools"
            end,
            ["clang-format"] = function()
                return "clang-tools"
            end,
            debugpy = function()
                return "python313Packages.debugpy"
            end,
        },
        portage = {
            clangd = function()
                return "llvm-core/clang"
            end,
            jq = function()
                return "app-misc/jq"
            end,
        },
        default = function()
            return packageName
        end,
    }
    return (managers[packageManagerName][packageName] or managers.default)()
end

function m.packageInsert(packageName, sharedData, packageDataBase)
    local oss = {
        gentoo = function()
            local packageAltName = m.nameSubstitute(packageName, "portage")
            if m.ifPackageExistInRepos(packageAltName, "portage") then
                table.insert(sharedData.portagePackages, packageAltName)
                lowLevel.tableUpdate(packageDataBase, { [packageName] = { installers = { portage = true } } })
                return true
            end
        end,
        arch = function()
            if m.ifPackageExistInRepos(packageName, "pacman") then
                table.insert(sharedData.pacmanPackages, packageName)
                lowLevel.tableUpdate(packageDataBase, { [packageName] = { installers = { pacman = true } } })
                return true
            else
                --FIXME: don't do that, set sharedValue and use that
                sharedData.aurHelper = m.setAurHelper()
                if sharedData.aurHelper ~= "" and m.ifPackageExistInRepos(packageName, sharedData.aurHelper) then
                    table.insert(sharedData.aurPackages, packageName)
                    lowLevel.tableUpdate(packageDataBase, { [packageName] = { installers = { aur = true } } })
                    return true
                end
            end
        end,
        debian = function()
            if m.ifPackageExistInRepos(packageName, "apt") then
                table.insert(sharedData.aptPackages, packageName)
                lowLevel.tableUpdate(packageDataBase, { [packageName] = { installers = { apt = true } } })
                return true
            end
        end,
        nixos = function()
            local packageAltName = m.nameSubstitute(packageName, "nix")
            if m.ifPackageExistInRepos(packageAltName, "nix") then
                table.insert(sharedData.nixPackages, packageAltName)
                lowLevel.tableUpdate(packageDataBase, { [packageName] = { installers = { nix = true } } })
                return true
            end
        end,
    }
    return oss[sharedData.osName]()
end

return m
