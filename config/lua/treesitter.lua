-- setting this triggers a bunch of treesitter things that 
-- are _very_ slow. It adds 20ms to startup.
vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        vim.defer_fn(function()
            vim.opt.foldmethod = "expr"
            vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
        end, 100)
    end,
})

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
