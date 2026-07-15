vim.api.nvim_command(":packadd! blink.cmp")

require('blink.cmp').setup({
	snippets = { preset = 'luasnip' },
	fuzzy = { implementation = "prefer_rust_with_warning" },
	cmdline = {
	  keymap = { preset = 'inherit' },
	  completion = { menu = { auto_show = true } },
	},
})

