name "vpn_expedient"
description "VPN (expedient side)"

default_attributes(
  "openvpn" => {
    "config" => {
      "ifconfig" => "10.1.0.1 10.1.0.2",
      "remote" => "54.191.207.59",
      "routes" => { 
        "172.24.0.0" => "255.255.0.0"
      }
    },
    "name" => "default"
  }
)

override_attributes(
)

run_list(
  "recipe[openvpn::p2p]"
)
