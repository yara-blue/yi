vim.cmd.packadd("blink.cmp")
vim.cmd.packadd("blink-cmp-yanky")

require('blink.cmp').setup({
	snippets = { preset = 'luasnip' },
	fuzzy = { implementation = "prefer_rust_with_warning" },
	cmdline = {
	  keymap = { preset = 'inherit' },
	  completion = { 
		  menu = { auto_show = true } ,
	  },
	},

	completion = { 
		  menu = { auto_show = true } ,
		  documentation = {
			  auto_show = true,
		  },
	  },
	sources = {
		default = { "lsp", "path", "buffer", "snippets", "yank" },
		providers = {
			yank = {
				name = "yank",
				module = "blink-yanky",
			},
		},
	},
	keymap = {
		['<Right>'] = { 'select_and_accept', 'fallback' },
	},
})
