local m = {}

---@return string
---Sets the AUR helper, currently supports yay, and paru
---If you want to add something just add it to the `aurHelperList`
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
