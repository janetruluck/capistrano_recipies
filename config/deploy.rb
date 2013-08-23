require "bundler/capistrano"

load "config/recipes/base"
load "config/recipes/ssh"
load "config/recipes/nginx"
load "config/recipes/redis"
load "config/recipes/unicorn"
load "config/recipes/postgresql"
load "config/recipes/nodejs"
load "config/recipes/rbenv"
load "config/recipes/iptables"
load "config/recipes/fail2ban"
load "config/recipes/check"
load "config/recipes/monit"
load "config/recipes/newrelic"

set :server_ip, fetch(:server_ip, "my_app_ip_or_dns") # Default server ip to staging

server server_ip, :web, :app, :resque_worker, :db, primary: true

set :application, "my_app_name"
set :user, "deploy"
set :user_group, "sudo"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

# Resque
set :workers, {
  "worker" => 1 # worker name and number
}

set :scm, "git"
set :repository, "git@github.com:mission-control/#{application}.git"
set :branch, fetch(:branch, "master")
set :env, fetch(:env, "production")

set :maintenance_template_path, File.expand_path("../recipes/templates/maintenance.html.erb", __FILE__)

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy:restart", "resque:restart" 
after "deploy", "deploy:cleanup" # keep only the last 5 releases
