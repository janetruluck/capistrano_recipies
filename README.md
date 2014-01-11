Note: This is dated, but I am leaving this here in case it helps anyone else. Provisioning has since been moved to Ansible and capistrano controls deployment as it should :) .
# Capistrano Recipies

This is my set of default cap recipies for deploying with Capistrano. It takes care of installing and provisioning the servers, no chef needed at the moment.

###Recipies included:
- Nginx
- Redis
- Unicorn
- Postgresql
- monit
- rbenv
- nodejs
- ssh
- iptables
- fail2ban
- newrelic

###Usage
1. ssh into server
2. (remote) `adduser deploy --ingroup sudo`
3. (remote) `exit`
4. (local) `cap deploy:install`
5. (local) `cap deploy:setup`
