# install git
include_recipe 'git'

# install nodejs
node.default['nodejs']['install_method'] = 'binary'  
node.default['nodejs']['version'] = "#{node['nodejs']['version']}"  
node.default['nodejs']['binary']['checksum']['linux_x64'] = "#{node['nodejs']['linux_x64_binary_checksum']}"
include_recipe 'nodejs'
