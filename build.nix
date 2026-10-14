{
  hostname ? abort "Hostname must be provided.",
  ...
}:

let

  hosts = import ./hosts;

  host = hosts.${hostname} or (abort "Host ${hostname} not defined in ${./hosts}.");

  pkgs = import host.nixpkgs {
    inherit (host) system;
    overlays = map import (host.overlays or []);
  };

in pkgs.nixos [
  host.config
  { config._module.args.sources = import ./sources.nix; }
]

