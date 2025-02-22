local m = {}

function m.create()
    vim.fn.mkdir(vim.fn.stdpath("data") .. "/metapack", "p")
    local file = io.open(vim.fn.stdpath("data") .. "/metapack/test.json", "w")
    if file == nil then
        error("cannot create file")
    else
        file:close()
    end
end

function m.tableUpdate(table1, table2)
    for key, value in pairs(table2) do
        if type(value) == "table" then
            if type(table1[key]) ~= "table" then
                table1[key] = {}
            end
            m.tableUpdate(table1[key], value)
        else
            table1[key] = value
        end
    end
    return table1
end

function m.update(data)
    local file = io.open(vim.fn.stdpath("data") .. "/metapack/test.json", "w")
    local content
    if file == nil then
        m.create()
        local file = io.open(vim.fn.stdpath("data") .. "/metapack/test.json", "r")
        if file ~= nil then
            content = file:read()
            file:close()
        end
    end
    -- vim.print(pcall(vim.json.decode, content))
    local success = pcall(vim.json.decode, content)
    if success == false then
        content = { codelldb = { installers = { portage = true } } }
    end
    vim.print(m.tableUpdate(content, data))
end

m.update { codelldb = { installers = { mason = true } } }

return m
