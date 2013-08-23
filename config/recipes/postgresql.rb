set_default(:postgresql_host, "localhost")
set_default(:postgresql_user) { user }
set_default(:postgresql_password) { Capistrano::CLI.password_prompt "PostgreSQL Password: " }
set_default(:postgresql_database) { "#{application}_production" }
set_default(:postgresql_version) { "9.2" }
set_default(:postgresql_local_auth_type) { "md5" }
set_default(:postgresql_pid) { "/var/run/postgresql/#{postgresql_version}-main.pid" }
set_default(:use_hstore) { true }

namespace :postgresql do
  desc "Install the latest stable release of PostgreSQL."
  task :install, roles: :db, only: {primary: true} do
    run "#{sudo} add-apt-repository ppa:pitti/postgresql -y"
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install postgresql-#{postgresql_version}"
    run "#{sudo} apt-get -y install libpq-dev"
    run "#{sudo} apt-get -y install postgresql-contrib-#{postgresql_version}"
  end
  after "deploy:install", "postgresql:install"

  desc "Update pg_hba.conf to use local auth type"
  task :update_auth, roles: :db, only: {primary: true} do
    postgresql_config "pg_hba"
    restart
  end
  after "postgresql:install", "postgresql:update_auth"

  desc "Create a database for this application."
  task :create_database, roles: :db, only: {primary: true} do
    user_exists = capture %Q{#{sudo} -u postgres psql -c "select count(*) from pg_roles where rolname='#{postgresql_user}'"}
    unless user_exists.split("\n")[2].strip.to_i == 0
      run %Q{#{sudo} -u postgres psql -c "create user #{postgresql_user} with password '#{postgresql_password}';"}
      run %Q{#{sudo} -u postgres psql -c "create database #{postgresql_database} owner #{postgresql_user};"}
      if use_hstore
        run %Q{#{sudo} -u postgres psql -c "create extension if not exists hstore;" #{postgresql_database}}
      end
    end
  end
  after "deploy:setup", "postgresql:create_database"

  desc "Generate the database.yml configuration file."
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "postgresql.yml.erb", "#{shared_path}/config/database.yml"
  end
  after "deploy:setup", "postgresql:setup"

  desc "Symlink the database.yml file into latest release"
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after "deploy:finalize_update", "postgresql:symlink"

  %w[start stop restart].each do |command|
    desc "#{command} postgresql"
    task command, roles: :web do
      run "#{sudo} service postgresql #{command}"
    end
  end
end

def postgresql_config(name, destination = nil)
  destination ||= "/etc/postgresql/#{postgresql_version}/main/#{name}.conf"
  template "postgresql/#{name}.erb", "/tmp/#{name}"
  run "#{sudo} mv /tmp/#{name} #{destination}"
  run "#{sudo} chown postgres:postgres #{destination}"
  run "#{sudo} chmod 600 #{destination}"
end
