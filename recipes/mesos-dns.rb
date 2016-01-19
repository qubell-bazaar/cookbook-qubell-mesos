remote_file "/usr/bin/mesos-dns" do
  source "https://github.com/mesosphere/mesos-dns/releases/download/v0.5.1/mesos-dns-v0.5.1-linux-amd64"
  mode '0755'
  owner 'root'
  group 'root'
end

directory "/etc/mesos-dns/" do 
  action :create
end

if node['mesos']['zookeeper_exhibitor_discovery'] && node['mesos']['zookeeper_exhibitor_url']
    zk_nodes = MesosHelper.discover_zookeepers_with_retry(node['mesos']['zookeeper_exhibitor_url'])

      if zk_nodes.nil?
            Chef::Application.fatal!('Failed to discover zookeepers. Cannot continue.')
      end

    zk_url = 'zk://' + zk_nodes['servers'].sort.map { |s| "#{s}:#{zk_nodes['port']}" }.join(',') + '/' +  node['mesos']['zookeeper_path']
end

resolvers = open("/etc/resolv.conf").grep(/nameserver/).map { |s| "#{s}".gsub(/^nameserver /, '').gsub(/\n$/, '') }.to_s
ec2_region = node['qubell-mesos']['ec2_zone'].gsub(/.$/, '')
masters = zk_nodes['servers'].sort.map { |s| "#{s}:#{zk_nodes['port']}" }
  template "/etc/resolv.conf" do
    source 'resolv.conf.erb'
    owner 'root'
    group 'root'
    variables({
      :hosts => zk_nodes['servers'],
      :ec2_region => ec2_region
    })
  end

  template "mesos-dns-wrapper" do 
    path "/etc/mesos-dns/start-mesos-dns"
    source 'wrapper.erb'
    owner 'root'
    group 'root'
    mode '0755'
  end

  template "mesos-dns-init" do
    path   "/etc/init/mesos-dns.conf"
    source 'upstart.erb'
    owner 'root'
    group 'root'
    variables({
       :name => "Start mesos-dns",
       :wrapper => "/etc/mesos-dns/start-mesos-dns"
    })
  end

  service "mesos-dns" do
    provider Chef::Provider::Service::Upstart
    supports status: true, restart: true
    subscribes :restart, "template[mesos-dns-init]"
    subscribes :restart, "template[mesos-dns-wrapper]"
    action [:enable, :start]
  end

template "/etc/mesos-dns/config.json" do
  source 'config.json.erb'
  owner 'root'
  group 'root'
  mode '0755'
  variables(
    :zk_url => zk_url,
    :resolvers => resolvers,
    :masters => masters
  )
  notifies :restart, 'service[mesos-dns]', :delayed
end
