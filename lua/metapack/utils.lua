local m = {}

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
    if executableName == nil then
        executableName = packageName
    end
    if vim.fn.executable(executableName) == 1 or require("mason-registry").is_installed(packageName) == true then
        return true
    end
    return false
end

return m
