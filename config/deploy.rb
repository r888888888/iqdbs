# config valid only for current version of Capistrano
lock '3.6.1'

set :application, 'iqdbs'
set :repo_url, 'git://github.com/r888888888/iqdbs.git'
set :rbenv_type, :user
set :rbenv_ruby, "2.3.1"
set :linked_files, fetch(:linked_files, []).push(".env")
