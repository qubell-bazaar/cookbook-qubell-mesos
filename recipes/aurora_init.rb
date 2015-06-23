chef_gem "chef-rewind"
require 'chef/rewind'

rewind 'execute[initialize aurora replicated log]' do
  user "aurora"
  group "aurora"
end

bash 'update aurora-scheduler upstart' do
  code <<-EEND
  sed -i '/post-stop/a console log' /etc/init/aurora-scheduler.conf
  EEND
  notifies :restart, 'service[aurora-scheduler]'
end
