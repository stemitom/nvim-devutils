local M = {}

function M.encode(str)
	if not str then
		return ""
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

	str = string.gsub(str, "%%(%x%x)", function(hex)
		return string.char(tonumber(hex, 16))
	end)

	return str
end

function M.encode_selection()
	local lines = vim.fn.getline("'<", "'>")
	local text = table.concat(lines, "\n")
	local encoded = M.encode(text)

	vim.api.nvim_buf_set_lines(0, vim.fn.line("'<") - 1, vim.fn.line("'>"), false, { encoded })
end

function M.decode_selection()
	local lines = vim.fn.getline("'<", "'>")
	local text = table.concat(lines, "\n")

	local ok, decoded = pcall(M.decode, text)
	if not ok then
		vim.notify("Invalid URL encoded input", vim.log.levels.ERROR)
		return
	end

	local result_lines = vim.split(decoded, "\n")
	vim.api.nvim_buf_set_lines(0, vim.fn.line("'<") - 1, vim.fn.line("'>"), false, result_lines)
end

return M
