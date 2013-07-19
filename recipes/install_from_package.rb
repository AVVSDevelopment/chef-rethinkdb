#
# Author:: Vitaly Aminev (v@aminev.me)
# Cookbook Name:: rethinkdb
# Recipe:: install_from_package
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

case node['platform_family']
  when 'debian'    
    repo = 'http://ppa.launchpad.net/rethinkdb/ppa/ubuntu'
    packages = %w{ rethinkdb }  
  
    apt_repository 'rethinkdb' do
      uri repo
      distribution node['lsb']['codename']
      components ['main']
      keyserver "keyserver.ubuntu.com"
      key "11D62AD6"
      action :add    
    end
      
  else
    Chef::Log.error "There are no rethinkdb packages for this platform; please use the source or binary method to install node"
    return
end

packages.each do |pkg|
  
  package "#{pkg}" do
    version "'#{node[pkg]['version']}*'"
    action :install
  end
  
end

