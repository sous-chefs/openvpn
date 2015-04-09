require 'spec_helper'

describe 'openvpn::server' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: ['openvpn_conf']) do |node|
      node.set['openvpn']['push_options'] = {
        'dhcp-options' => ['DOMAIN local',
                           'DOMAIN-SEARCH local']
      }
    end.converge(described_recipe)
  end

  it 'converges' do
    chef_run
  end

  it 'makes a template with dhcp options' do
    expect(chef_run).to render_file('/etc/openvpn/server.conf')
      .with_content('push "dhcp-options DOMAIN local"')
    expect(chef_run).to render_file('/etc/openvpn/server.conf')
      .with_content('push "dhcp-options DOMAIN-SEARCH local"')
  end
end
