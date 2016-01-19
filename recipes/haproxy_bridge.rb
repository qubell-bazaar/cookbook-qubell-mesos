if node['mesos']['zookeeper_exhibitor_discovery'] && node['mesos']['zookeeper_exhibitor_url']
      zk_nodes = MesosHelper.discover_zookeepers_with_retry(node['mesos']['zookeeper_exhibitor_url'])

         if zk_nodes.nil?
             Chef::Application.fatal!('Failed to discover zookeepers. Cannot continue.')
         end
end
marathons = zk_nodes['servers'].sort.map { |s| "#{s}:8080" }
remote_file "/usr/bin/haproxy-marathon-bridge" do
  source "https://raw.githubusercontent.com/mesosphere/marathon/master/bin/haproxy-marathon-bridge"
  mode "0755"
  user 'root'
  group 'root'
end

execute "install haproxy-marathon-bridge" do
  command "/usr/bin/haproxy-marathon-bridge install_haproxy_system #{marathons.join(' ')}"
end
