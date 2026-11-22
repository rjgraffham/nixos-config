{
  config,
  pkgs,
  ...
}:

let

  hostIp = "10.0.2.2";   # qemu's address on the virtual network
  kubeIp = "10.0.2.15";  # address outside of qemu's DHCP range

in

{

  # configure static IP and gateway
  networking = {

    interfaces.eth0.ipv4.addresses = [
      {
        address = kubeIp;
        prefixLength = 24;
      }
    ];

    defaultGateway = hostIp;

  };

  # add kubernetes tools to system environment
  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm
  ];

  # symlink admin kubeconfig for root user (technically would be readable by
  # any user, but still requires root to read key file, so we stick to root)
  systemd.tmpfiles.rules = [
    "d /root/.kube        0700 root root -"
    "L /root/.kube/config -    -    -    - /etc/kubernetes/cluster-admin.kubeconfig"
  ];

  # configure kubernetes itself
  services.kubernetes = {

    roles = ["master" "node"];  # this is a single-node cluster so this machine must be both
    masterAddress = config.networking.hostName;  # hostname, as easyCerts can't generate IP certs
    kubelet.extraOpts = "--fail-swap-on=false";
    easyCerts = true;
    apiserver = {
      securePort = 443;
      advertiseAddress = kubeIp;
    };

  };

}
