{
  pkgs,
  ...
}:
let
  custom_nvim_name = "yi";
  packageName = "plugins-from-nixpkgs";
  plugins = import ./plugins.nix { pkgs = pkgs; };
  plugins_lazy_loaded = import ./plugins_lazy_loaded.nix { pkgs = pkgs; };
  packpath = pkgs.runCommandLocal "packpath" { } ''
    mkdir -p $out/pack/${packageName}/{start,opt}

    # neovim config as a plugin
    ln -vsfT ${./config} $out/pack/${packageName}/start/config

    ${pkgs.lib.strings.concatLines [
      # plugins neovim should load on startup
      (pkgs.lib.concatMapStringsSep "\n" (
        plugin: "ln -vsfT ${plugin} $out/pack/${packageName}/start/${pkgs.lib.getName plugin}"
      ) plugins)

      # plugins lazy loaded (explicit :packadd)
      (pkgs.lib.concatMapStringsSep "\n" (
        plugin: "ln -vsfT ${plugin} $out/pack/${packageName}/opt/${pkgs.lib.getName plugin}"
      ) plugins_lazy_loaded)
    ]}
  '';
in
pkgs.symlinkJoin {
  name = custom_nvim_name;
  paths = [ pkgs.neovim-unwrapped ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
            # 1. Pass the config init.lua from the store to neovim using -u
    		# 2. Run a vim command on startup to set the package path to load our
    		#    plugins
    		# 3. Change the `NVIM_APPNAME` to further isolate this neovim from any
    		#    existing install
          	wrapProgram $out/bin/nvim \
        		--add-flags '-u' \
        		--add-flags NORC \
    			--add-flags '--cmd' \
    			--add-flags "'set packpath^=${packpath} | set runtimepath^=${packpath}'" \
    			--set-default NVIM_APPNAME ${custom_nvim_name}
        	mv $out/bin/{nvim,${custom_nvim_name}}
  '';

  passthru = {
    inherit packpath;
  };
}
