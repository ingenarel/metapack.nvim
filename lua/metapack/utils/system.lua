local m = { osData = "" }

function m.setOS()
    if vim.fn.has("win32") == 0 then
        m.osData = vim.system({ "grep", "-i", "-E", '^(id|id_like|name|pretty_name)="?.+"?', "/etc/os-release" })
            :wait().stdout
    else
        m.osData = "windows"
    end
    if string.find(m.osData, "gentoo") then
        return "gentoo"
    elseif string.find(m.osData, "arch") then
        return "arch"
    elseif string.find(m.osData, "debian") then
        return "debian"
    elseif string.find(m.osData, "nixos") then
        return "nixos"
    end
end

return m
