local M = {}

-- Lazy-load dependencies to avoid errors if telescope is not installed
local function get_utilities()
	local base64 = require("nvim-utils.base64")
	local json = require("nvim-utils.json")
	local url = require("nvim-utils.url")
	local uuid = require("nvim-utils.uuid")
	local rayso = require("nvim-utils.rayso")
	local jwt = require("nvim-utils.jwt")
	local timestamp = require("nvim-utils.timestamp")
	local case = require("nvim-utils.case")

	return {
	{
		name = "Base64 Encode",
		desc = "Encode selection as base64",
		action = base64.encode_selection,
		requires_selection = true,
	},
	{
		name = "Base64 Decode",
		desc = "Decode base64 selection",
		action = base64.decode_selection,
		requires_selection = true,
	},
	{
		name = "JSON Format",
		desc = "Format JSON selection",
		action = json.format_selection,
		requires_selection = true,
	},
	{
		name = "URL Encode",
		desc = "URL encode selection",
		action = url.encode_selection,
		requires_selection = true,
	},
	{
		name = "URL Decode",
		desc = "URL decode selection",
		action = url.decode_selection,
		requires_selection = true,
	},
	{
		name = "Generate UUID",
		desc = "Insert UUID at cursor",
		action = uuid.insert_uuid,
		requires_selection = false,
	},
	{
		name = "Generate Ray.so Snippet",
		desc = "Create code snippet with ray.so",
		action = rayso.generate_from_selection,
		requires_selection = true,
	},
	{
		name = "JWT Decode",
		desc = "Decode JWT token",
		action = jwt.decode_selection,
		requires_selection = true,
	},
	{
		name = "Timestamp Convert",
		desc = "Convert timestamp/date",
		action = timestamp.convert_selection,
		requires_selection = true,
	},
	{
		name = "Insert Timestamp",
		desc = "Insert Unix timestamp at cursor",
		action = timestamp.insert_timestamp,
		requires_selection = false,
	},
	{
		name = "Case Convert",
		desc = "Convert text case",
		action = case.convert_selection,
		requires_selection = true,
	},
	}
end

function M.show_utils(opts)
	opts = opts or {}

	-- Lazy-load telescope dependencies
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local utils = require("nvim-utils.utils")

	local utilities = get_utilities()
	local available_utils = {}
	local has_selection = utils.has_selection()

	for _, util in ipairs(utilities) do
		if not util.requires_selection or has_selection then
			table.insert(available_utils, util)
		end
	end

	if #available_utils == 0 then
		vim.notify("No utilities available. Please select text first.", vim.log.levels.WARN)
		return
	end

	pickers
		.new(opts, {
			prompt_title = "Text Utilities",
			finder = finders.new_table({
				results = available_utils,
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry.name,
						ordinal = entry.name .. " " .. entry.desc,
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
			previewer = false,
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)

					if selection then
						local util = selection.value
						util.action()
					end
				end)

				return true
			end,
		})
		:find()
end

return M
