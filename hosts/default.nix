let

  sources = import ../sources.nix;

in

{

  rpi4 = rec {
    system = "aarch64-linux";
    config = ./rpi4/default.nix;
    nixpkgs = sources.nixpkgs;
    overlays = [
    ];
  };

  kube-qemu = rec {
    system = "x86_64-linux";
    config = ./kube-qemu/default.nix;
    nixpkgs = sources.nixpkgs;
    overlays = [
    ];
  };

}
