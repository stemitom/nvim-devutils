local M = {}
local utils = require("nvim-utils.utils")

--- Decode a base64url string (JWT uses base64url, not standard base64)
--- @param input string: Base64url encoded string
--- @return string: Decoded string
local function base64url_decode(input)
	-- Replace URL-safe characters with standard base64 characters
	input = input:gsub("-", "+"):gsub("_", "/")

	-- Add padding if needed
	local padding = #input % 4
	if padding > 0 then
		input = input .. string.rep("=", 4 - padding)
	end

	return vim.base64_decode(input)
end

--- Parse a JWT token and return its parts
--- @param token string: JWT token string
--- @return table|nil: Table with header, payload, signature or nil on error
--- @return string|nil: Error message if parsing failed
function M.parse(token)
	if type(token) ~= "string" then
		return nil, "jwt.parse expects a string, got " .. type(token)
	end

	-- Remove whitespace
	token = token:gsub("%s+", "")

	-- Split by dots
	local parts = {}
	for part in token:gmatch("[^%.]+") do
		table.insert(parts, part)
	end

	if #parts ~= 3 then
		return nil, "Invalid JWT format: expected 3 parts separated by dots"
	end

	-- Decode header
	local ok_header, header_json = pcall(base64url_decode, parts[1])
	if not ok_header then
		return nil, "Failed to decode JWT header"
	end

	local ok_header_parse, header = pcall(vim.fn.json_decode, header_json)
	if not ok_header_parse then
		return nil, "Invalid JSON in JWT header"
	end

	-- Decode payload
	local ok_payload, payload_json = pcall(base64url_decode, parts[2])
	if not ok_payload then
		return nil, "Failed to decode JWT payload"
	end

	local ok_payload_parse, payload = pcall(vim.fn.json_decode, payload_json)
	if not ok_payload_parse then
		return nil, "Invalid JSON in JWT payload"
	end

	return {
		header = header,
		payload = payload,
		signature = parts[3],
	}
end

--- Format JWT parts as a readable string
--- @param jwt_data table: Parsed JWT data
--- @return string: Formatted JWT string
local function format_jwt(jwt_data)
	local json = require("nvim-utils.json")

	local lines = {}
	table.insert(lines, "=== JWT Header ===")
	local header_formatted = json.format(vim.fn.json_encode(jwt_data.header))
	table.insert(lines, header_formatted or vim.fn.json_encode(jwt_data.header))
	table.insert(lines, "")
	table.insert(lines, "=== JWT Payload ===")
	local payload_formatted = json.format(vim.fn.json_encode(jwt_data.payload))
	table.insert(lines, payload_formatted or vim.fn.json_encode(jwt_data.payload))
	table.insert(lines, "")
	table.insert(lines, "=== Signature ===")
	table.insert(lines, jwt_data.signature)

	-- Add helpful info about common claims
	if jwt_data.payload.exp then
		local exp_date = os.date("%Y-%m-%d %H:%M:%S", jwt_data.payload.exp)
		local now = os.time()
		local expired = jwt_data.payload.exp < now
		table.insert(lines, "")
		table.insert(lines, "=== Token Info ===")
		table.insert(lines, "Expires: " .. exp_date .. (expired and " (EXPIRED)" or ""))
	end

	if jwt_data.payload.iat then
		local iat_date = os.date("%Y-%m-%d %H:%M:%S", jwt_data.payload.iat)
		if not jwt_data.payload.exp then
			table.insert(lines, "")
			table.insert(lines, "=== Token Info ===")
		end
		table.insert(lines, "Issued: " .. iat_date)
	end

	return table.concat(lines, "\n")
end

--- Decode JWT from selection and show in a popup
function M.decode_selection()
	local token = utils.get_selection()
	if not token then
		vim.notify("No selection found. Please select text first.", vim.log.levels.WARN)
		return
	end

	local jwt_data, err = M.parse(token)
	if not jwt_data then
		vim.notify(err or "Failed to parse JWT", vim.log.levels.ERROR)
		return
	end

	local formatted = format_jwt(jwt_data)

	-- Create a popup buffer
	local buf = vim.api.nvim_create_buf(false, true)
	local lines = vim.split(formatted, "\n")
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- Calculate popup dimensions
	local width = 0
	for _, line in ipairs(lines) do
		width = math.max(width, #line)
	end
	width = math.min(width + 4, vim.o.columns - 4)
	local height = math.min(#lines + 2, vim.o.lines - 4)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
		title = " JWT Decoded ",
		title_pos = "center",
	})

	vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
	vim.api.nvim_set_option_value("filetype", "json", { buf = buf })

	-- Close on q or Escape
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(win, true)
	end, { buffer = buf })

	vim.keymap.set("n", "<Esc>", function()
		vim.api.nvim_win_close(win, true)
	end, { buffer = buf })
end

return M
