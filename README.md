To lazy load a plugin:
- add the nix package to the list in `plugins_lazy_loaded.nix` 
- `nix run .`
- in neovim do `:echo &packpath`
- take the first entry and ls that dir
- go down into `/pack/plugins-from-neovim/opt`
  (full path looks like: 
  `/nix/store/fn05dlfzsb0vq94lai8fa2z0wa1m4dr6-packpath/pack/plugins-from-nixpkgs/opt`)
- find how the plugin is named there (like `gitportal.nvim`)
- lazy load it somewhere:
```lua
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = vim.schedule_wrap(function() -- run immediately after startup
  -- callback = vim.defer_fn(function () etc etc , timeout) -- run after some time
	vim.cmd.packadd("gitportal.nvim") -- name in the opt dir found above
	require("gitportal.nvim").setup() { -- from the setup of the plugin
		always_include_current_line = true,
	}
  end),
})
```
