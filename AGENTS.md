# AGENTS.md

## Cookbook Purpose

This cookbook manages OpenVPN Community Edition through custom resources for package
installation, server configuration, service management, and client certificate bundles.

## Agent Findings

* Owner confirmed Full Migration for PR #260 on 2026-11-12. Complete this existing PR;
  do not close the competing incremental PR #253 or merge either PR without authorisation.
* `openvpn_client` replaces the old client recipe: install the package, write an explicit
  client configuration and enable/start its service. Client certificates remain caller-managed.
* Named RHEL/Fedora instances use `/etc/openvpn/server/<name>.conf` and
  `/etc/openvpn/client/<name>.conf`, matching the package systemd templates.
* Removed the unused `kitchen.exec.yml` macOS/Windows scaffold: neither the original
  main metadata nor this migration declares macOS or Windows support, README lists Linux
  only, and CI exclusively uses Dokken Linux images. No supported target was removed.
* This is a full migration from recipes and node attributes to resources. Do not reintroduce
  `recipes/` or `attributes/`; use resource properties in test cookbooks and wrapper cookbooks.
* The cookbook intentionally uses distribution packages rather than the legacy
  `build.openvpn.net` APT repository. This keeps convergence deterministic in CI and avoids a
  bespoke external repository for the default path.
* RHEL-family installs use the `epel-release` package before `openvpn` because OpenVPN is shipped
  by EPEL for EL 8 and EL 9.
* OpenVPN service naming differs by platform family. Debian/Ubuntu use `openvpn@server.service`
  with `/etc/openvpn/server.conf`; RHEL 8+, Fedora, and Amazon Linux 2023 use
  `openvpn-server@server.service` with `/etc/openvpn/server/server.conf`.
* The old easy-rsa v2-style templates are retained for compatibility with the previous cookbook
  certificate workflow. Replacing that with modern EasyRSA 3 should be a separate breaking change.

## Package Availability

### APT (Debian/Ubuntu)

* Debian 12 and Debian 13 provide `openvpn` and recommend `easy-rsa` in the distribution
  repositories for multiple architectures.
* Ubuntu 22.04 and Ubuntu 24.04 provide `openvpn` in the distribution repositories.

### DNF/YUM (RHEL family)

* Fedora provides `openvpn` directly.
* EPEL provides OpenVPN for EL 8, EL 9, and EL 10 derivatives.
* Amazon Linux 2023 is kept in the matrix because the current Dokken image can install OpenVPN
  without the old external APT repository path.

## Architecture Limitations

* The cookbook does not pin architecture-specific packages. Platform package managers select the
  appropriate package for the node architecture.

## Source/Compiled Installation

Source installation is intentionally not implemented. The cookbook only supports package-based
installation.

## Known Issues

* OpenVPN inside containers requires privileged Dokken and systemd. Service convergence can fail
  if the host Docker runtime does not allow tun/network capability operations.
* This cookbook provides a baseline OpenVPN configuration only. Advanced routing, bridge, MFA, and
  site-specific firewall policies should be handled in wrapper cookbooks.

## Test and CI Notes

* Arch Linux and Red Hat support are retained from main, including ChefSpec coverage. The
  Docker registry returned `no such manifest: docker.io/dokken/archlinux:latest` on 2026-11-12.
  No licensed Red Hat integration image is configured in this repository. Kitchen/CI keeps
  its existing 13 Linux images; AlmaLinux covers the RHEL-family package/service workflow,
  but is not direct evidence of Red Hat or Arch convergence.
* Arch packages ship the upstream split `openvpn-client@` / `openvpn-server@` units, not the
  obsolete `openvpn@` unit. Use the same client/server subdirectories as Fedora/RHEL.
* AlmaLinux's OpenSSL applies request extensions during `openssl req`; use `v3_req` for
  the CSR and apply `server` extensions only when the CA signs it. Applying the server
  authorityKeyIdentifier to a CSR fails because a request has no issuer certificate.
* Debian 13 omits `/etc/sysctl.conf`, but Chef's native sysctl resource still reloads
  that path. Create it only when absent and forwarding is enabled; preserve existing content.
* Current Fedora OpenSSL no longer provides the engines module. The PKI template must
  not initialise its unused legacy engine section, or all certificate commands fail to start.
* Dokken is the default CI/local strategy because the resources are Linux systemd/package based.
* The default suite exercises install, server config, service enable/start, PKI file generation,
  and one client bundle.
* InSpec profiles must not add `supports` filters; container platform strings drift across Dokken
  images and can silently skip controls.

## Sources

* [Debian openvpn package](https://packages.debian.org/bookworm/openvpn)
* [Debian 13 openvpn package](https://packages.debian.org/trixie/openvpn)
* [Ubuntu 22.04 openvpn package](https://packages.ubuntu.com/jammy/openvpn)
* [Ubuntu 24.04 openvpn package](https://packages.ubuntu.com/noble/openvpn)
* [Fedora openvpn package](https://packages.fedoraproject.org/pkgs/openvpn/openvpn/)
* [Fedora OpenVPN service and configuration paths](https://fedoraproject.org/wiki/OpenVPN)
* [Upstream systemd instance layout](https://github.com/OpenVPN/openvpn/blob/master/distro/systemd/README.systemd)
* [Arch OpenVPN package files](https://archlinux.org/packages/extra/x86_64/openvpn/files/)
