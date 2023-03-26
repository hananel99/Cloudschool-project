 consul {
 address = "main.services:8500"
}

log_level = "debug"

# render the role with the new value and re run python application

template {
 source = "/Cloudschool-project/DockerCompose/WorkerInstance/consul-config-app.tpl"
 destination = "/home/bob/myapp/app.conf"
 exec{
   command = "chef-solo -c /Cloudschool-project/Chef/solo.rb -j /Cloudschool-project/Chef/runlist.json --chef-license accept > /var/log/chef-solo.log 2>&1"
   kill_timeout = "10m"
 }
}


