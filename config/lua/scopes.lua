-- these names are dirs in <nix store path>/packpath/pack/plugins-from-nixpkgs/opt
-- (find the path to packpath by inspecting the shell wrapper)
vim.api.nvim_command(":packadd! telescope.nvim")
vim.api.nvim_command(":packadd! telescope-fzf-native.nvim")
vim.api.nvim_command(":packadd! telescope-ui-select.nvim")

local actions = require("telescope.actions")
require("telescope").setup({
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
		-- Cannot be in .gitignore but clutter up telescopes
		file_ignore_patterns = {
			"%.lock",
			"%.jpg",
			"%.pdf",
			"%.webp",
		},
		winblend = 0,
		border = {},
		borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
		color_devicons = true,
		path_display = {"smart"},
		set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
		file_previewer = require("telescope.previewers").vim_buffer_cat.new,
		grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
		qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,

		-- Developer configurations: Not meant for general override
		buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,

	  extensions = {
		fzf = {
		  fuzzy = true,                    -- false will only do exact matching
		  override_generic_sorter = true,  -- override the generic sorter
		  override_file_sorter = true,     -- override the file sorter
		  case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
										   -- the default case_mode is "smart_case"
		}
	  }
	},
})

require("telescope").load_extension("ui-select")
require("telescope").load_extension("fzf")

return require("telescope.builtin")
