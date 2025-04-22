local m = {}

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
end

return m
