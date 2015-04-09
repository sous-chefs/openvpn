require 'spec_helper'

describe 'openvpn::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new.converge(described_recipe)
  end

  it 'converges' do
    chef_run
  end
end

describe package('openvpn') do
  it { should be_installed }
end
