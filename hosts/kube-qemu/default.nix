{ pkgs, ... }: 

let

  sources = import ../../sources.nix;

in

{

  imports = [
    # users
    ../../users/rj

    # networking configuration
    ./network.nix

    # nix configuration
    ../../nix
  ];

  # set hostname
  networking.hostName = "kube-qemu";

  # enable SSH
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # allow sudo without password for %wheel
  security.sudo.wheelNeedsPassword = false;

  # This is a config that uses 23.11 state where relevant
  system.stateVersion = "23.11";

  # configure as a grub-based EFI install
  boot.loader.generic-extlinux-compatible.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.efi.canTouchEfiVariables = false;

  # clean /tmp on boot
  boot.tmp.cleanOnBoot = true;

  # locate root by the default label applied to a vm boot disk
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
  };

  # configure zram swap with the default limit of 50% physical RAM
  zramSwap.enable = true;

  # configure some swap-related memory parameters to take advantage of the speed of zram
  # - stolen from https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram
  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };

}
