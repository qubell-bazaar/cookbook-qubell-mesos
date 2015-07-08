#
# Cookbook Name:: qubell-mesos
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
case node['platform_family']
  when "debian"
    execute "update packages cache" do
      command "apt-get update"
    end
  end

package 'docker.io'
node.default['mesos']['master']['flags']['hostname'] = node['fqdn']
node.default['mesos']['slave']['flags']['hostname'] = node['fqdn']
