local M = {}
local utils = require("nvim-utils.utils")

function M.encode(str)
	if not str then
		return ""
	end
	if type(str) ~= "string" then
		error("url.encode expects a string, got " .. type(str))
	end

	str = string.gsub(str, "([^%w%-%.%_~])", function(c)
		return string.format("%%%02X", string.byte(c))
	end)

	return str
end

function M.decode(str)
	if not str then
		return ""
	end
	if type(str) ~= "string" then
		error("url.decode expects a string, got " .. type(str))
	end

	str = string.gsub(str, "%%(%x%x)", function(hex)
		return string.char(tonumber(hex, 16))
	end)

	return str
end

function M.encode_selection()
	local text = utils.get_selection()
	if not text then
		vim.notify("No selection found. Please select text first.", vim.log.levels.WARN)
		return
	end

	local ok, encoded = pcall(M.encode, text)
	if not ok then
		vim.notify("Failed to encode: " .. encoded, vim.log.levels.ERROR)
		return
	end

	utils.replace_selection(encoded)
end

function M.decode_selection()
	local text = utils.get_selection()
	if not text then
		vim.notify("No selection found. Please select text first.", vim.log.levels.WARN)
		return
	end

	local ok, decoded = pcall(M.decode, text)
	if not ok then
		vim.notify("Invalid URL encoded input", vim.log.levels.ERROR)
		return
	end

	utils.replace_selection(decoded)
end

return M
