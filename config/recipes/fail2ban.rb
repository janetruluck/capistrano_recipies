namespace :fail2ban do
  desc "Install fail2ban" 
  task :install do
    run "#{sudo} apt-get install fail2ban -y"
  end
  after "deploy:install", "fail2ban:install"
end

