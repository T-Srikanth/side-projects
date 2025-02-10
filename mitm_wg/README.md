# Docker container running mitmproxy in WireGuard mode

Objective: Route the app container's traffic through a WireGuard VPN tunnel to a mitmproxy server running in WireGuard mode before reaching the internet.

## Requirement

The setup required routing network traffic from an app container through a WireGuard tunnel to a mitmproxy server before connecting to the internet. So the approach was to spin up three containers using docker compose:

- **mitmproxy container (wg-mitm)**: [Image used - [mitmproxy](https://hub.docker.com/r/mitmproxy/mitmproxy/)] We'll be using the mitmdump tool. When started with `mitmdump --mode wireguard`, it creates a WireGuard server that listens on port `51820/udp` by default. The server provides a client configuration that can be used to establish a tunnel connection.
  <img src="/Assets/mitm_wg_ss/1.png">
- **Wireguard client container (wg-client)**: [Image used - [wireguard](https://hub.docker.com/r/linuxserver/wireguard)] Using the client configuration from the server, this container functions as a WireGuard client to establish a VPN tunnel.
- **Application container (curl-app)**: [Image used - [curl](https://hub.docker.com/r/curlimages/curl)] This is a simple container from which we can perform curl operations. The `[network_mode](https://docs.docker.com/reference/compose-file/services/#network_mode): "service:[service name]"` field specifies it to use the wg-client container’s network. Hence all the traffic flows through the VPN tunnel.
  <img src="/Assets/mitm_wg_ss/2.png">
You can see the traffic being intercepted in the `wg-mitm` container.
<img src="/Assets/mitm_wg_ss/3.png">

## Issue & Solution

`wg-client` container expects a config file.

As mentioned earlier, when the wireguard server is started in the `wg-mitm` container, we get to see client configuration details on the terminal. We need to pass those details to the `wg-client` container. For which I’d to the following:

- Store the config details in `/config/wg0.conf` on the `wg-mitm` container.
- Mount a common host directory on both the containers(`wg-mitm`, `wg-client`).
- Now the client container can use the `wg0.conf` to establish a tunnel.

## Steps to implement
- Copy `docker-compose.yml` and `start.sh` files on to a docker host.
- Make `start.sh` executable.
- Run `docker-compose up -d`

With just a single command `docker-compose up -d`you will have all the containers running. And, that’s it the setup is ready.

*Note*: Running this on a WSL2 docker host might fail due to a known [bug](https://github.com/linuxserver/docker-wireguard/issues/252)