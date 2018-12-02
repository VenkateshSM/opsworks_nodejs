search("aws_opsworks_app").each do |app|
    Chef::Log.info("app_id=#{app['app_id']}")
    Chef::Log.info("shortname=#{app['shortname']}")
    Chef::Log.info("app_source.type=#{app['app_source']['type']}")
    Chef::Log.info("app_source.url=#{app['app_source']['url']}")
    Chef::Log.info("app_source.revision=#{app['app_source']['revision']}")
    Chef::Log.info("environment=#{app['environment']}")

    case app['app_source']['type']
    when 'git' then
        git "/opt/#{app['app_id']}" do
            repository "#{app['app_source']['url']}"
            revision "#{app['app_source']['revision']}"
            action :sync
        end
    when 's3' then
        bucket, object = app['app_source']['url'].match('https:\/\/(.+)\.s3\.amazonaws\.com\/(.+)').captures
        s3_cp 'copy s3 to local directory' do
            s3_source "s3://#{bucket}/#{object}"
            s3_destination "/opt/#{app['app_id']}/app.zip"
        end
        zipfile "/opt/#{app['app_id']}/app.zip" do
            into "/opt/#{app['app_id']}"
            overwrite true
        end
    else
        Chef::Application.fatal!("Unexpect app source type")
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
        action :restart
        ignore_failure true
    end

    service "#{app['app_id']}" do
        provider Chef::Provider::Service::Upstart
        action :start
    end
end
