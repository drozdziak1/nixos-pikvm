{
  description = "NixOS modules and packages for pikvm v3";

  inputs = {
    flake-utils.url = github:numtide/flake-utils;
    nixpkgs.url = github:NixOS/nixpkgs/release-22.11;
    kvmd-src = {
      url = github:pikvm/kvmd;
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, kvmd-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = rec {
          hello = pkgs.hello;
          default = hello;
          kvmd = pkgs.callPackage ./packages/kvmd.nix { src = kvmd-src; };
        };
        apps = rec {
          hello = flake-utils.lib.mkApp { drv = self.packages.${system}.hello; };
          default = hello;
        };
      }
    );
}
