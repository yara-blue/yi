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

vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		vim.cmd.packadd("yanky.nvim")
		require('yanky').setup({
			ring = {
				history_length = 20,
				storage = "memory",
			},
			highlight = {
				timer = 200,
			},
			system_clipboard = {
			    sync_with_ring = true,
				clipboard_register = nil,
			},
		})

		vim.keymap.set({"n","x"}, "p", "<Plug>(YankyPutAfter)", { remap = true })
		vim.keymap.set({"n","x"}, "P", "<Plug>(YankyPutBefore)", { remap = true })

		vim.keymap.set("n", "<c-n>", "<Plug>(YankyPreviousEntry)", { remap = true })
		vim.keymap.set("n", "<c-e>", "<Plug>(YankyNextEntry)", { remap = true })
	end,
	once = true
})
