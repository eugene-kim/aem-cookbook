#
# Cookbook Name:: aem
# Recipe:: base_author_setup
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

unless node[:aem][:use_yum]
  aem_jar_installer "author" do
    download_url node[:aem][:download_url]
    default_context node[:aem][:author][:default_context]
    port node[:aem][:author][:port]
    action :install
  end
end

unless node[:aem][:license_url].nil?
  remote_file "#{node[:aem][:author][:default_context]}/license.properties" do
    source "#{node[:aem][:license_url]}"
    mode 0644
  end
end

if node[:aem][:version].to_f > 5.4 then
  node.set[:aem][:author][:runnable_jar] = "aem-author-p#{node[:aem][:author][:port]}.jar"
end

aem_init "aem-author" do
  service_name "aem-author"
  default_context node[:aem][:author][:default_context]
  runnable_jar node[:aem][:author][:runnable_jar]
  base_dir node[:aem][:author][:base_dir]
  jvm_opts node[:aem][:author][:jvm_opts]
  jar_opts node[:aem][:author][:jar_opts]
  jar_opts_runmodes node[:aem][:author][:jar_opts_runmodes]
  action :add
end

service "aem-author" do
  #init script returns 0 for status no matter what
  status_command "service aem-author status | grep running"
  supports :status => true, :stop => true, :start => true, :restart => true
  action [ :enable, :start ]
end

if node[:aem][:version].to_f > 5.4
  node[:aem][:author][:validation_urls].each do |url|
    aem_url_watcher url do
      validation_url url
      status_command "service aem-author status | grep running"
      max_attempts node[:aem][:author][:startup][:max_attempts]
      wait_between_attempts node[:aem][:author][:startup][:wait_between_attempts]
      user node[:aem][:author][:admin_user]
      password node[:aem][:author][:admin_password]
      action :wait
    end
  end
else
  aem_port_watcher "4502" do
    status_command "service aem-author status | grep running"
    action :wait
  end
end