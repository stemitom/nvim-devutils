local M = {}
local utils = require("nvim-utils.utils")

--- Validate JSON string
--- @param json_str: string: JSON string to validate
--- @return boolean: true if valid JSON, false otherwise
local function validate_json(json_str)
	local ok, _ = pcall(vim.fn.json_decode, json_str)
	return ok
end

function M.format(json_str)
	if type(json_str) ~= "string" then
		return nil, "json.format expects a string, got " .. type(json_str)
	end

	-- Validate JSON first
	if not validate_json(json_str) then
		return nil, "Invalid JSON"
	end

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
	local text = utils.get_selection()
	if not text then
		vim.notify("No selection found. Please select text first.", vim.log.levels.WARN)
		return
	end

	local ok, formatted = pcall(M.format, text)
	if not ok or not formatted then
		vim.notify("Invalid JSON input", vim.log.levels.ERROR)
		return
	end

	utils.replace_selection(formatted)
end

return M
