namespace :redis do
  desc "Install Redis"
  task :install, roles: :app do
    run "#{sudo} apt-get install redis-server"
    start
  end
  after "deploy:install", "redis:install"

  %w[start stop restart].each do |command|
    desc "#{command} redis"
    task command, roles: :app do
      run "#{sudo} service redis-server #{command}"
    end
  end
end

