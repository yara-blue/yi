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
require("comp") -- completions and snippets

vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		require("lsp")
	end,
	once = true
})

require("startup")

-- require("lsp")
-- require("debuggers") -- debugger adapter
