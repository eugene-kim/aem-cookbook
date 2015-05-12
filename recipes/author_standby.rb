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

# stop the AEM service
service "aem-author" do
  supports :status => true, :stop => true, :start => true, :restart => true
  action :stop
end

# add the standby runmode
node.default[:aem][:author][:jar_opts_runmodes] << 'standby'

base_dir = node[:aem][:author][:base_dir]

# # stop the AEM service
# service "aem-author" do
#   supports :status => true, :stop => true, :start => true, :restart => true
#   action :stop
# end

# make sure the install directory is there
directory "#{base_dir}/install" do
  owner "crx"
  group "crx"
  mode "0644"
end

# add two configuration files for standby
# template "#{base_dir}/launchpad/config/org/apache/jackrabbit/oak/plugins/segment/SegmentNodeStoreService.config" do
template "#{base_dir}/install/org.apache.jackrabbit.oak.plugins.segment.SegmentNodeStoreService.config" do
  owner "crx"
  group "crx"
  mode "0644"
  source "segment_node_store_service.config.erb"
end

# template "#{base_dir}/launchpad/config/org/apache/jackrabbit/oak/plugins/segment/standby/store/StandbyStoreService.config" do
template "#{base_dir}/install/org.apache.jackrabbit.oak.plugins.segment.standby.store.StandbyStoreService.config" do
  owner "crx"
  group "crx"
  mode "0644"
  source "standby_store_service.config.erb"
  variables({
    :persist      => node[:aem][:author][:standby_store_service][:persist],
    :primary_host => node[:aem][:author][:standby_store_service][:primary_host],
    :port         => node[:aem][:author][:standby_store_service][:port],
    :secure       => node[:aem][:author][:standby_store_service][:secure],
    :interval     => node[:aem][:author][:standby_store_service][:interval]
  })
end

include_recipe "aem::author_base_setup"

# # restart the AEM service
# service "aem-author" do
#   action :restart
# end

# # stop the AEM service
# service "aem-author" do
#   supports :status => true, :stop => true, :start => true, :restart => true
#   action :stop
# end

# include_recipe "aem::author_base_setup"