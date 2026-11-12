# openvpn_install

Installs or removes OpenVPN packages.

## Actions

| Action     | Description                         |
|------------|-------------------------------------|
| `:install` | Installs OpenVPN packages (default) |
| `:remove`  | Removes OpenVPN packages            |

## Properties

| Property           | Type          | Default     | Description                         |
|--------------------|---------------|-------------|-------------------------------------|
| `package_name`     | String        | `'openvpn'` | OpenVPN package name                |
| `install_epel`     | true, false   | `true`      | Install `epel-release` on EL nodes  |
| `install_easy_rsa` | true, false   | `false`     | Install distribution `easy-rsa`     |
| `install_tar`      | true, false   | `true`      | Install `tar` for client bundles    |
| `install_bash`     | true, false   | `true`      | Install `bash` for helper scripts   |

## Examples

```ruby
openvpn_install 'default'
```

```ruby
openvpn_install 'custom' do
  package_name 'openvpn'
  install_easy_rsa true
end
```
