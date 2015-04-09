# Encoding: utf-8
require 'spec_helper'

describe package('openvpn') do
  it { is_expected.to be_installed }
end
