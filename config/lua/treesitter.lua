vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "nvim_treesitter#foldexpr()"

local select = {
	enable = true,
	keymaps = {
		-- You can use the capture groups defined in textobjects.scm
		["af"] = "@function.outer",
		["if"] = "@function.inner",
		["ac"] = "@class.outer",
		["ic"] = "@class.inner",
	},
}


vim.api.nvim_create_autocmd("BufRead", {
	once = true,
	callback = function() 
		require("nvim-treesitter.configs").setup {
			highlight = { enable = true },
			indent = { enable = false },
			textobjects = {
				select = select,
				-- swap = swap,
			},
		}

		require("treesitter-context").setup {
			enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
			max_lines = 10, -- How many lines the window should span. Values <= 0 mean no limit.
			-- Minimum editor window height to enable context. Values <= 0 mean no limit.
			min_window_height = 0,
			line_numbers = true,
			-- Maximum number of lines to collapse for a single context line
			multiline_threshold = 100,
			-- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
			trim_scope = 'outer',
			mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
			-- Separator between context and content. Should be a single 
			-- character string, like '-'. When separator is set, the context 
			-- will only show up when there are at least 2 lines above cursorline.
			separator = nil,
			zindex = 20,  -- The Z-index of the context window
			on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching

			patterns = {  -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
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
			},
		}
	end
})
