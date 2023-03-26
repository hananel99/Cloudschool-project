 consul {
 address = "main.services:8500"
}

log_level = "debug"

# render the role with the new value and re run python application

template {
 source = "/CloudSchool-DEVOPS/DockerCompose/WorkerInstance/consul-config-app.tpl"
 destination = "/home/bob/myapp/app.conf"
 exec{
   command = "chef-solo -c /CloudSchool-DEVOPS/Chef/solo.rb -j /CloudSchool-DEVOPS/Chef/runlist.json --chef-license accept > /var/log/chef-solo.log 2>&1"
   kill_timeout = "10m"
 }
}


