#
# Cookbook Name:: aem
# Provider:: init
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

#This provider creates an init script for AEM

action :add do
  vars = {}
  service_name = new_resource.service_name
  var_list = [
    :aem_options, :default_context, :runnable_jar, :base_dir, :jvm_opts, :jar_opts, :jar_opts_runmodes
  ]

  #take value passed to provider, or node attribute
  var_list.each do |var|
    vars[var] = new_resource.send(var) || node[:aem][var]
  end

  vars[:jar_opts] = [get_jar_opts(vars[:jar_opts].dup, vars[:jar_opts_runmodes].dup)]

  template "/etc/init.d/#{service_name}" do
    cookbook 'aem'
    source 'init.erb'
    mode '0755'
    variables(vars)
    notifies :restart, resources(:service => "#{service_name}")
  end
end

# appends runmodes to an existing run_modes jar_opt or creates one if it doesn't exist
def get_jar_opts(jar_opts, jar_opts_runmodes)
  run_modes = jar_opts.select{|jar_opt| jar_opt.include? '-r'}  
  if run_modes.any?
    run_modes_string = run_modes[0]
    run_modes_index = jar_opts.index run_modes_string
    jar_opts_runmodes.each do |jar_opts_runmode|
      run_modes_string << " #{jar_opts_runmode}"
    end
    jar_opts[run_modes_index] = run_modes_string
  else # a jar_opt with 
    jar_opts_string = '-r'
    jar_opts_runmodes.each do |runmode|
      jar_opts_string << " #{runmode}"
    end
    jar_opts << jar_opts_string
  end
end
