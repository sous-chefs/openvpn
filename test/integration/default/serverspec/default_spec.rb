require 'serverspec'
include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

describe 'openvpn::default' do
  it 'starts and enables openvpn' do
    expect(service('openvpn')).to be_enabled
    expect(service('openvpn')).to be_running
  end

  it 'is listening on the correct port' do
    expect(port(1194)).to be_listening
  end
end
