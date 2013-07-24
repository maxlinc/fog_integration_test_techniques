require 'spec_helper'
require 'fog'
require 'my_fog_helper'

describe Fog do
    let(:username) { ENV['RAX_USERNAME'] }
    let(:api_key) { ENV['RAX_API_KEY'] }


    context "Mock with Fog", :mock => :fog do
      it "should create a server (Fog.mock!)", :mock => :fog do
          helper = MyFogHelper.new(username, api_key)
          server = helper.create_server()
          server.state.should eq('ACTIVE')
      end
    end

    context "Use VCR", :mock => :vcr do
      it "should create a server (vcr)", :vcr do
          helper = MyFogHelper.new(username, api_key)
          server = helper.create_server()
          server.state.should eq('ACTIVE')
      end
    end

    it "should create a server (live)", :live do
        helper = MyFogHelper.new(username, api_key)
        server = helper.create_server()
        server.state.should eq('ACTIVE')
    end
end
