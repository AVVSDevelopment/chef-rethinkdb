#
# Author:: Vitaly Aminev (v@aminev.me)
# Cookbook Name:: rethinkdb
# Recipe:: start
#
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


rethinkdb_servers = search(:node, "role:rethinkdb")
servers_ips = {}
rethinkdb_servers.each do |server|
  if node['rethinkdb']['bind_to_network_interface']
    servers_ips[server.name] = server.network.interfaces[node['rethinkdb']['network_interface']].routes[0].src
  else
    servers_ips[server.name] = server.ipaddress
  end
end

# service start
service 'rethinkdb' do
  action :start
  supports :status => true, :restart => true
  provider Chef::Provider::Service::Init
end

node.rethinkdb.instances.each_with_index do |instance, index|
  
  user "#{instance.user}" do
    system false   
    shell '/bin/false' 
    :create
  end
  
  unless system('egrep -i "^rethinkdb" /etc/group')    
    group "#{instance.group}" do
      action :create
    end
  end
  
  group "#{instance.group}" do
    action :modify    
    members instance.user
    append true
  end
  
  directory "/opt/rethinkdb/#{instance.name}" do
    owner instance.user
    group instance.group
    recursive true
    mode 00775
  end

  if node['rethinkdb']['bind_to_network_interface'] 
    node.default.rethinkdb[index].address = node.network.interfaces[node['rethinkdb']['network_interface']]
  end
 
  config_name = "/etc/rethinkdb/instances.d/#{instance.name}.conf"
  
  template config_name do
    user instance.user
    group instance.group
    source 'rethinkdb.conf.erb'
    variables({
      :instance => node.default.rethinkdb[index],
      :cores    => node.rethinkdb.make_threads 
    })
    mode 00440
  end

  if node['rethinkdb']['join_to_cluster']
    rethinkdb_servers = search(:node, "role:rethinkdb")
    rethinkdb_servers.each do |server|
      execute "joining #{server.name}" do
        command "sed -i 's/# join=example.com:29015/# join=example.com:29015\\njoin=#{servers_ips[server.name]}/g' #{config_name}"
      end      
    end
  end

  ruby_block "notify service" do
    block do
      # empty
    end
    notifies :restart, "service[rethinkdb]", :delayed
  end
end
