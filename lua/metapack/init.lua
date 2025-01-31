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
    local emergePackages = {}
    ---@type table
    local masonPackages = {}

    for i = 1, #packagesData do
        if type(packagesData[i]) == "string" then
            -- emerge --ask n --pretend --oneshot --nodeps --verbose n --color n
            -- vim.print(packagesData[i])
            -- vim.print(m._checkInPath(packagesData[i]))
            -- print(m._checkInPath(packagesData[i]))
            if m._checkInPath(packagesData[i]) == false then
                -- vim.print(packagesData[i] .. " = false")
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
                    table.insert(emergePackages, packagesData[i])
                else
                    table.insert(masonPackages, packagesData[i])
                end
            end
        end
        -- print("mason")
        -- vim.print(masonPackages)
        -- print("emerge")
        -- vim.print(emergePackages)
        -- print("\n")
    end

    ---@type string
    local emergeCommand = ""
    if #emergePackages > 0 then
        if doas == true then
            emergeCommand = emergeCommand .. "doas"
        else
            emergeCommand = emergeCommand .. "sudo"
        end
        emergeCommand = emergeCommand .. " emerge --ask y --verbose --color y --quiet-build y"
        for i = 1, #emergePackages do
            emergeCommand = emergeCommand .. " " .. emergePackages[i]
        end
    end

    ---@type string
    local masonCommand = ""
    if #masonPackages > 0 then
        -- require("mason-tool-installer").setup({ ensure_installed = masonPackages })
        for i = 1, #masonPackages do
            masonCommand = masonCommand .. " " .. masonPackages[i]
        end
        -- print(masonCommand)
        vim.cmd("MasonInstall" .. masonCommand)
    end

    if #emergeCommand > 0 then
        vim.cmd("bot split|" .. "resize 10|" .. "terminal " .. emergeCommand)
    end
end

return m
