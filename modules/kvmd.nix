# Main configuration options for kvmd. Note: The default overlay must be a part of your pkgs
{ config, lib, pkgs, ... }:
let cfg = config.services.kvmd;
in
with lib; {
  options = {
    services.kvmd = {
      enable = mkOption {
        type = types.bool;
        description = "Whether to enable kvmd, the main PiKVM daemon";
        default = false;
      };
      package = mkOption {
        type = types.package;
        description = "The kvmd package to use for the service";
        default = pkgs.kvmd;
      };
      user = mkOption {
        type = types.str;
        description = "Username to associate with kvmd processes";
        default = "kvmd";
      };
      group = mkOption {
        type = types.str;
        description = "Group to associate with kvmd processes";
        default = "kvmd";
      };
      extraGroups = mkOption {
        type = types.listOf types.str;
        description = "Additional groups that the kvmd user should be a part of";
        default = [ ];
        example = [ "jackaudio" "docker" ];
      };
    };
  };
  # 2023-03-20: Inspired by <kvmd>/configs/kvmd/os/services
  config.systemd.services = lib.mkIf cfg.enable {
    kvmd = {
      enable = true;
      description = "PiKVM - The main daemon";
      after = [ "network.target" "network-online.target" "nss-lookup.target" ];
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Type = "simple";
        Restart = "always";
        RestartSec = 3;
        AmbientCapabilities = [ "CAP_NET_RAW" ];
        ExecStart = "${cfg.package}/bin/kvmd --run";
        ExecStopPost = "${cfg.package}/bin/kvmd-cleanup --run";
        TimeoutStopSec = 10;
        KillMode = "mixed";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
