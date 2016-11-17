$:.unshift(File.expand_path("../../lib", __FILE__))

require "dotenv"
Dotenv.load

require "sinatra"
require "json"
require "iqdb/server"

get "/similar" do
  url = params["url"]
  server = Iqdb::Server.default
  results = server.download_and_query(url, 1)
  JSON.generate(results)
end
