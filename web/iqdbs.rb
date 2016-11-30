$:.unshift(File.expand_path("../../lib", __FILE__))

require "dotenv"
Dotenv.load

require "sinatra"
require "json"
require "iqdb/server"

set :port, ENV["SINATRA_PORT"]

before do
  if params["key"] != ENV["AUTH_KEY"]
    halt 401
  end
end

get "/similar" do
  url = params["url"]
  server = Iqdb::Server.default
  results = server.download_and_query(url, 1)
  JSON.generate(results)
end
