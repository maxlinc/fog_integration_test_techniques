module VCR
    module Filters
        class RackspaceConfidential

            def initialize
                # Doing these during in initialize should avoid recording the calls to Fog,
                # because this should be called before a cassette is inserted.
                require 'fog'
                identity = Fog::Identity.new({
                    :provider => 'Rackspace',
                    :rackspace_api_key => ENV['OS_PASSWORD'],
                    :rackspace_username => ENV['OS_USERNAME']
                })
                tenants = identity.tenants.map(&:id)
                @tenant_id = tenants.find {|t| t.include? 'MossoCloudFS'}
                @cdn_tenant_name = tenants.find {|t| !t.include? 'MossoCloudFS'}
            end

            def before_record(interaction, cassette)
                # We definitely need to hide our credentials!
                interaction.filter!(ENV['RAX_USERNAME'], '_RAX_USERNAME_')
                interaction.filter!(ENV['RAX_API_KEY'], '_RAX_API_KEY_')

                # Let's filter out our tenants
                interaction.filter!(@cdn_tenant_name, '_CDN-TENANT-NAME_')
                interaction.filter!(@tenant_id,'_TENANT_ID_')
            end

            def before_playback(interaction, cassette)
                # Some code may expect an integer here
                interaction.filter!('_TENANT_ID_', '000000')
            end
        end
    end
end