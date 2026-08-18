vim.api.nvim_create_autocmd("InsertEnter", {
	callback = function()
		require("comp.completion_engine")
		require("comp.snippets")
	end,
	once = true
})

vim.api.nvim_create_autocmd("BufEnter", {
	pattern = { 'Cargo.toml' },
	callback = function()
		vim.cmd.packadd("crates.nvim")
		require('crates').setup({
			lsp = {
				enabled = true,
				on_attach = function(client, bufnr)
					-- the same on_attach function as for your other language servers
					-- can be ommited if you're using the `LspAttach` autocmd
				end,
				actions = true,
				completion = true,
				hover = true,
			},
			popup = {
				show_dependency_version = false,
			},
		})
	end,
	once = true
})
