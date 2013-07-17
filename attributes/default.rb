#
# Author:: Vitaly Aminev (v@aminev.me)
# Cookbook Name:: rethinkdb
# Attributes:: default
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

default['rethinkdb']['install_method'] = 'package'
default['rethinkdb']['version'] = '1.7.1'
default['rethinkdb']['make_threads'] = node['cpu'] ? node['cpu']['total'].to_i : 1
default['rethinkdb']['src_url'] = "http://download.rethinkdb.com/dist"
default['rethinkdb']['dir'] = "/usr/local"

default['rethinkdb']['instances'] = [  
    {      
      :name  => 'rethinkdb.yb.com',
      :user  => 'rethinkdb',
      :group => 'rethinkdb',
      :address => "all",
      :driverPort => 28015,
      :clusterPort => 29015,
      :portOffset => 0,
      :httpPort => 8080,
      :directory => "/opt/rethinkdb/rethinkdb.yb.com/data"
    }
]

default['rethinkdb']['join_to_cluster'] = false
default['rethinkdb']['bind_to_network_interface'] = false
default['rethinkdb']['network_interface'] = 'eth0'
