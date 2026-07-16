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
  blink-cmp
  blink-cmp-yanky

  plenary-nvim # dependency of telescope-nvim
  telescope-nvim
  telescope-fzf-native-nvim
  telescope-ui-select-nvim

  gitsigns-nvim
  fidget-nvim

  crates-nvim
  comment-nvim
  yanky-nvim

  typst-preview-nvim
  openscad-nvim

  # Nouns, Verbs, textobjects
  nvim-surround
  vim-repeat
  vim-jjdescription
  vim-easy-align

  # Completions
  luasnip
])
