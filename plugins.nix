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
  plenary-nvim # dependency of telescope-nvim
  which-key-nvim
  nvim-surround

  gitsigns-nvim
  fidget-nvim

  popup-nvim

  # Looks
  lualine-nvim
  lualine-lsp-progress
  nvim-web-devicons
  vim-startify
  vim-jjdescription
  mini-base16

  solarized-nvim
  gruvbox-material
  tokyonight-nvim

  # Tools
  # telescope-sg # ast graph seach/regex Nonfree + I don't really use it
  harpoon2
  which-key-nvim
  nvim-lint

  # Text tools
  vim-easy-align

  # Other
  leap-nvim
  # pkgs.unstable.vimPlugins.neomutt-vim
  nvim-lspconfig

  # Nouns, Verbs, textobjects
  nvim-surround
  vim-repeat
  vim-textobj-user # TODO do we still need this?
  # vim-textobj-ident

  # Tree sitter
  nvim-treesitter.withAllGrammars
  nvim-treesitter-context
  nvim-treesitter-textobjects
])
