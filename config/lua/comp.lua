local ls = require("luasnip") 
local types = require "luasnip.util.types"
-- require("luasnip/loaders/from_vscode").lazy_load({ override_priority = 800 }) -- default prio is 1000
local loaders = require("luasnip.loaders.from_lua")
loaders.lazy_load({ paths = "~/.config/nvim/lua/snippets" })

require('blink.cmp').setup({
	snippets = { preset = 'luasnip' },
	fuzzy = { implementation = "prefer_rust_with_warning" },
	cmdline = {
	  keymap = { preset = 'inherit' },
	  completion = { menu = { auto_show = true } },
	},
})

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
	}
})

-- Every unspecified option will be set to the default.
ls.config.setup({
	history = true,
	enable_autosnippets = true,
	-- Update more often, :h events for more info.
	updateevents = "TextChanged,TextChangedI",
	ext_opts = {
		[types.choiceNode] = {
			active = {
				virt_text = { { "choiceNode", "Comment" } },
			},
		},
	},
	-- treesitter-hl has 100, use something higher (default is 200).
	ext_base_prio = 300,
	-- minimal increase in priority.
	ext_prio_increase = 1,
})
