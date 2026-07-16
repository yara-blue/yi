
-- Lazy load openscad-nvim
-- BufRead since this plugin _adds_ the filetype
vim.api.nvim_create_autocmd("BufRead", {
	once = true,
	pattern = "*.scad",
	callback = function()
		vim.cmd.packadd("openscad.nvim")
		vim.g.openscad_load_snippets =true
		require("openscad")
	end
})

-- Lazy load typst-preview
vim.api.nvim_create_autocmd("FileType", {
	once = true,
	pattern = "*.typst",
	callback = function()
		vim.cmd.packadd("typst-preview.nvim")
		require("typst-preview").setup {
			debug = false,
			open_cmd = 'firefox %s -P typst-preview --class typst-preview',
			follow_cursor = true,
			dependencies_bin = {
				['tinymist'] = "tinymist",
				['websocat'] = "websocat",
			},

			-- This function will be called to determine the root of the typst project
			get_root = function(path_of_main_file)
				local root = os.getenv 'TYPST_ROOT'
				if root then
					return root
				end
				return vim.fn.fnamemodify(path_of_main_file, ':p:h')
			end,

			-- This function will be called to determine the main file of the typst
			-- project.
			get_main_file = function(path_of_buffer)
				return path_of_buffer
			end,
		}
	end,
})
