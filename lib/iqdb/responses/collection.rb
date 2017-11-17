module Iqdb
  module Responses
    class Collection
      attr_reader :responses
      include Enumerable
      extend Forwardable
      delegate [:<=>, :each, :to] => :matches
      
      def initialize(response_string)
        @responses = response_string.split(/\n/).map do |string|
          ::Iqdb::Responses.const_get("Response_#{string[0..2]}").new(string[4..-1])
        end
      end

      def matches
        @matches ||= responses.select {|x| x.is_a?(Iqdb::Responses::Response_200) && x.score >= 80}
      end

      def errored?
        errors.any?
      end

      def errors
        @errors ||= responses.select {|x| x.is_a?(Iqdb::Responses::Error)}.map {|x| x.to_s}
      end

      def to_json
        if errored?
          JSON.generate(errors)
        else
          JSON.generate(matches.map {|x| {"post_id" => x.post_id, "width" => x.width, "height" => x.height, "score" => x.score}})
        end
      end
    end
  end
end
