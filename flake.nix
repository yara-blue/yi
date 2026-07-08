{
  description = "Neovim with my config and plugins as a nix flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      packages.x86_64-linux.default = (import ./package.nix) { pkgs = pkgs; };
	  apps.x86_64-linux.default = {
		  type = "app";
		  program = "${self.packages.x86_64-linux.default}/bin/yi";
	  };
    };
}
