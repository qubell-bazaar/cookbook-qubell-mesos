if node['mesos']['zookeeper_exhibitor_discovery'] && node['mesos']['zookeeper_exhibitor_url']
      zk_nodes = MesosHelper.discover_zookeepers_with_retry(node['mesos']['zookeeper_exhibitor_url'])

         if zk_nodes.nil?
             Chef::Application.fatal!('Failed to discover zookeepers. Cannot continue.')
         end
end
ec2_region = node['qubell-mesos']['ec2_zone'].gsub(/.$/, '')
template "/etc/resolv.conf" do
  source 'resolv.conf.erb'
  owner 'root'
  group 'root'
  variables({
   :hosts => zk_nodes['servers'],
   :ec2_region => ec2_region
  })
end
