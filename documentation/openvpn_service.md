# openvpn_service

Manages an OpenVPN systemd service.

## Actions

| Action     | Description                         |
|------------|-------------------------------------|
| `:enable`  | Enables the service (default)       |
| `:start`   | Starts the service                  |
| `:restart` | Restarts the service                |
| `:stop`    | Stops and disables the service      |
| `:delete`  | Stops and disables the service      |

## Properties

| Property       | Type   | Default           | Description                         |
|----------------|--------|-------------------|-------------------------------------|
| `config_name`  | String | name property     | OpenVPN instance/config name        |
| `service_type` | String | `config_name`     | Service type, usually `server`      |
| `service_name` | String | platform-specific | Full service unit name              |
| `config_path`  | String | platform-specific | Configuration file read by the packaged service |
| `supports`     | Hash   | status/restart    | Chef service support map            |

For a custom `config_path`, the resource links the packaged instance's expected path to the custom file. The file must be visible and readable inside the unit's sandbox. Move an existing regular file at the packaged path before adopting a custom path. Remove the old link before changing the custom path or returning to the packaged default. A service selected explicitly with `service_name` keeps its own configuration handling.

## Examples

```ruby
openvpn_service 'server' do
  service_type 'server'
  action [:enable, :start]
end
```
