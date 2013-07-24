class MyFogHelper
    def initialize(username, api_key)
        @username = username
        @api_key = api_key
    end
    
    def create_server
        flavor = service.flavors.first
        image = service.images.first
        server_name = "server name"
        
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
            :version            => :v2 })
    end
end