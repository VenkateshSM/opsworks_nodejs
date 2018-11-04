search("aws_opsworks_app").each do |app|
    Chef::Log.info("shortname=#{app['shortname']}")
    Chef::Log.info("app_source.url=#{app['app_source']['url']}")
    Chef::Log.info("app_source.revision=#{app['app_source']['revision']}")
    Chef::Log.info("environment=#{app['environment']}")

    git "/opt/#{app['app_id']}" do
        repository "#{app['app_source']['url']}"
        revision "#{app['app_source']['revision']}"
        action :sync
    end

    execute 'npm prune' do  
        cwd "/opt/#{app['app_id']}"
    end
    
    execute 'npm install' do
        cwd "/opt/#{app['app_id']}"
    end

    template "/etc/init/#{app['app_id']}.conf" do
        source 'app.conf.erb'
        mode '0600'
        variables app: app
    end

    service "#{app['app_id']}" do
        provider Chef::Provider::Service::Upstart
        action :start
    end
end
