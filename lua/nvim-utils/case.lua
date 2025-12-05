local M = {}
local utils = require("nvim-utils.utils")

--- Split a string into words, handling various case formats
--- @param str string: Input string
--- @return table: Array of lowercase words
local function split_words(str)
	local words = {}

	-- First, handle separators (space, dash, underscore, dot)
	str = str:gsub("[%s%-_%.]+", " ")

	-- Then handle camelCase and PascalCase by inserting spaces before uppercase letters
	str = str:gsub("(%l)(%u)", "%1 %2")
	str = str:gsub("(%u+)(%u%l)", "%1 %2")

	-- Split by spaces and collect words
	for word in str:gmatch("%S+") do
		if #word > 0 then
			table.insert(words, word:lower())
		end
	end

	return words
end

--- Convert to camelCase
--- @param str string: Input string
--- @return string: camelCase string
function M.to_camel(str)
	if type(str) ~= "string" then
		error("case.to_camel expects a string, got " .. type(str))
	end

	local words = split_words(str)
	if #words == 0 then
		return str
	end

	local result = words[1]
	for i = 2, #words do
		result = result .. words[i]:sub(1, 1):upper() .. words[i]:sub(2)
	end

	return result
end

--- Convert to PascalCase
--- @param str string: Input string
--- @return string: PascalCase string
function M.to_pascal(str)
	if type(str) ~= "string" then
		error("case.to_pascal expects a string, got " .. type(str))
	end

	local words = split_words(str)
	if #words == 0 then
		return str
	end

	local result = ""
	for _, word in ipairs(words) do
		result = result .. word:sub(1, 1):upper() .. word:sub(2)
	end

	return result
end

--- Convert to snake_case
--- @param str string: Input string
--- @return string: snake_case string
function M.to_snake(str)
	if type(str) ~= "string" then
		error("case.to_snake expects a string, got " .. type(str))
	end

	local words = split_words(str)
	return table.concat(words, "_")
end

--- Convert to SCREAMING_SNAKE_CASE
--- @param str string: Input string
--- @return string: SCREAMING_SNAKE_CASE string
function M.to_screaming(str)
	if type(str) ~= "string" then
		error("case.to_screaming expects a string, got " .. type(str))
	end

	local words = split_words(str)
	local upper_words = {}
	for _, word in ipairs(words) do
		table.insert(upper_words, word:upper())
	end

	return table.concat(upper_words, "_")
end

--- Convert to kebab-case
--- @param str string: Input string
--- @return string: kebab-case string
function M.to_kebab(str)
	if type(str) ~= "string" then
		error("case.to_kebab expects a string, got " .. type(str))
	end

	local words = split_words(str)
	return table.concat(words, "-")
end

--- Convert to Title Case
--- @param str string: Input string
--- @return string: Title Case string
function M.to_title(str)
	if type(str) ~= "string" then
		error("case.to_title expects a string, got " .. type(str))
	end

	local words = split_words(str)
	local titled = {}
	for _, word in ipairs(words) do
		table.insert(titled, word:sub(1, 1):upper() .. word:sub(2))
	end

	return table.concat(titled, " ")
end

--- Convert selection with interactive picker
function M.convert_selection()
	local text = utils.get_selection()
	if not text then
		vim.notify("No selection found. Please select text first.", vim.log.levels.WARN)
		return
	end

	local options = {
		{ name = "camelCase", fn = M.to_camel },
		{ name = "PascalCase", fn = M.to_pascal },
		{ name = "snake_case", fn = M.to_snake },
		{ name = "SCREAMING_SNAKE", fn = M.to_screaming },
		{ name = "kebab-case", fn = M.to_kebab },
		{ name = "Title Case", fn = M.to_title },
	}

	local display = {}
	for _, opt in ipairs(options) do
		local preview = opt.fn(text)
		table.insert(display, opt.name .. ": " .. preview)
	end

	vim.ui.select(display, {
		prompt = "Convert to:",
	}, function(choice, idx)
		if choice and idx then
			local result = options[idx].fn(text)
			utils.replace_selection(result)
		end
	end)
end

--- Direct conversion functions for keybindings
function M.to_camel_selection()
	local text = utils.get_selection()
	if not text then
		vim.notify("No selection found. Please select text first.", vim.log.levels.WARN)
		return
	end
	utils.replace_selection(M.to_camel(text))
end

function M.to_snake_selection()
	local text = utils.get_selection()
	if not text then
		vim.notify("No selection found. Please select text first.", vim.log.levels.WARN)
		return
	end
	utils.replace_selection(M.to_snake(text))
end

function M.to_kebab_selection()
	local text = utils.get_selection()
	if not text then
		vim.notify("No selection found. Please select text first.", vim.log.levels.WARN)
		return
	end
	utils.replace_selection(M.to_kebab(text))
end

return M
