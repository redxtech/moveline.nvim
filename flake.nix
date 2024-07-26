{
  description = "Neovim plugin for moving lines up and down";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";
    naersk.url = "github:nix-community/naersk";
    naersk.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ flake-parts, nixpkgs, fenix, naersk, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem = { config, self', inputs', pkgs, system, lib, ... }: {
        # define the packages provided by this flake
        packages = let 
          rustPkg = let
            # use the minimal nightly toolchain provided by fenix
            toolchain = inputs'.fenix.packages.minimal.toolchain;
            nearskLib = inputs.naersk.lib.${system}.override {
              cargo = toolchain;
              rustc = toolchain;
            };
          in nearskLib.buildPackage {
            src = ./.;
						copyLibs = true;
          };
				in {
          moveline-nvim = pkgs.vimUtils.buildVimPlugin {
            pname = "moveline-nvim";
            version = "2024-07-25";

						src = rustPkg;

						preInstall = ''
							mkdir -p lua
							ln -s ${rustPkg}/target/release/libmoveline.so lua/moveline.so

							# include docs and license
							cp -s ${./README.md} README.md
							cp -s ${./LICENSE} LICENSE
						'';
          };

					default = self'.packages.moveline-nvim;
        };
      };
    };
}
