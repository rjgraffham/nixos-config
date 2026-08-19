{
  config,
  ...
}:

{

  services.k3s = {
    enable = true;

    nodeName = config.networking.hostName;

    # configure as a server+agent node (default at time of writing, but being explicit about it)
    role = "server";
    disableAgent = false;

    # let wheel use kubectl without sudo, since they could elevate to use it anyway
    extraFlags = [
      "--write-kubeconfig-mode 640"
      "--write-kubeconfig-group wheel"
    ];

    # attempt to stop pods cleanly on host shutdown, delaying host shutdown if needed
    gracefulNodeShutdown = {
      enable = true;
      shutdownGracePeriod = "1m";
      shutdownGracePeriodCriticalPods = "15s";
    };

    manifests."traefik-config".content = {
      apiVersion = "helm.cattle.io/v1";
      kind = "HelmChartConfig";
      metadata = {
        name = "traefik";
        namespace = "kube-system";
      };
      spec = {
        valuesContent = ''
          additionalArguments:
            - "--certificatesresolvers.default.acme.email=psquid@psquid.net"
            - "--certificatesresolvers.default.acme.storage=/data/acme.json"
            - "--certificatesresolvers.default.acme.httpchallenge.entrypoint=web"
          ports:
            web:
              exposedPort: 80
            websecure:
              exposedPort: 443
          providers:
            kubernetesGateway:
              enabled: true
        '';
      };
    };

  };

  # open firewall on web ports and forgejo ssh port
  networking.firewall.allowedTCPPorts = [ 80 443 30022 ];
  networking.firewall.allowedUDPPorts = [ 443 ];

}
