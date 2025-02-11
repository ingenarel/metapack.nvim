local m = {}

---@return string
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

return m
