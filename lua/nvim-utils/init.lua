local M = {}

local base64 = require("nvim-utils.base64")
local json = require("nvim-utils.json")
local url = require("nvim-utils.url")
local uuid = require("nvim-utils.uuid")
local rayso = require("nvim-utils.rayso")

local default_config = {
	mappings = {
		base64_encode = "<leader>ue",
		base64_decode = "<leader>ud",
		json_format = "<leader>uj",
		url_encode = "<leader>uU",
		url_decode = "<leader>uu",
		uuid_generate = "<leader>ug",
		rayso_generate = "<leader>ur",
		rayso_options = "<leader>uR",
		telescope_utils = "<leader>ut",
	},
	telescope = {
		enabled = true,
	},
}

--- Validate configuration keys and warn on unknown options
local function validate_config(user_opts)
	local valid_top_level_keys = { "mappings", "telescope" }
	local valid_mapping_keys = {
		"base64_encode",
		"base64_decode",
		"json_format",
		"url_encode",
		"url_decode",
		"uuid_generate",
		"rayso_generate",
		"rayso_options",
		"telescope_utils",
	}
	local valid_telescope_keys = { "enabled" }

	-- Check top-level keys
	for key, _ in pairs(user_opts) do
		if not vim.tbl_contains(valid_top_level_keys, key) then
			vim.notify(
				string.format("nvim-utils: Unknown config key '%s'. Valid keys: %s", key, table.concat(valid_top_level_keys, ", ")),
				vim.log.levels.WARN
			)
		end
	end

	-- Check mapping keys
	if user_opts.mappings then
		for key, _ in pairs(user_opts.mappings) do
			if not vim.tbl_contains(valid_mapping_keys, key) then
				vim.notify(
					string.format("nvim-utils: Unknown mapping key '%s'. Valid keys: %s", key, table.concat(valid_mapping_keys, ", ")),
					vim.log.levels.WARN
				)
			end
		end
	end

	-- Check telescope keys
	if user_opts.telescope then
		for key, _ in pairs(user_opts.telescope) do
			if not vim.tbl_contains(valid_telescope_keys, key) then
				vim.notify(
					string.format("nvim-utils: Unknown telescope key '%s'. Valid keys: %s", key, table.concat(valid_telescope_keys, ", ")),
					vim.log.levels.WARN
				)
			end
		end
	end
end

--- Merge configuration with defaults, supporting false to disable mappings
local function merge_config(user_opts)
	user_opts = user_opts or {}

	-- Validate configuration
	validate_config(user_opts)

	-- Create a copy of defaults
	local config = vim.deepcopy(default_config)

	-- Merge mappings
	if user_opts.mappings then
		for key, value in pairs(user_opts.mappings) do
			config.mappings[key] = value
		end
	end

	-- Merge telescope config
	if user_opts.telescope then
		config.telescope = vim.tbl_deep_extend("force", config.telescope, user_opts.telescope)
	end

	return config
end

function M.setup(opts)
	opts = opts or {}
	local config = merge_config(opts)

	-- Create user commands
	vim.api.nvim_create_user_command("Base64Encode", function()
		base64.encode_selection()
	end, { range = true, desc = "Encode selection as base64" })

	vim.api.nvim_create_user_command("Base64Decode", function()
		base64.decode_selection()
	end, { range = true, desc = "Decode base64 selection" })

	vim.api.nvim_create_user_command("JsonFormat", function()
		json.format_selection()
	end, { range = true, desc = "Format JSON selection" })

	vim.api.nvim_create_user_command("UrlEncode", function()
		url.encode_selection()
	end, { range = true, desc = "URL encode selection" })

	vim.api.nvim_create_user_command("UrlDecode", function()
		url.decode_selection()
	end, { range = true, desc = "URL decode selection" })

	vim.api.nvim_create_user_command("UuidGenerate", function()
		uuid.insert_uuid()
	end, { desc = "Insert UUID at cursor" })

	vim.api.nvim_create_user_command("RaysoGenerate", function()
		rayso.generate_from_selection()
	end, { range = true, desc = "Generate ray.so snippet from selection" })

	vim.api.nvim_create_user_command("RaysoWithOptions", function()
		rayso.generate_with_options()
	end, { range = true, desc = "Generate ray.so with custom options" })

	-- Setup telescope integration
	if config.telescope.enabled then
		local telescope_ok, _ = pcall(require, "telescope")
		if telescope_ok then
			vim.api.nvim_create_user_command("UtilsPicker", function()
				require("nvim-utils.telescope").show_utils()
			end, { desc = "Open utils picker" })

			if config.mappings.telescope_utils then
				vim.keymap.set({ "n", "v" }, config.mappings.telescope_utils, function()
					require("nvim-utils.telescope").show_utils()
				end, { desc = "Open utils picker" })
			end
		else
			vim.notify("Telescope not found, utils picker disabled", vim.log.levels.WARN)
		end
	end

	-- Setup keymaps
	if config.mappings.base64_encode then
		vim.keymap.set("v", config.mappings.base64_encode, base64.encode_selection, { desc = "Base64 encode selection" })
	end

	if config.mappings.base64_decode then
		vim.keymap.set("v", config.mappings.base64_decode, base64.decode_selection, { desc = "Base64 decode selection" })
	end

	if config.mappings.json_format then
		vim.keymap.set("v", config.mappings.json_format, json.format_selection, { desc = "Format JSON selection" })
	end

	if config.mappings.url_encode then
		vim.keymap.set("v", config.mappings.url_encode, url.encode_selection, { desc = "URL encode selection" })
	end

	if config.mappings.url_decode then
		vim.keymap.set("v", config.mappings.url_decode, url.decode_selection, { desc = "URL decode selection" })
	end

	if config.mappings.uuid_generate then
		vim.keymap.set("n", config.mappings.uuid_generate, uuid.insert_uuid, { desc = "Generate UUID" })
	end

	if config.mappings.rayso_generate then
		vim.keymap.set("v", config.mappings.rayso_generate, rayso.generate_from_selection, { desc = "Generate ray.so snippet" })
	end

	if config.mappings.rayso_options then
		vim.keymap.set("v", config.mappings.rayso_options, rayso.generate_with_options, { desc = "Generate ray.so with options" })
	end

	-- Setup which-key integration if available
	local which_key_ok, which_key = pcall(require, "which-key")
	if which_key_ok then
		which_key.add({
			{ "<leader>u", group = "Utils" },
			{ "<leader>ue", desc = "Base64 encode" },
			{ "<leader>ud", desc = "Base64 decode" },
			{ "<leader>uj", desc = "JSON format" },
			{ "<leader>uU", desc = "URL encode" },
			{ "<leader>uu", desc = "URL decode" },
			{ "<leader>ug", desc = "Generate UUID" },
			{ "<leader>ur", desc = "Ray.so snippet" },
			{ "<leader>uR", desc = "Ray.so with options" },
			{ "<leader>ut", desc = "Utils picker" },
		})
	end
end

M.base64 = base64
M.json = json
M.url = url
M.uuid = uuid
M.rayso = rayso

return M
