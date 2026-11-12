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
| `config_path`  | String | platform-specific | Config file path                    |
| `supports`     | Hash   | status/restart    | Chef service support map            |

## Examples

```ruby
openvpn_service 'server' do
  service_type 'server'
  action [:enable, :start]
end
```
