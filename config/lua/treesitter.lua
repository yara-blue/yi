vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "nvim_treesitter#foldexpr()"

require("nvim-treesitter-textobjects").setup {
	select = {
		lookahead = true,
	}
}

vim.keymap.set({ "x", "o" }, "af", function()
require "nvim-treesitter-textobjects.select".select_textobject("@function.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "if", function()
require "nvim-treesitter-textobjects.select".select_textobject("@function.inner", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "ac", function()
require "nvim-treesitter-textobjects.select".select_textobject("@class.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "ic", function()
require "nvim-treesitter-textobjects.select".select_textobject("@class.inner", "textobjects")
end)

require("treesitter-context").setup{
	patterns = {  
		-- For all filetypes
		-- Note that setting an entry here replaces all other patterns for this entry.
		-- By setting the 'default' entry below, you can control which nodes you want to
		-- appear in the context window.
		default = {
			'class',
			'function',
			'method',
			'switch',
			'case',
			-- 'for', -- These won't appear in the context
			-- 'while',
			-- 'if',
		},
		rust = {
			'impl_item',
			'match'
		},
	}
}

vim.api.nvim_create_autocmd("BufRead", {
	once = true,
	callback = function() 
		vim.treesitter.start()
	end
})
