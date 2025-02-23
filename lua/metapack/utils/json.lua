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

function m.readDataBase()
    local file = io.open(vim.fn.stdpath("data") .. "/metapack/test.json", "r")
    local fileContent
    if file == nil then
        m.create()
        file = io.open(vim.fn.stdpath("data") .. "/metapack/test.json", "r")
    end
    if file ~= nil then
        fileContent = file:read("*a")
        file:close()
    end
    local success, functionOutput = pcall(vim.json.decode, fileContent)
    if success == false then
        fileContent = {}
    else
        fileContent = functionOutput
    end
    return fileContent
end

function m.writeDataBase(table)
    local outputJson = vim.json.encode(table)
    if outputJson ~= false then
        local file = io.open(vim.fn.stdpath("data") .. "/metapack/test.json", "w")
        if file ~= nil then
            file:write(outputJson)
            file:close()
        end
    end
end

return m
