#
# Cookbook Name:: aem
# Recipe:: author_standby
#
# Copyright 2012, Tacit Knowledge, Inc.
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

include_recipe "aem::_base_aem_setup"

# add the standby runmode
node.default[:aem][:author][:jar_opts_runmodes] << 'standby'

# ensure that the install directory exists
install_dir = "#{base_dir}/install"
directory install_dir do
  owner "crx"
  group "crx"
  mode "0644"
end

# add two configuration files for standby
template "#{base_dir}/install/org.apache.jackrabbit.oak.plugins.segment.SegmentNodeStoreService.conf" do
  owner "crx"
  group "crx"
  mode "0644"
  source "segment_node_store_service.conf.erb"
end

template "#{base_dir}/install/org.apache.jackrabbit.oak.plugins.segment.standby.store.StandbyStoreService.config" do
  owner "crx"
  group "crx"
  mode "0644"
  source "standby_store_service.conf.erb"
  variables(
    :persist      => node['aem']['author']['standboy_store_service']['persist'],
    :primary_host => node['aem']['author']['standboy_store_service']['primary_host'],
    :port         => node['aem']['author']['standboy_store_service']['port'],
    :secure       => node['aem']['author']['standboy_store_service']['secure'],
    :interval     => node['aem']['author']['standboy_store_service']['interval']
  )
end

include_recipe "aem::author_base_setup"

# ----------------------------- NOT NEEDED FOR STANDBY ---------------------------------
# #Change admin password
# unless node[:aem][:author][:new_admin_password].nil?
#   aem_user node[:aem][:author][:admin_user] do
#     password node[:aem][:author][:new_admin_password]
#     admin_user node[:aem][:author][:admin_user]
#     admin_password node[:aem][:author][:admin_password]
#     port node[:aem][:author][:port]
#     aem_version node[:aem][:version]
#     action :set_password
#   end
#   node.set[:aem][:author][:admin_password] = node[:aem][:author][:new_admin_password]
# end

# #delete the privileged users from geometrixx, if they're still there.
# node[:aem][:geometrixx_priv_users].each do |user|
#   aem_user user do
#     admin_user node[:aem][:author][:admin_user]
#     admin_password node[:aem][:author][:admin_password]
#     port node[:aem][:author][:port]
#     aem_version node[:aem][:version]
#     path "/home/users/geometrixx"
#     action :remove
#   end
# end

# aem_ldap "author" do
#   options node[:aem][:author][:ldap][:options]
#   action node[:aem][:author][:ldap][:enabled]? :enable : :disable
# end

# if node[:aem][:version].to_f < 5.5 then
#   web_inf_dir = "#{node[:aem][:author][:base_dir]}/server/runtime/0/_crx/WEB-INF"
#   user = node[:aem][:aem_options]["RUNAS_USER"]
#   directory web_inf_dir do
#     owner user
#     group user
#     mode "0755"
#     action :create
#     recursive true
#   end
#   template "#{web_inf_dir}/web.xml" do
#     source "web.xml.erb"
#     owner user
#     group user
#     mode "0644"
#     action :create
#     notifies :restart, "service[aem-author]"
#   end
# end

# #If we're using the aem_package provider to deploy, do it now
# node[:aem][:author][:deploy_pkgs].each do |pkg|
#   aem_package pkg[:name] do
#     version pkg[:version]
#     aem_instance "author"
#     package_url pkg[:url]
#     update pkg[:update]
#     user node[:aem][:author][:admin_user]
#     password node[:aem][:author][:admin_password]
#     port node[:aem][:author][:port]
#     group_id pkg[:group_id]
#     recursive pkg[:recursive]
#     properties_file pkg[:properties_file]
#     version_pattern pkg[:version_pattern]
#     action pkg[:action]
#   end
# end


# #Remove author agents that aren't listed
# aem_replicator "delete_extra_replication_agents" do
#   local_user node[:aem][:author][:admin_user]
#   local_password node[:aem][:author][:admin_password]
#   local_port node[:aem][:author][:port]
#   remote_hosts node[:aem][:author][:replication_hosts]
#   dynamic_cluster node[:aem][:author][:find_replication_hosts_dynamically]
#   cluster_name node[:aem][:cluster_name]
#   cluster_role node[:aem][:publish][:cluster_role]
#   type :agent
#   action :remove
# end

# #Set up author agents
# aem_replicator "create_replication_agents_for_publish_servers" do
#   local_user node[:aem][:author][:admin_user]
#   local_password node[:aem][:author][:admin_password]
#   local_port node[:aem][:author][:port]
#   remote_hosts node[:aem][:author][:replication_hosts]
#   dynamic_cluster node[:aem][:author][:find_replication_hosts_dynamically]
#   cluster_name node[:aem][:cluster_name]
#   cluster_role node[:aem][:publish][:cluster_role]
#   type :agent
#   action :add
# end

# #Set up replication agents
# aem_replicator "replicate_to_publish_servers" do
#   local_user node[:aem][:author][:admin_user]
#   local_password node[:aem][:author][:admin_password]
#   local_port node[:aem][:author][:port]
#   remote_hosts node[:aem][:author][:replication_hosts]
#   dynamic_cluster node[:aem][:author][:find_replication_hosts_dynamically]
#   cluster_name node[:aem][:cluster_name]
#   cluster_role node[:aem][:publish][:cluster_role]
#   type :publish
#   action :add
# end
