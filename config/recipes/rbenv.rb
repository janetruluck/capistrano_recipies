set_default :ruby_version, "1.9.3-p429"
set_default :rbenv_bootstrap, "bootstrap-ubuntu-12-04"

namespace :rbenv do
  desc "Install rbenv, Ruby, and the Bundler gem"
  task :install, roles: :app do
    run "#{sudo} apt-get -y install curl git-core"
    run "curl -L https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash"
    bashrc = <<-BASHRC
if [ -d $HOME/.rbenv ]; then 
  export PATH="$HOME/.rbenv/bin:$PATH" 
  eval "$(rbenv init -)" 
fi
    BASHRC
    put bashrc, "/tmp/rbenvrc"
    run "cat /tmp/rbenvrc ~/.bashrc > ~/.bashrc.tmp"
    run "mv ~/.bashrc.tmp ~/.bashrc"
    run %q{export PATH="$HOME/.rbenv/bin:$PATH"}
    run %q{eval "$(rbenv init -)"}
    rbenv "#{rbenv_bootstrap}"
    rbenv "install #{ruby_version}"
    rbenv "global #{ruby_version}"
    rbenv "rehash"
    run "gem install bundler --no-ri --no-rdoc"
  end
  after "deploy:install", "rbenv:install"
end

def rbenv(command)
  run "rbenv #{command}", :pty => true do |ch, stream, data|
    if data =~ /\[sudo\].password.for/
      ch.send_data(Capistrano::CLI.password_prompt("Password:") + "\n")
    else
      Capistrano::Configuration.default_io_proc.call(ch, stream, data)
    end
  end
end
