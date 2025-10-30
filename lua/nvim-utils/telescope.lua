local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local base64 = require("nvim-utils.base64")
local json = require("nvim-utils.json")
local url = require("nvim-utils.url")
local uuid = require("nvim-utils.uuid")
local rayso = require("nvim-utils.rayso")

local M = {}

local utilities = {
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
}

local function has_visual_selection()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	return start_pos[2] > 0 and end_pos[2] > 0 and start_pos[2] <= end_pos[2]
end

function M.show_utils(opts)
	opts = opts or {}

	local available_utils = {}
	local has_selection = has_visual_selection()

	for _, util in ipairs(utilities) do
		if not util.requires_selection or has_selection then
			table.insert(available_utils, util)
		end
	end

	if #available_utils == 0 then
		vim.notify("No utilities available. Try selecting some text first.", vim.log.levels.WARN)
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
