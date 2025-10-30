if vim.g.loaded_nvim_utils then
	return
end
vim.g.loaded_nvim_utils = 1

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if not vim.g.nvim_utils_configured then
			require("nvim-utils").setup()
			vim.g.nvim_utils_configured = true
		end
	end,
	once = true,
})
