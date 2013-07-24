require 'vcr'

RSpec.configure do |c|
  # so we can use :vcr rather than :vcr => true;
  # in RSpec 3 this will no longer be necessary.
  c.treat_symbols_as_metadata_keys_with_true_values = true
end

shared_context "Mock with Fog", :mock => :fog do
  before { Fog.mock!; puts "Mocking with Fog" }
  after { Fog.unmock! }
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.allow_http_connections_when_no_cassette = true
#  c.default_cassette_options.merge!({:record => :none})
end

