# Install marathon

if node['mesos']['zookeeper_exhibitor_discovery'] && node['mesos']['zookeeper_exhibitor_url']
  file "/etc/mesos/zk" do
    content node['mesos']['master']['flags']['zk']
  end
end

marathon_conf = "/etc/marathon/conf"
hostname = node['cloud']['public_hostname'] rescue node['hostname']

directory marathon_conf do
  recursive true
end

file ::File.join(marathon_conf, "hostname") do
  content hostname
end

file ::File.join(marathon_conf, "http_port") do
  content "8080"
end

package "marathon"
package "chronos"
service "marathon" do
  action [ :enable, :start ]
end
service "chronos" do
  action [ :enable, :start ]
end
