#
# Author:: Vitaly Aminev (v@aminev.me)
# Cookbook Name:: rethinkdb
# Recipe:: install_from_source
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

include_recipe "build-essential"

packages = %w{ protobuf-compiler protobuf-c-compiler libprotobuf-dev libv8-dev libgoogle-perftools-dev make libprotoc-dev default-jre libboost-dev }
packages.each do |dependency|
  package dependency
end
#http://download.rethinkdb.com/dist/rethinkdb-1.4.5.tgz
rethinkdb_tar = "rethinkdb-#{node['nodejs']['version']}.tgz"
rethinkdb_tar_path = rethinkdb_tar

# Let the user override the source url in the attributes
rethinkdb_src_url = "#{node['rethinkdb']['src_url']}/#{rethinkdb_tar_path}"

remote_file "/usr/local/src/#{rethinkdb_tar}" do
  source rethinkdb_src_url
  mode 0644
  action :create_if_missing
end

# --no-same-owner required overcome "Cannot change ownership" bug
# on NFS-mounted filesystem
execute "tar --no-same-owner -zxf #{rethinkdb_tar}" do
  cwd "/usr/local/src"
  creates "/usr/local/src/rethinkdb-#{node['rethinkdb']['version']}"
end

bash "compile rethinkdb (on #{node['rethinkdb']['make_threads']} cpu)" do
# OSX doesn't have the attribute so arbitrarily default 2
  cwd "/usr/local/src/rethinkdb-#{node['rethinkdb']['version']}"
  code <<-EOH
    PATH="/usr/local/bin:$PATH"
    ./configure --prefix=#{node['rethinkdb']['dir']} --allow-fetch && \
    make -j #{node['rethinkdb']['make_threads']}
  EOH
  creates "/usr/local/src/rethinkdb-#{node['rethinkdb']['version']}/rethinkdb"
end

execute "rethinkdb make install" do
  environment({"PATH" => "/usr/local/bin:/usr/bin:/bin:$PATH"})
  command "make install"
  cwd "/usr/local/src/rethinkdb-#{node['rethinkdb']['version']}"
  not_if {::File.exists?("#{node['rethinkdb']['dir']}/bin/rethinkdb") && `#{node['rethinkdb']['dir']}/bin/rethinkdb --version`.chomp == "#{node['rethinkdb']['version']}" }
end