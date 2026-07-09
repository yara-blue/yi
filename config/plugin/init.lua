-- plugins are installed and managed by nixOs

require("settings")
require("maps")
require("commands")

-- -- these files mirrors those in the plugin file
-- -- and contain configurations
require("theme")
require("looks")
require("gui_tools")
require("text_tools")
require("treesitter")

vim.api.nvim_create_autocmd("InsertEnter", {
	callback = function()
		vim.api.nvim_command(":packadd! luasnip")
		vim.api.nvim_command(":packadd! cmp-nvim-lsp-signature-help")
		vim.api.nvim_command(":packadd! cmp-buffer")
		vim.api.nvim_command(":packadd! cmp-path")
		vim.api.nvim_command(":packadd! cmp-cmdline")
		vim.api.nvim_command(":packadd! cmp_luasnip")
		require("comp") -- completions and snippets
	end,
	once = true
})
require("lsp")
-- require("debuggers") -- debugger adapter
