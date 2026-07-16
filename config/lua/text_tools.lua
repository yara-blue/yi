
vim.api.nvim_create_autocmd({'BufEnter'}, {
	once = true,
	callback = vim.schedule_wrap(function(opt)
		vim.cmd.packadd("comment.nvim")
		vim.cmd.packadd("nvim-surround")
		vim.cmd.packadd("vim-repeat")
		vim.cmd.packadd("vim-easy-align")
		require("nvim-surround").setup()
		require("Comment").setup()
	end)
} )

vim.api.nvim_create_autocmd({'BufEnter'}, {
	once = true,
	pattern = "*.jjdescription",
	callback = vim.schedule_wrap(function(opt)
		vim.cmd.packadd("vim-jjdescription")
	end)
} )

-- recommended: define a preview filter to reduce visual noise
-- and the blinking effect after the first keypress.
-- For example, define word boundaries as the common case, that is, skip
-- preview for matches starting with whitespace or an alphabetic
-- mid-word character: foobar[baaz] = quux
--                     ^    ^^^  ^^ ^ ^  ^
require('leap').opts.preview = function(ch0, ch1, ch2)
  return not (
    ch1:match('%s')
    or (ch0:match('%a') and ch1:match('%a') and ch2:match('%a'))
  )
end

-- Enable the traversal keys to repeat the previous search without
-- explicitly invoking Leap (`<cr><cr>...` instead of `s<cr><cr>...`):
do
  local clever = require('leap.user').with_traversal_keys
  vim.keymap.set({ 'n', 'x', 'o' }, '<cr>', function()
    require('leap').leap {
      ['repeat'] = true, opts = clever('<cr>', '<bs>'),
    }
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, '<bs>', function()
    require('leap').leap {
      ['repeat'] = true, opts = clever('<bs>', '<cr>'), backward = true,
    }
  end)
end
