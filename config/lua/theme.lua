local looks = require("looks")

local theme = {}
theme.is_set = false

vim.cmd('highlight clear')
vim.o.background = 'dark'
vim.g.colors_name = 'one'

local hl = vim.api.nvim_set_hl


local function solarized()
	vim.g.solarized_italic_comments = true
	vim.g.solarized_italic_keywords = true
	vim.g.solarized_italic_functions = true
	vim.g.solarized_italic_variables = false
	vim.g.solarized_contrast = true
	vim.g.solarized_borders = false
	vim.g.solarized_disable_background = false
	require("solarized").set()
end

function theme:set_light()
	if vim.o.background ~= "light" or not self.is_set then
		self.is_set = true
		vim.o.background = "light"
		solarized()
		looks:lualine( "solarized")
	end
end

function theme:set_dark()
	if vim.o.background ~= "dark" or not self.is_set then
		self.is_set = true
		vim.o.background = "dark"
		vim.g.tokyonight_style = "storm"
		vim.cmd("colorscheme tokyonight")
		looks:lualine( "tokyonight")
	end
end

function theme:set()
	local f = io.open("/tmp/darkmode", "r")
	if f ~= nil then
		self:set_dark()
		return
	end

	local hour = os.date("*t").hour
	if hour >= 5 and hour < 21 then
		self:set_light()
	else
		self:set_dark()
	end
end

local nix_colors_path = vim.fn.stdpath("config") .. "/colors.json"
-- local nix_provides_colors = vim.fn.filereadable(nix_colors_path) == 1
local nix_provides_colors = false; -- for now disabled

if nix_provides_colors then 
	local content = table.concat(vim.fn.readfile(nix_colors_path), "\n")
	local colors = vim.json.decode(content)
	require('mini.base16').setup({
		palette = { -- colors provides base24, we need base16 so cut a few off
		  base00 = colors.base00,
		  base01 = colors.base01,
		  base02 = colors.base02,
		  base03 = colors.base03,
		  base04 = colors.base04,
		  base05 = colors.base05,
		  base06 = colors.base06,
		  base07 = colors.base07,
		  base08 = colors.base08,
		  base09 = colors.base09,
		  base0A = colors.base0A,
		  base0B = colors.base0B,
		  base0C = colors.base0C,
		  base0D = colors.base0D,
		  base0E = colors.base0E,
		  base0F = colors.base0F,
		},
		use_cterm = true,
		plugins = {
			default = true,
		}
	})
	looks:lualine()
else 
	theme:set()
end

-- vim.o.background="dark"
-- vim.g.gruvbox_material_background = "hard"
-- vim.g.gruvbox_material_enable_bold = true
-- vim.cmd("colorscheme gruvbox-material")
-- looks:lualine("gruvbox")
