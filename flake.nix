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
    let
      def-olay = self: super: {
        kvmd = self.callPackage ./packages/kvmd.nix { src = kvmd-src; };
      };
      aarch64-pkgs = import nixpkgs
        {
          system = "aarch64-linux";
          overlays = [ def-olay ];
        };
    in
    {
      nixosConfigurations = {
        default = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          pkgs = aarch64-pkgs;
          modules = [
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            ./modules/kvmd.nix
            ({ pkgs, config, ... }: {
              users.users.nixos = {
                initialPassword = "nixos";
                isNormalUser = true;
                extraGroups = [ "wheel" ];
              };
              hardware.pikvm.v3-hdmi-rpi4.enable = true;
              services = {
                openssh.enable = true;
                kvmd.enable = true;
              };
            })
          ];
        };
      };
    } //
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs
            {
              inherit system;
              overlays = [ def-olay ];
            };
        in
        {
          overlay = def-olay;
          packages = rec {
            kvmd = pkgs.callPackage ./packages/kvmd.nix { src = kvmd-src; };
            sdcard-image =
              (nixpkgs.lib.nixosSystem {
                system = "aarch64-linux";
                pkgs = aarch64-pkgs;

                modules = [
                  "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
                  ./modules/kvmd.nix
                  ({ pkgs, config, ... }: {
                    users.users.nixos = {
                      initialPassword = "nixos"; # Pwease change ASAP OwO
                      isNormalUser = true;
                      extraGroups = [ "wheel" ];
                    };
                    hardware.pikvm.v3-hdmi-rpi4.enable = true;
                    services.openssh.enable = true;
                    services.kvmd.enable = true;
                  })
                ];
              }).config.system.build.sdImage;
          };
          apps = rec {
            hello = flake-utils.lib.mkApp {
              drv = self.packages.${system}.hello;
            };
            default = hello;
          };
        }
      );
}
