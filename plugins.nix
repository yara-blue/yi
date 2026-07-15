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
  vim-startuptime

  plenary-nvim # dependency of telescope-nvim
  which-key-nvim
  nvim-surround

  gitsigns-nvim
  fidget-nvim

  popup-nvim

  # Looks
  # vim-highlightedyank TODO replace with:
  # https://stackoverflow.com/questions/26069278/highlight-copied-area-in-vim
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
  crates-nvim

  # Text tools
  vim-easy-align

  # Other
  leap-nvim
  # pkgs.unstable.vimPlugins.neomutt-vim
  nvim-lspconfig
  typst-preview-nvim

  # Nouns, Verbs, textobjects
  nvim-surround
  vim-repeat
  vim-textobj-user # TODO do we still need this?
  # vim-textobj-ident

  # Tree sitter
  nvim-treesitter.withAllGrammars
  nvim-treesitter-context
  nvim-treesitter-textobjects

  blink-cmp


  telescope-nvim
  telescope-fzf-native-nvim
  telescope-ui-select-nvim
])
