local M = {}

local default_config = {
	title = "",
	theme = "vercel",
	background = true,
	dark_mode = true,
	padding = 32,
	language = "auto",
}

local function get_language_from_filetype(filetype)
	local lang_map = {
		javascript = "javascript",
		typescript = "typescript",
		lua = "lua",
		python = "python",
		go = "go",
		rust = "rust",
		java = "java",
		cpp = "cpp",
		c = "c",
		html = "html",
		css = "css",
		json = "json",
		yaml = "yaml",
		bash = "bash",
		sh = "bash",
		zsh = "bash",
		vim = "vim",
	}

	return lang_map[filetype] or "auto"
end

local function url_encode(str)
	return string.gsub(str, "([^%w%-%.%_~])", function(c)
		return string.format("%%%02X", string.byte(c))
	end)
end

function M.generate_url(code, opts)
	opts = opts or {}
	local config = vim.tbl_deep_extend("force", default_config, opts)

	if config.language == "auto" then
		config.language = get_language_from_filetype(vim.bo.filetype)
	end

	local base_url = "https://ray.so/"
	local params = {
		"code=" .. url_encode(code),
		"language=" .. url_encode(config.language),
		"title=" .. url_encode(config.title),
		"theme=" .. url_encode(config.theme),
		"background=" .. tostring(config.background),
		"darkMode=" .. tostring(config.dark_mode),
		"padding=" .. tostring(config.padding),
	}

	return base_url .. "#" .. table.concat(params, "&")
end

function M.generate_from_selection(opts)
	opts = opts or {}

	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	local start_line = start_pos[2]
	local end_line = end_pos[2]
	local start_col = start_pos[3]
	local end_col = end_pos[3]

	if start_line == 0 or end_line == 0 then
		vim.notify("No code selected! Please select some code first.", vim.log.levels.WARN)
		return
	end

	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

	if #lines == 0 then
		vim.notify("No code selected!", vim.log.levels.WARN)
		return
	end

	if #lines == 1 then
		local line = lines[1]
		lines[1] = string.sub(line, start_col, end_col)
	else
		lines[1] = string.sub(lines[1], start_col)
		lines[#lines] = string.sub(lines[#lines], 1, end_col)
	end

	local code = table.concat(lines, "\n")

	code = code:gsub("^%s+", ""):gsub("%s+$", "")

	if code == "" then
		vim.notify("Selected code is empty!", vim.log.levels.WARN)
		return
	end

	local url = M.generate_url(code, opts)

	vim.fn.setreg("+", url)
	vim.fn.setreg('"', url)

	local choice = vim.fn.confirm(
		"Ray.so URL generated and copied to clipboard!\n\n" .. url,
		"&Open in browser\n&Just copied\n&Show URL",
		2
	)

	if choice == 1 then
		local open_cmd
		if vim.fn.has("mac") == 1 then
			open_cmd = "open"
		elseif vim.fn.has("unix") == 1 then
			open_cmd = "xdg-open"
		elseif vim.fn.has("win32") == 1 then
			open_cmd = "start"
		end

		if open_cmd then
			vim.fn.system(open_cmd .. ' "' .. url .. '"')
		else
			vim.notify("Cannot detect system to open browser", vim.log.levels.ERROR)
		end
	elseif choice == 3 then
		M.show_url_popup(url)
	end
end

function M.show_url_popup(url)
	local width = math.min(#url + 4, vim.o.columns - 4)
	local height = math.ceil(#url / width) + 2

	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, false, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
		title = " Ray.so URL ",
		title_pos = "center",
	})

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { url })
	vim.api.nvim_buf_set_option(buf, "modifiable", false)

	vim.keymap.set("n", "<Esc>", function()
		vim.api.nvim_win_close(win, true)
	end, { buffer = buf })

	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(win, true)
	end, { buffer = buf })
end

function M.generate_with_options()
	vim.ui.input({ prompt = "Title (optional): " }, function(title)
		if title == nil then
			return
		end

		local themes = { "vercel", "supabase", "tailwind", "bitmap", "noir", "ice", "sand", "forest" }
		vim.ui.select(themes, { prompt = "Select theme:" }, function(theme)
			if theme == nil then
				return
			end

			local opts = {
				title = title or "",
				theme = theme,
			}

			M.generate_from_selection(opts)
		end)
	end)
end

return M
