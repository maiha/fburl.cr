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
      property array : Array(Options) = Array(Options).new

      def initialize(@args : Array(String), @max : Int32 = 50)
      end
      
      def execute(args)
        if array.size >= @max
          raise Errors::TooManyBatch.new("Maximum batch size is #{@max}")
        end
        array << Options.parse!(args)
      end

      protected def execute
        client = Client.new(@args + ["-F", "batch=#{batch_string}"])
        client.execute
      end

      def batch_string
        "[%s]" % array.map(&.batch_string).join(",")
      end
    end
    
    def batch : HTTP::Client::Response
      api = BatchApi.new(original_args, max: options.maxbatch)
      yield api
      api.execute
    end
  end
end
