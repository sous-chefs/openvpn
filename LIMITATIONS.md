# Limitations

## Package Availability

OpenVPN (community edition) is available in the default OS repositories for all supported platforms. No third-party repositories are required for basic installation, though the cookbook optionally supports the official OpenVPN APT repository and EPEL for RHEL-family systems.

### APT (Debian/Ubuntu)

- Ubuntu 22.04: openvpn 2.5.x (amd64, arm64)
- Ubuntu 24.04: openvpn 2.6.x (amd64, arm64)
- Debian 12: openvpn 2.6.x (amd64, arm64)
- Debian 13: openvpn 2.6.x (amd64, arm64)

Optional: The official OpenVPN APT repository (`build.openvpn.net`) provides newer releases.

### DNF/YUM (RHEL family)

Requires EPEL repository for RHEL 8/9 family distributions.

- AlmaLinux 8 / Rocky Linux 8 / RHEL 8: openvpn 2.4.x via EPEL (amd64, arm64)
- AlmaLinux 9 / Rocky Linux 9 / RHEL 9: openvpn 2.5.x via EPEL (amd64, arm64)
- AlmaLinux 10 / Rocky Linux 10 / RHEL 10: openvpn 2.6.x via EPEL (amd64, arm64)
- CentOS Stream 9: openvpn 2.5.x via EPEL (amd64, arm64)
- CentOS Stream 10: openvpn 2.6.x via EPEL (amd64, arm64)
- Amazon Linux 2023: openvpn 2.5.x in default repos (amd64, arm64)
- Fedora 42/43: openvpn 2.6.x in default repos (amd64, arm64)

### Zypper (openSUSE)

- openSUSE Leap 15.6: openvpn 2.5.x (amd64, arm64)
- openSUSE 16.0: openvpn 2.6.x (amd64, arm64)

## Architecture Limitations

- Both amd64 and arm64 packages are available across all supported platforms
- No architecture-specific restrictions

## Container/Dokken Limitations

- OpenVPN requires the `tun` device (`/dev/net/tun`), which is not available in unprivileged containers
- Dokken containers must run with `privileged: true` to access the TUN/TAP device
- IP forwarding sysctl settings require appropriate container capabilities
- Service start/stop tests may behave differently in containers vs bare metal

## Platform Notes

- **Arch Linux**: Listed in `metadata.rb` but not actively tested in CI. The `openvpn` package is available in the official Arch repositories
- **openSUSE**: Not currently supported by this cookbook. Would require zypper package management support
- **RHEL/CentOS/Alma/Rocky**: Use systemd instance units (`openvpn-server@.service`) on version 8+, different from Debian-family (`openvpn@.service`)

## Known Issues

- The `easy-rsa` tooling bundled via templates is a legacy approach; modern OpenVPN deployments typically use the `easy-rsa` package directly
- DH parameter generation (`dh2048.pem`) is CPU-intensive and can take several minutes on first converge
- The CRL refresh guard uses file mtime comparison which may not work correctly on filesystems without mtime support
