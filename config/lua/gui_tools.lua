require("nvim-tree").setup({})

require("lsp_lines").setup()

local actions = require("telescope.actions")
require("telescope").setup({
	extensions = {
		ast_grep = {
            command = {
                "ast-grep", 
                "--json=stream",
            }, -- must have --json=stream
            grep_open_files = false, -- search in opened files
            lang = nil, -- specify language for ast-grep `nil` for default
		}
	},
	defaults = {
		vimgrep_arguments = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
		},
		mappings = {
			i = {
				["<C-h>"] = "which_key",
				-- if items selected (tab) send only those to qflist
				["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
			},
		},
		prompt_prefix = "> ",
		selection_caret = "> ",
		entry_prefix = "  ",
		initial_mode = "insert",
		selection_strategy = "reset",
		sorting_strategy = "descending",
		layout_strategy = "horizontal",
		layout_config = {
			horizontal = {
				mirror = false,
			},
			vertical = {
				mirror = false,
			},
		},
		file_sorter = require("telescope.sorters").get_fuzzy_file,
		-- Cannot be in .gitignore but clutter up telescopes
		file_ignore_patterns = {
			"%.lock",
			"%.jpg",
			"%.pdf",
			"%.webp",
		},
		generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
		winblend = 0,
		border = {},
		borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
		color_devicons = true,
		use_less = true,
		path_display = {},
		set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
		file_previewer = require("telescope.previewers").vim_buffer_cat.new,
		grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
		qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,

		-- Developer configurations: Not meant for general override
		buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
	},
})
require('telescope').load_extension('fzf')
require("telescope").load_extension("ui-select")

require("which-key").setup({
	plugins = {
		registers = true,
		spelling = {
			enabled = true,
			suggestions = 20,
		},
	},
})

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
