# install dependencies
include_recipe 'git'

execute 'symbolic link to awscli expected by s3_cli' do
    command "ln -s /usr/bin/aws /usr/local/bin/aws"
    not_if { ::File.exist?("/usr/local/bin/aws") }
end

# install nodejs
node.default['nodejs']['install_method'] = 'binary'  
node.default['nodejs']['version'] = "#{node['nodejs']['version']}"  
node.default['nodejs']['binary']['checksum']['linux_x64'] = "#{node['nodejs']['linux_x64_binary_checksum']}"
include_recipe 'nodejs'
