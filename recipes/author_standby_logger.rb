# Cookbook Name:: aem
# Recipe:: standby_logger

# This recipe installs the Apache Sling Logging Logger that's required for primary and standby instances in the TarMK Cold Standby setup

base_dir = node['aem']['author']['base_dir']
logger_package = "cold-standby-logger-1.0.zip"
logger_package_path = "#{base_dir}/install/#{logger_package}"
file_owner = "crx"
if Chef::Config['solo']
  file_owner = "vagrant"
end

# ensure that the install directory exists
install_dir = "#{base_dir}/install"
directory install_dir do
  owner file_owner 
  group "crx"
  mode "0644"
end

# move logger package into node file systems
cookbook_file logger_package_path do 
  source logger_package
  owner file_owner 
  group "crx"
  mode "0644"
  action :create_if_missing
end

# TODO put this and related values into attributes
install_package_curl = "curl -u admin:#{node['aem']['author']['new_admin_password']} -F file=@\"#{base_dir}/install/#{logger_package}\" -F name=\"cold-standby-logger\" -F force=true -F install=true http://localhost:4502/crx/packmgr/service.jsp"

# execute cURL command
bash "upload and install package" do 
  code install_package_curl
  action :run
end