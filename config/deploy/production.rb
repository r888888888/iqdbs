set :rails_env, "production"

server "karasuma.donmai.us", :user => "danbooru", :roles => %w(web app db)
