module VCR
    module Filters
        class BuildingServers
            def before_record(interaction, cassette)
                # Throw away build state - just makes server.wait_for loops really long during replay
                begin
                    json = JSON.parse(interaction.response.body)
                    if json['server']['status'] == 'BUILD'
                        # Ignoring interaction because server is in BUILD state
                        interaction.ignore!
                    end
                rescue
                end
            end
        end
    end
end