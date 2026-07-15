
vim.api.nvim_create_autocmd({'BufEnter'}, {
	once = true,
	callback = function(opt)
		vim.api.nvim_command(":packadd comment.nvim")
		require("Comment").setup()
	end
} )

require("nvim-surround").setup()
