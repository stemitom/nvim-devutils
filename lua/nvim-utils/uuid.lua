local M = {}

-- Seed random number generator for UUID generation
math.randomseed(os.time())

function M.generate()
	local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
	return string.gsub(template, "[xy]", function(c)
		local v = (c == "x") and math.random(0, 15) or math.random(8, 11)
		return string.format("%x", v)
	end)
end

function M.insert_uuid()
	local uuid = M.generate()
	local pos = vim.api.nvim_win_get_cursor(0)
	local line = vim.api.nvim_get_current_line()
	local new_line = line:sub(1, pos[2]) .. uuid .. line:sub(pos[2] + 1)
	vim.api.nvim_set_current_line(new_line)

	vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] + #uuid })
end

return M
