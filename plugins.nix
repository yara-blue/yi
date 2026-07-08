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

  # Themes
  tokyonight-nvim
  solarized-nvim
  gruvbox-material

  # Looks
  # vim-highlightedyank TODO replace with: 
  # https://stackoverflow.com/questions/26069278/highlight-copied-area-in-vim
  gitsigns-nvim
  lualine-nvim
  lualine-lsp-progress
  nvim-web-devicons
  vim-startify
  vim-jjdescription
  mini-base16

  # Tools
  nvim-tree-lua
  telescope-nvim
  telescope-fzf-native-nvim
  telescope-ui-select-nvim
  # telescope-sg # ast graph seach/regex Nonfree + I don't really use it
  harpoon2
  which-key-nvim
  lsp_lines-nvim
  fidget-nvim
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
  comment-nvim
  nvim-surround
  vim-repeat
  vim-textobj-user # TODO do we still need this?
  # vim-textobj-ident

  # Tree sitter
  nvim-treesitter.withAllGrammars
  nvim-treesitter-context
  nvim-treesitter-textobjects

  # Completions
  luasnip
  nvim-cmp
  cmp-nvim-lsp
  cmp-nvim-lsp-signature-help
  cmp-buffer
  cmp-path
  cmp-cmdline
  cmp_luasnip
])
