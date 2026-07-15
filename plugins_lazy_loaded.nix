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
  # telescope-nvim
  # telescope-fzf-native-nvim
  # telescope-ui-select-nvim

  comment-nvim

  # Completions
  luasnip
])
