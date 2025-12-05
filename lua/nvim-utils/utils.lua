local M = {}

--- Get selected text from visual selection
--- @return string|nil: Selected text, or nil if no valid selection
function M.get_selection()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")

	-- Validate selection marks exist
	if start_pos[2] == 0 or end_pos[2] == 0 then
		return nil
	end

	local start_line = start_pos[2]
	local end_line = end_pos[2]
	local start_col = start_pos[3]
	local end_col = end_pos[3]

	-- Validate selection order
	if start_line > end_line or (start_line == end_line and start_col > end_col) then
		return nil
	end

	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

	if #lines == 0 then
		return nil
	end

	if #lines == 1 then
		lines[1] = string.sub(lines[1], start_col, end_col)
	else
		lines[1] = string.sub(lines[1], start_col)
		lines[#lines] = string.sub(lines[#lines], 1, end_col)
	end

	return table.concat(lines, "\n")
end

--- Replace selection with new text
--- @param text: string: Text to replace selection with
function M.replace_selection(text)
	local start_line = vim.fn.line("'<") - 1
	local end_line = vim.fn.line("'>")
	local result_lines = vim.split(text, "\n")
	vim.api.nvim_buf_set_lines(0, start_line, end_line, false, result_lines)
end

--- Check if there's a valid visual selection
--- @return boolean
function M.has_selection()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")

	if start_pos[2] == 0 or end_pos[2] == 0 then
		return false
	end

	local start_line = start_pos[2]
	local end_line = end_pos[2]
	local start_col = start_pos[3]
	local end_col = end_pos[3]

	return start_line < end_line or (start_line == end_line and start_col <= end_col)
end

return M
