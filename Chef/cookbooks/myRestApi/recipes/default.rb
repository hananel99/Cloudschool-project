#
# Cookbook:: myRestApi
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.

apt_update
package 'python3'
package 'python3-pip'
package 'pkg-config'
package 'build-essential'
package 'libssl-dev'
package 'libffi-dev'
package 'libgirepository1.0-dev'
package 'libmysqlclient-dev'
package 'git'
package 'gunicorn'
package 'nginx'

user 'bob' do
  uid 1212
  gid 'users'
  home '/home/bob'
  manage_home true
  shell '/bin/bash'
  password '$1$alilbito$C83FsODuq0A1pUMeFPeR10'
  action [:create, :modify]
end

directory "/home/bob/myapp" do
  owner 'bob'
  group 'users'
  mode '0755'
  action :create
end

git "/home/bob/myapp" do
  repository "git://github.com/EliranKasif/CloudSchool-PythonRestApi.git"
  revision "main"
  retries 3
  user 'bob'
  action :sync
end

execute 'install python dependencies' do
  command 'pip3 install -r requirements.txt'
  cwd '/home/bob/myapp'
end

systemd_unit 'consul.service' do
  content({
  Unit: {
    Description: 'Consul template service',
    After: 'network.target',
  },
  Service: {
    ExecStart: '/usr/local/bin/consul-template -config consul-config.hcl',
    User: 'root',
    Group: 'root',
    WorkingDirectory: '/CloudSchool-DEVOPS/DockerCompose/WorkerInstance/',
    Restart: 'always'
  },
  Install: {
    WantedBy: 'multi-user.target',
  }
  })
  action [:create, :enable, :start]
end

systemd_unit 'gunicorn.service' do
  content({
  Unit: {
    Description: 'Flask on Gunicorn',
    After: 'network.target',
  },
  Service: {
    ExecStart: 'gunicorn --workers 1 --bind localhost:5000 app:app',
    User: 'bob',
    Group: 'www-data',
    WorkingDirectory: '/home/bob/myapp',
    Restart: 'always'
  },
  Install: {
    WantedBy: 'multi-user.target',
  }
  })
  action [:create, :enable, :start, :reload_or_restart]
end

template '/etc/nginx/sites-available/default' do
  source 'nginx.conf.erb'
  owner 'root'
  group 'root'
  mode '0744'
  action :create
end

link '/etc/nginx/sites-enabled/default' do
  to '/etc/nginx/sites-available/default'
end

service 'nginx' do
  action [:enable, :start, :restart]

end

