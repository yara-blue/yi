{ pkgs }:
let
  # Add all the dependencies of a plugin to the list
  foldPlugins = builtins.foldl' (
    acc: next:
    acc
    ++ [
      next
    ]
    ++ (foldPlugins (next.dependencies or [ ]))
  ) [ ];
in
with pkgs.vimPlugins;
pkgs.lib.unique (foldPlugins [
  popup-nvim

  # Looks
  lualine-nvim
  lualine-lsp-progress
  nvim-web-devicons
  mini-base16

  solarized-nvim
  gruvbox-material
  tokyonight-nvim

  # Tools
  # telescope-sg # ast graph seach/regex Nonfree + I don't really use it
  harpoon2
  nvim-lint
  which-key-nvim

  # Text tools

  # Other
  leap-nvim # lazy loads itself
  # pkgs.unstable.vimPlugins.neomutt-vim
  nvim-lspconfig

  # Tree sitter
  nvim-treesitter.withAllGrammars
  nvim-treesitter-context
  nvim-treesitter-textobjects
])
