require 'spec_helper'

describe 'openvpn::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'converges' do
    chef_run
    pending
  end
end
