---@type table
local m = {}

---@return boolean
---@param executableName string
function m._checkinstalled(executableName)
	if vim.uv.fs_stat("/usr/bin/" .. executableName) or vim.uv.fs_stat("/bin/" .. executableName) then
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
			if
				string.find(osData.release, "gentoo")
				and m._checkinstalled(packagesData[i]) == false
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

	---@type string
	local command = ""
	if #emergePackages > 0 then
		if doas == true then
			command = command .. "doas"
		else
			command = command .. "sudo"
		end
		command = command .. " emerge --ask y --verbose --color y --quiet-build y"
		for i = 1, #emergePackages do
			command = command .. " " .. emergePackages[i]
		end
	end

	if #masonPackages > 0 then
		require("mason-tool-installer").setup(masonPackages)
	end

	-- vim.print(masonPackages)
	-- vim.print(emergePackages)

	if #command > 0 then
		vim.cmd("bot split|" .. "resize 10|" .. "terminal " .. command)
	end
end

return m
