# AGENTS.md

## Cookbook Purpose

This cookbook manages OpenVPN Community Edition through custom resources for package
installation, server configuration, service management, and client certificate bundles.

## Agent Findings

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
