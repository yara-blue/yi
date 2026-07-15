vim.api.nvim_command(":packadd luasnip")

local ls = require("luasnip")
local types = require "luasnip.util.types"
-- require("luasnip/loaders/from_vscode").lazy_load({ override_priority = 800 }) -- default prio is 1000
local loaders = require("luasnip.loaders.from_lua")
loaders.lazy_load({ paths = "./comp/snippets" }) -- relative to config

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
