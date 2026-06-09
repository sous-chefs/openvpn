# frozen_string_literal: true

property :key_dir, String, default: '/etc/openvpn/keys'
property :easy_rsa_dir, String, default: '/etc/openvpn/easy-rsa'
property :key_size, Integer, default: 2048
property :ca_expire, Integer, default: 3650
property :key_expire, Integer, default: 3650
property :key_country, String, default: 'US'
property :key_province, String, default: 'CA'
property :key_city, String, default: 'San Francisco'
property :key_org, String, default: 'Fort Funston'
property :key_email, String, default: 'admin@example.com'
