vim.api.nvim_create_user_command(
	"LuaSnipEdit",
	function() require("luasnip.loaders.from_lua").edit_snippet_files() end,
	{ desc = "edit lua file" }
)

vim.api.nvim_create_user_command(
	"Unmap",
	function() require("functions").undo_custom_remaps() end,
	{ desc = "undo custom remappings" }
)

vim.api.nvim_create_user_command(
	"Remap",
	function() require("functions").apply_custom_remaps() end,
	{ desc = "redo custom remappings" }
)

vim.api.nvim_create_user_command(
	"LspCodeAction",
	function() require("functions").lsp_code_action_by_prefix() end,
	{
		nargs = 1,
		desc = "perform the lsp code action that matches the provided prefix",
		complete = function(_, _, _)
			return func.lst_list_code_actions()
		end,

	}
)

vim.api.nvim_create_user_command(
	"RustcDev",
	function() require("lsp").setup_rustc_dev() end,
	{ desc = "configure the rust-analyzer lsp for rustc development" }
)

-- see `:h lua-guide-commands-create`
vim.api.nvim_create_user_command(
	"RustFeature",
	function(opts) require("lsp").add_flag_to_rust_analyzer(opts.fargs) end,
	{ 
		nargs = 1,
		complete = function() require("lsp").list_crate_features() end,
		desc = "adds a feature flag to rust-analyzer's config and restarts it" 
	}
)
