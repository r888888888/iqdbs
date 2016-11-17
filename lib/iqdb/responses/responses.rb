module Iqdb
  module Responses
    class Base
    end

    class Response_000 < Base
      def initialize(response_string)
      end
    end

    class Response_100 < Base
      attr_reader :message

      def initialize(response_string)
        @message = response_string
      end
    end

    class Response_101 < Base
      attr_reader :key, :value

      def initialize(response_string)
        @key, @value = response_string.split(/\=/)
      end
    end

    class Response_102 < Base
      attr_reader :dbid, :filename

      def initialize(response_string)
        @dbid, @filename = response_string.split(/ /)
      end
    end

    class Response_200 < Base
      attr_reader :imgid, :score, :width, :height

      def initialize(response_string)
        @imgid, @score, @width, @height = response_string.split(/ /)
        @score = score.to_f
        @width = width.to_i
        @height = height.to_i
      end

      def post_id
        imgid.to_i(16)
      end
    end

    class Response_201 < Base
      attr_reader :dbid, :imgid, :score, :width, :height

      def initialize(response_string)
        @dbid, @imgid, @score, @width, @height = response_string.split(/ /)
        @dbid = dbid.to_i
        @score = score.to_f
        @width = width.to_i
        @height = height.to_i
      end

      def post_id
        imgid.to_i(16)
      end
    end

    class Response_202 < Base
      attr_reader :original_id, :stddev, :dupes

      def initialize(response_string)
        response_string =~ /^(\d+)=([0-9.]+)/
        @original_id = $1
        @stddev = $2

        @dupes = response_string.scan(/(\d+):([0-9.]+)/).map {|x| [x[0].to_i(16), x[1].to_f]}
      end

      def original_post_id
        original_id.to_i(16)
      end
    end

    class Response_300 < Error
      attr_reader :message

      def initialize(response_string)
        @message = response_string
      end

      def to_s
        "Error: #{message}"
      end
    end

    class Response_301 < Error
      attr_reader :exception, :description

      def initialize(response_string)
        response_string =~ /^(\S+) (.+)/
        @exception = $1
        @description = $2
      end

      def to_s
        "Exception: #{exception}: #{description}"
      end
    end

    class Response_302 < Error
      attr_reader :exception, :description

      def initialize(response_string)
        response_string =~ /^(\S+) (.+)/
        @exception = $1
        @description = $2
      end

      def to_s
        "Fatal Exception: #{exception}: #{description}"
      end
    end
  end
end
