$:.unshift(File.expand_path("../../lib", __FILE__))

require "dotenv"
Dotenv.load

require "sinatra"
require "json"
require "iqdb/responses/collection"
require "iqdb/responses/error"
require "iqdb/responses/responses"
require "iqdb/server"
require "iqdb/command"

set :port, ENV["SINATRA_PORT"]

# before "/similar" do
#   if params["key"] != ENV["AUTH_KEY"]
#     halt 401
#   end
# end

def find_referer(url)
  if url =~  /\Ahttps?:\/\/(?:\w+\.)?pixiv\.net/ || url =~ /\Ahttps?:\/\/i\.pximg\.net/
    return "https://www.pixiv.net"
  end

  if url =~ %r{https?://lohas\.nicoseiga\.jp} || url =~ %r{https?://seiga\.nicovideo\.jp}
    return "https://seiga.nicovideo.jp"
  end

  return nil
end

post "/similar" do
  server = Iqdb::Server.default

  begin
    if params["file"]
      file = params["file"]
      results = server.query(5, file["tempfile"].path)
      
      if params["callback"]
        data = results.matches.map {|x| [x.post_id, x.score]}.to_json
        url = URI::HTTP.build(host: params["callback"], query: URI.encode_www_form({matches: data}))
        redirect url.to_s
      else
        results.to_json
      end

    elsif params["url"]
      url = params["url"]
      ref = params["ref"] || find_referer(url)
      server.download_and_query(url, ref, 5).to_json
    end

  rescue Iqdb::Responses::Error => e
    JSON.generate({"error" => e.to_s})
  end
end

get "/" do
	redirect "/index.html"
end
