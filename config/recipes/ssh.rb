set_default(:local_key_location, "/Users/jasontrulucks/.ssh/personal") # Location on local machine of SSH key
set_default(:key, "id_rsa.pub") # Name of the Local SSH key

namespace :ssh do
  desc "Transfer SSH key from local machine to server for public key authentication"
  task :install do
    run "mkdir -p /home/#{user}/.ssh"
    run_locally("scp #{local_key_location}/#{key} #{user}@#{server_ip}:/home/#{user}/.ssh/authorized_keys")
    run "chown -R #{user}:#{user_group} /home/#{user}/.ssh"
    run "chmod 700 /home/#{user}/.ssh"
    run "chmod 600 /home/#{user}/.ssh/authorized_keys"
  end
  before "deploy:install", "ssh:install"

  desc "Disable Password Authenticaton and Root login via SSH"
  task :setup do
    run "#{sudo} sed -i -e 's/.*PasswordAuthentication.*/PasswordAuthentication no/g' /etc/ssh/sshd_config"
    run "#{sudo} sudo sed -i -e 's/.*PermitRootLogin.*/PermitRootLogin no/g' /etc/ssh/sshd_config"
    run "#{sudo} service ssh restart"
  end
  after "deploy:isntall", "ssh:setup"
end
