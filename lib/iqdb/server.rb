require 'cityhash'
require 'net/http'

module Iqdb
  class Server
    FLAG_SKETCH = 0x01
    FLAG_GRAYSCALE = 0x02
    FLAG_WIDTH_AS_SET = 0x08
    FLAG_DISCARD_COMMON_COEFFS = 0x10

    attr_reader :hostname, :port, :socket

    def self.default
      new(ENV["IQDB_HOSTNAME"], ENV["IQDB_PORT"])
    end

    def initialize(hostname, port)
      @hostname = hostname
      @port = port
    end

    def open
      @socket = TCPSocket.open(hostname, port)
    end

    def close
      socket.close
    end

    def request
      open
      yield
    ensure
      close if socket
    end

    def add(post_id, file_path)
      request do
        hex = post_id.to_s(16)
        socket.puts "add 0 #{hex}:#{file_path}"
        socket.puts "done"
        socket.read
      end
    end

    def download(image_url, ref = nil)
      url_hash = CityHash.hash64(image_url).to_s(36)
      url = URI.parse(image_url)
      ret = nil
      headers = {
        "User-Agent" => "iqdbs/1.0"
      }
      if ref
        headers["Referer"] = ref
      end

      Tempfile.open("iqdbs-#{url_hash}") do |f|
        Net::HTTP.start(url.host, url.port, :use_ssl => url.is_a?(URI::HTTPS)) do |http|
          http.request_get(url.request_uri, headers) do |res|
            ret = yield(f, res)
          end
        end
      end

      ret
    end

    def download_and_add(image_url, post_id)
      download(image_url) do |f, res|
        if res.is_a?(Net::HTTPSuccess)
          res.read_body(f)
          f.close
          add(post_id, f.path)
        end
      end
    end

    def remove(post_id)
      request do
        hex = post_id.to_s(16)
        socket.puts "remove 0 #{hex}"
        socket.puts "done"
        socket.read
      end
    end

    def download_and_query(image_url, referer, n, flags = 0)
      download(image_url, referer) do |f, res|
        if res.is_a?(Net::HTTPSuccess)
          res.read_body(f)
          f.close
          query(n, f.path, flags)
        else
          raise Responses::Error.new("HTTP error code: #{res.code} #{res.message}")
        end
      end
    end

    def query(n, filename, flags = 0)
      request do
        socket.puts "query 0 #{flags} #{n} #{filename}"
        socket.puts "done"
        responses = Responses::Collection.new(socket.read)
      end
    end
  end
end
