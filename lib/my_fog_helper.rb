class MyFogHelper
    def initialize(username, api_key)
        @username = username
        @api_key = api_key
    end
    
    def create_server
        flavor = service.flavors.first
        # pick the first Ubuntu image we can find
        image = service.images.find {|image| image.name =~ /Ubuntu/}
        server_name = "test_server"
        
        server = service.servers.create :name        => server_name,
                                        :flavor_id   => flavor.id,
                                        :image_id    => image.id
        server.wait_for(600, 5) {
            ready?
        }
        server
    end
    
    def service
        @service ||= Fog::Compute.new({
            :provider           => 'rackspace',
            :rackspace_username => @username,
            :rackspace_api_key  => @api_key,
            :version            => :v2,
            :rackspace_region   => :ord})
    end
end