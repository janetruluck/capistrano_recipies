set_default(:firewall_gist_url, 'https://gist.github.com/jasontruluck/02eb2fcd40a088bf8cce/download')

namespace :iptables do
  desc "Install IPtables and IPtables Persistent"
  task :install do
    run "#{sudo} apt-get install iptables -y"
  end
  after "deploy:install", "iptables:install"

  desc "Setup IPtables firewall"
  task :setup do
    run "wget -q -O firewall #{firewall_gist_url}"
    run "tar --strip-components=1 -xvzf  firewall"
    run "#{sudo} mv iptables.firewall.rules /etc/"
    run "#{sudo} mv firewall /etc/network/if-pre-up.d/"
    run "#{sudo} iptables-restore < /etc/iptables.firewall.rules"
    run "#{sudo} chmod +x /etc/network/if-pre-up.d/firewall"
  end
  after "deploy:setup", "iptables:setup"

  desc "Disable IPtables Firewall (you will need to re-run iptables:setup to re enable)"
  task :disable do
    run "#{sudo} iptables -F"
  end
end

