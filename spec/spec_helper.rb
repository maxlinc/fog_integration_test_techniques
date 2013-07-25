require 'vcr'
require 'vcr/filter_processor'
require 'vcr/filters/rackspace_confidential'
require 'vcr/filters/building_servers'

RSpec.configure do |c|
  # so we can use :vcr rather than :vcr => true;
  # in RSpec 3 this will no longer be necessary.
  c.treat_symbols_as_metadata_keys_with_true_values = true
end

shared_context "Mock with Fog", :mock => :fog do
  before { Fog.mock! }
  after { Fog.unmock! }
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  # The live test would not be possible without this option
  config.allow_http_connections_when_no_cassette = true
  # filters = VCR::FilterProcessor.new(config)
  config.register_filter(VCR::Filters::RackspaceConfidential)
  config.register_filter(VCR::Filters::BuildingServers)
end