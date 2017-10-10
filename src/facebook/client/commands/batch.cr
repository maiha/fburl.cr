class Facebook::Client
  # API for Facebook Batch API
  #
  # Used in `Facebook::Client#batch`.
  #
  # Example:
  #
  # ```crystal
  # client.batch do |batch|
  #   batch.execute("/v1/me")
  #   batch.execute("/v1/act_123/campaigns")
  # end
  # ```
  #
  # is equivalent to
  #
  # ```crystal
  # Facebook::Client.new(%(-F batch=[{"method":"GET","relative_url":"v1/me"},{"method":"GET","relative_url":"v1/act_123/campaigns"}]))
  # ```
  module Commands::Batch
    class BatchApi
      def initialize(@max : Int32 = 50)
        @array = Array(Options).new
      end
      
      def execute(args)
        if @array.size >= @max
          raise Errors::TooManyBatch.new("Maximum batch size is #{@max}")
        end
        @array << Options.parse!(args)
      end

      def value : String
        "[%s]" % @array.map(&.batch_value).join(",")
      end

      def arg : String
        "-F batch=#{value}"
      end
    end
    
    def batch : BatchApi
      BatchApi.new(max: options.maxbatch)
    end

    def batch : HTTP::Client::Response
      api = batch
      yield api
      merge(api.arg).execute
    end
  end
end
