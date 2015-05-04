#
# Cookbook Name:: aem
# Recipe:: author_primary
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

# add the primary runmode
node.default[:aem][:author][:jar_opts_runmodes] << 'primary'

# stop the AEM service
service "aem-author" do
  #init script returns 0 for status no matter what
  status_command "service aem-author status | grep running"
  supports :status => true, :stop => true, :start => true, :restart => true
  action :stop
end

base_dir = node[:aem][:author][:base_dir]

# remove the standby configuration files from crx-quickstart install
node[:aem][:author][:standby_configs].values.each do |config|
  file config do 
    path "#{base_dir}/install/#{config}"
    owner "crx"
    group "crx"
    action :delete
  end
end

include_recipe "aem::author"