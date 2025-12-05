local M = {}
local utils = require("nvim-utils.utils")

function M.encode(data)
	if not data or data == "" then
		return ""
	end
	if type(data) ~= "string" then
		error("base64.encode expects a string, got " .. type(data))
	end
	return vim.base64_encode(data)
end

function M.decode(data)
	if not data or data == "" then
		return ""
	end
	if type(data) ~= "string" then
		error("base64.decode expects a string, got " .. type(data))
	end
	return vim.base64_decode(data)
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
		vim.notify("Invalid base64 input", vim.log.levels.ERROR)
		return
	end

	utils.replace_selection(decoded)
end

return M
