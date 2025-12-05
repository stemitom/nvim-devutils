local M = {}
local utils = require("nvim-utils.utils")

--- Check if a string looks like a Unix timestamp
--- @param str string: String to check
--- @return boolean: True if it looks like a timestamp
local function is_unix_timestamp(str)
	-- Unix timestamps are typically 10 digits (seconds) or 13 digits (milliseconds)
	return str:match("^%d+$") and (#str == 10 or #str == 13 or #str <= 10)
end

--- Convert Unix timestamp to human-readable date
--- @param timestamp number: Unix timestamp (seconds or milliseconds)
--- @return string: Formatted date string
function M.to_date(timestamp)
	if type(timestamp) ~= "number" then
		error("timestamp.to_date expects a number, got " .. type(timestamp))
	end

	-- Handle milliseconds (13 digits)
	if timestamp > 9999999999 then
		timestamp = math.floor(timestamp / 1000)
	end

	return os.date("%Y-%m-%d %H:%M:%S", timestamp)
end

--- Convert human-readable date to Unix timestamp
--- Supports formats: "YYYY-MM-DD", "YYYY-MM-DD HH:MM:SS"
--- @param date_str string: Date string
--- @return number|nil: Unix timestamp or nil on error
--- @return string|nil: Error message if parsing failed
function M.to_timestamp(date_str)
	if type(date_str) ~= "string" then
		return nil, "timestamp.to_timestamp expects a string, got " .. type(date_str)
	end

	-- Try to parse "YYYY-MM-DD HH:MM:SS"
	local year, month, day, hour, min, sec = date_str:match("(%d+)-(%d+)-(%d+)%s+(%d+):(%d+):(%d+)")

	if not year then
		-- Try "YYYY-MM-DD"
		year, month, day = date_str:match("(%d+)-(%d+)-(%d+)")
		hour, min, sec = 0, 0, 0
	end

	if not year then
		return nil, "Invalid date format. Use YYYY-MM-DD or YYYY-MM-DD HH:MM:SS"
	end

	local time_table = {
		year = tonumber(year),
		month = tonumber(month),
		day = tonumber(day),
		hour = tonumber(hour),
		min = tonumber(min),
		sec = tonumber(sec),
	}

	local ok, result = pcall(os.time, time_table)
	if not ok then
		return nil, "Invalid date values"
	end

	return result
end

--- Get current Unix timestamp
--- @return number: Current Unix timestamp
function M.now()
	return os.time()
end

--- Insert current timestamp at cursor
function M.insert_timestamp()
	local timestamp = tostring(M.now())
	local pos = vim.api.nvim_win_get_cursor(0)
	local line = vim.api.nvim_get_current_line()
	local new_line = line:sub(1, pos[2]) .. timestamp .. line:sub(pos[2] + 1)
	vim.api.nvim_set_current_line(new_line)
	vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] + #timestamp })
end

--- Convert selection between timestamp and date
function M.convert_selection()
	local text = utils.get_selection()
	if not text then
		vim.notify("No selection found. Please select text first.", vim.log.levels.WARN)
		return
	end

	text = text:gsub("^%s+", ""):gsub("%s+$", "")

	if is_unix_timestamp(text) then
		-- Convert timestamp to date
		local timestamp = tonumber(text)
		local date_str = M.to_date(timestamp)

		-- Show both local and UTC
		local utc_str = os.date("!%Y-%m-%d %H:%M:%S UTC", timestamp > 9999999999 and math.floor(timestamp / 1000) or timestamp)

		vim.ui.select({ "Local: " .. date_str, "UTC: " .. utc_str, "Replace with local", "Replace with UTC" }, {
			prompt = "Timestamp: " .. text,
		}, function(choice)
			if choice == "Replace with local" then
				utils.replace_selection(date_str)
			elseif choice == "Replace with UTC" then
				utils.replace_selection(utc_str)
			end
		end)
	else
		-- Convert date to timestamp
		local timestamp, err = M.to_timestamp(text)
		if not timestamp then
			vim.notify(err or "Failed to parse date", vim.log.levels.ERROR)
			return
		end

		vim.ui.select({
			"Seconds: " .. timestamp,
			"Milliseconds: " .. (timestamp * 1000),
			"Replace with seconds",
			"Replace with milliseconds",
		}, {
			prompt = "Date: " .. text,
		}, function(choice)
			if choice == "Replace with seconds" then
				utils.replace_selection(tostring(timestamp))
			elseif choice == "Replace with milliseconds" then
				utils.replace_selection(tostring(timestamp * 1000))
			end
		end)
	end
end

return M
