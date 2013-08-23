set_default(:newrelic_license_key) { Capistrano::CLI.password_prompt "New Relic License Key: " }

namespace :newrelic do
  desc "Install New Relic server monitoring"
  task :install do
    run "#{sudo} wget -O /etc/apt/sources.list.d/newrelic.list http://download.newrelic.com/debian/newrelic.list"
    run "#{sudo} apt-key adv --keyserver hkp://subkeys.pgp.net --recv-keys 548C16BF"
    run "#{sudo} apt-get update -y"
    run "#{sudo} apt-get install newrelic-sysmond -y"
    run "#{sudo} nrsysmond-config --set license_key=#{newrelic_license_key}"
    start
  end
  after "deploy:install", "newrelic:install"

  %w[start stop restart].each do |command|
    desc "#{command} New Relic Server Monitoring"
    task command do
      run "#{sudo} /etc/init.d/newrelic-sysmond #{command}"
    end
  end
end
