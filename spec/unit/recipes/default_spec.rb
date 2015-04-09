require 'spec_helper'

describe 'openvpn::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new.converge(described_recipe)
  end

  it 'converges' do
    chef_run
  end

  it 'Installs the openvpn package' do
    expect(chef_run).to install_package('openvpn')
  end
end
