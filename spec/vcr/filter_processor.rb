module VCR
  class Configuration
    def register_filter(filter)
      filter_processor.register(filter)
    end

    private
    def filter_processor
      @filter_processor ||= FilterProcessor.new(self)
    end
  end
end

module VCR
  class FilterProcessor

    #install in VCR config
    # VCR.config do |c|
      # FilterProcessor.new(config)
    # end
    def initialize(config)
      @filters = []
      config.before_record {|i,c| self.process_before_record(i,c) }
      config.before_playback {|i,c| self.process_before_playback(i,c) }
    end

    def register(filter)
      @filters << filter.new()
    end

    def process_before_record(interaction, cassette)
      @filters.each do |f|
        begin
          f.before_record(interaction, cassette) if f.respond_to?(:before_record)
        rescue => e
        end
      end
    end

    def process_before_playback(interaction, cassette)
      @filters.each do |f|
        begin
          f.before_playback(interaction, cassette) if f.respond_to?(:before_playback)
        rescue => e
        end
      end
    end
  end
end