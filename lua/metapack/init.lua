---@type table
local m = {}

---@return boolean
---@param packageName string
---@param executableName string?
function m._checkInPath(packageName, executableName)
    if executableName == nil then
        executableName = packageName
    end
    if vim.fn.executable(executableName) == 1 or require("mason-registry").is_installed(packageName) then
        return true
    end
    return false
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
                if
                    string.find(osData.release, "gentoo")
                    and vim.system({
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
                            packagesData[i],
                        })
                            :wait().code
                        == 0
                then
                    table.insert(portagePackages, packagesData[i])
                else
                    table.insert(masonPackages, packagesData[i])
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
