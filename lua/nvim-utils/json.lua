local M = {}

function M.format(json_str)
	local indent = 0
	local result = {}
	local in_string = false
	local escape_next = false

	for i = 1, #json_str do
		local char = json_str:sub(i, i)

		if escape_next then
			table.insert(result, char)
			escape_next = false
		elseif char == "\\" and in_string then
			table.insert(result, char)
			escape_next = true
		elseif char == '"' then
			table.insert(result, char)
			in_string = not in_string
		elseif not in_string then
			if char == "{" or char == "[" then
				table.insert(result, char)
				table.insert(result, "\n")
				indent = indent + 1
				table.insert(result, string.rep("  ", indent))
			elseif char == "}" or char == "]" then
				while #result > 0 and result[#result] == " " do
					table.remove(result)
				end
				table.insert(result, "\n")
				indent = indent - 1
				table.insert(result, string.rep("  ", indent))
				table.insert(result, char)
			elseif char == "," then
				table.insert(result, char)
				table.insert(result, "\n")
				table.insert(result, string.rep("  ", indent))
			elseif char == ":" then
				table.insert(result, char)
				table.insert(result, " ")
			elseif char ~= " " and char ~= "\t" and char ~= "\n" and char ~= "\r" then
				table.insert(result, char)
			end
		else
			table.insert(result, char)
		end
	end

	return table.concat(result)
end

function M.format_selection()
	local lines = vim.fn.getline("'<", "'>")
	local text = table.concat(lines, "")

	local ok, formatted = pcall(M.format, text)
	if not ok then
		vim.notify("Invalid JSON input", vim.log.levels.ERROR)
		return
	end

	local result_lines = vim.split(formatted, "\n")
	vim.api.nvim_buf_set_lines(0, vim.fn.line("'<") - 1, vim.fn.line("'>"), false, result_lines)
end

return M
