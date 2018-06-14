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

before "/similar" do
  if params["key"] != ENV["AUTH_KEY"]
    halt 401
  end
end

post "/similar" do
  file = params["file"]
  server = Iqdb::Server.default
  begin
    server.query(5, file["tempfile"].path).to_json
  rescue Iqdb::Responses::Error => e
    JSON.generate({"error" => e.to_s})
  end
end

get "/similar" do
  url = params["url"]
  ref = params["ref"]
  server = Iqdb::Server.default
  begin
    server.download_and_query(url, ref, 5).to_json
  rescue Iqdb::Responses::Error => e
    JSON.generate({"error" => e.to_s})
  end
end

get "/" do
	redirect "/index.html"
end
