vim.lsp.config("vale-ls", {
	  cmd = { 'vale-ls' },
	  filetypes = { 'asciidoc', 'markdown', 'text', 'tex', 'rst', 'html', 'xml' },
	  -- root_markers = { '.vale.ini' },
  }
)
-- vim.lsp.enable("vale-ls")
vim.lsp.enable("codebook")

vim.lsp.enable("tinymist")
vim.lsp.enable("lua_ls")
vim.lsp.enable("nixd")
vim.lsp.config("typos-lsp", {
	cmd = { "typos-lsp" },
    init_options = {
  --       -- Custom config. Used together with a config file found in
		-- -- the workspace or its parents,
  --       -- taking precedence for settings declared in both.
  --       -- Equivalent to the typos `--config` cli argument.
  --       config = '~/code/typos-lsp/crates/typos-lsp/tests/typos.toml',
		-- How typos are rendered in the editor, can be one of an Error,
		-- Warning, Info or Hint.
		-- Defaults to Info.
        diagnosticSeverity = "Hint"
    }
})
vim.lsp.enable("typos-lsp")


M = {}

local function we_are_rustc()
	return vim.fs.root(0, "x.py") ~= nil 
end

local function we_are_rust()
	return vim.fs.root(0, "Cargo.toml") ~= nil 
end

local function rustc_settings()
	return {
		linkedProjects = {
		  "Cargo.toml",
		  "compiler/rustc_codegen_cranelift/Cargo.toml",
		  "compiler/rustc_codegen_gcc/Cargo.toml",
		  "library/Cargo.toml",
		  "src/bootstrap/Cargo.toml",
		  "src/tools/rust-analyzer/Cargo.toml"
		 },
		check = {
			invocationLocation = "root",
			invocationStrategy = "once",
			overrideCommand = {
				"x",
				"check",
				"compiler",
				"--build-dir",
				"build-rust-analyzer",
				"--json-output"
			},
		},
		rustfmt = {
			overrideCommand = {
				"build/host/rustfmt/bin/rustfmt",
				"--edition=2024"
			},
		},
		procMacro = {
			server = "build/host/stage0/libexec/rust-analyzer-proc-macro-srv",
			enable = true,
		},
		rustc = {
			source = "./Cargo.toml",
		},
		cargo = {
			sysrootSrc = "./library",
			extraEnv = {
				RUSTC_BOOTSTRAP = "1",
			},
			buildScripts = {
				enable = true,
				invocationStrategy = "once",
				overrideCommand = {
					"x",
					"check",
					"compiler",
					"--compile-time-deps",
					"--build-dir",
					"build-rust-analyzer",
					"--json-output"
				}
			},
		},
		server = {
			extraEnv = {
				RUSTC_TOOLCHAIN = "nightly",
			}
		}
	}
end

local function config_and_enable()
	local existing_on_attach = (vim.lsp.config['rust-analyzer'] or {}).on_attach
	vim.lsp.config('rust-analyzer', {
		cmd = { "rust-analyzer" },
		root_dir = function(bufnr, on_dir)
			if we_are_rustc() then
				on_dir(vim.fs.root(bufnr, {"x.py"}))
			elseif we_are_rust() then
				on_dir(vim.fs.root(bufnr, {"Cargo.toml"}))
			end
		end,
		before_init = function(_, config)
			if we_are_rustc() then 
				config.settings["rust-analyzer"] = rustc_settings()
			end
		end,
		settings = { 
			["rust-analyzer"] = {
				imports = {
					granularity = {
						group = "module",
					},
				},
				cargo = {
					buildScripts = {
						enable = true,
					},
				},
				procMacro = {
					enable = true,
				}
			}
		}
	})
	vim.lsp.enable({'rust-analyzer'})
end

config_and_enable()

function M.add_flag_to_rust_analyzer(features)
	vim.lsp.config('rust-analyzer', {
		cmd = { "rust-analyzer" },
		root_markers = { 'Cargo.toml' },
		filetypes = { 'rust' },
		-- capabilities = capabilities,
		settings = {
			["rust-analyzer"] = {
				imports = {
					granularity = {
						group = "module",
					},
				},
				cargo = {
					buildScripts = {
						enable = true,
					},
					features = features,
				},
				procMacro = {
					enable = true,
				},
			},
		},
		-- highlights (including dead code greyout) survive lsp restart. So we refresh
		-- on_attach = function(_, bufnr)
		-- 	vim.schedule(function()
		-- 		pcall(vim.lsp.semantic_tokens.force_refresh, bufnr)
		-- 	end)
		-- end,
	})


	-- lsp stop (via disable) does not remove the diagnostics
	local ra = find_rust_analyzer()
	ra:stop()

	-- lsp restart does not update the config
	vim.lsp.enable('rust-analyzer', false)

	vim.defer_fn(function() 
		ra:stop() -- second stop kills it in case it hasn't died yet
		vim.lsp.enable('rust-analyzer', true)
	end, 2000)
end

function find_rust_analyzer() 
	local clients = vim.lsp.get_clients()
	for _, client in ipairs(clients) do
		if client.name == 'rust-analyzer' then
			return client
		end
	end
	return nil
end

function M.list_crate_features()
	local shell_cmd = [[cat Cargo.toml | rg "name\s*=\s*\"(.+?)\"" -r '$1' | head -n 1]]
	local crate = vim.system({"sh", "-c", shell_cmd}):wait()
	local crate = crate.stdout:sub(1, -2)

	local shell_cmd = "cargo info "..crate.." --offline -v"
	local out = vim.system({"sh", "-c", shell_cmd}):wait()
	local out = vim.split(out.stdout, "features:\n", { plain=true })
	local out = vim.split(out[2], "\ndependencies:", {plain = true})
	local out = vim.split(out[1], "\n")

	local features = {}
	for i, feature in ipairs(out) do
		if not vim.startswith(feature, " +") then
			features[#features+1] = string.match(out[i], '[^ ]+', 2)
		end
	end

	return features
end

return M
