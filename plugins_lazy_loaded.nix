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

  telescope-nvim
  telescope-fzf-native-nvim
  telescope-ui-select-nvim

  crates-nvim
  comment-nvim

  # Completions
  luasnip
])
