# vmware Harbor Registry

## 开始部署

- 安装docker

    	curl -sSL https://get.docker.io | bash
    	cat >/etc/docker/demon.json <<EOF
    	{
    	  "insecure-registries": ["172.16.1.8", "reg.kolla-openstack.com", "172.16.11.8"]
    	}
    	EOF
    
    	systemctl restart docker
    	systemctl enable docker 

- 安装配置harbor

    	cd /opt ;wget https://storage.googleapis.com/harbor-releases/release-1.8.0/harbor-offline-installer-v1.8.1.tgz
    	tar -xf harbor-offline-installer-v1.8.1.tgz

    	cat > harbor/harbor.yml <<EOF 
    	hostname: reg.kolla-openstack.com
    	http:
    	  port: 80
    	harbor_admin_password: openstack
    	database:
    	  password: openstack
    	data_volume: /data
    	clair: 
    	  updaters_interval: 12
    	  http_proxy:
    	  https_proxy:
    	  no_proxy: 127.0.0.1,localhost,core,registry
    	jobservice:
    	  max_job_workers: 10
    	chart:
    	  absolute_url: disabled
    	log:
    	  level: info
    	  rotate_count: 50
    	  rotate_size: 200M
    	  location: /var/log/harbor
    	_version: 1.8.0
    	EOF
    	 
    	bash harbor/install.sh 

- 安装完毕
  
    	[root@harbor harbor]# docker ps
		CONTAINER ID        IMAGE                                               COMMAND                  CREATED             STATUS                       PORTS                       NAMES
		a5f116e6867b        goharbor/nginx-photon:v1.8.1                        "nginx -g 'daemon of…"   About an hour ago   Up About an hour (healthy)   0.0.0.0:80->80/tcp          nginx
		4a14daafa379        goharbor/harbor-jobservice:v1.8.1                   "/harbor/start.sh"       About an hour ago   Up About an hour                                         harbor-jobservice
		1d47312ac0e5        goharbor/harbor-portal:v1.8.1                       "nginx -g 'daemon of…"   About an hour ago   Up About an hour (healthy)   80/tcp                      harbor-portal
		9dcf07240b92        goharbor/harbor-core:v1.8.1                         "/harbor/start.sh"       About an hour ago   Up About an hour (healthy)                               harbor-core
		55e55b3b5117        goharbor/redis-photon:v1.8.1                        "docker-entrypoint.s…"   About an hour ago   Up About an hour             6379/tcp                    redis
		4902fced9b30        goharbor/harbor-registryctl:v1.8.1                  "/harbor/start.sh"       About an hour ago   Up About an hour (healthy)                               registryctl
		a99b771a90e8        goharbor/registry-photon:v2.7.1-patch-2819-v1.8.1   "/entrypoint.sh /etc…"   About an hour ago   Up About an hour (healthy)   5000/tcp                    registry
		6482070d7d1b        goharbor/harbor-db:v1.8.1                           "/entrypoint.sh post…"   About an hour ago   Up About an hour (healthy)   5432/tcp                    harbor-db
		ad7f49c698cf        goharbor/harbor-log:v1.8.1                          "/bin/sh -c /usr/loc…"   About an hour ago   Up About an hour (healthy)   127.0.0.1:1514->10514/tcp   harbor-log
		[root@harbor harbor]# docker-compose restart # 重启
		[root@harbor harbor]# docker-compose up -d # 启动
		[root@harbor harbor]# docker-compose down #关闭


- login dashboard
    	[登入harbor](http://reg.kolla-openstack.com/)
# 同步私有仓库地址

         ansible -i /opt/kolla-ansible/ansible/inventory/multinode all  -m copy -a "src=/etc/docker/daemon.json dest=/etc/docker/daemon.json"
         ansible -i /opt/kolla-ansible/ansible/inventory/multinode all  -m service -a "name=docker state=restarted"
         
         cat /etc/kolla/globals.yml
            docker_registry: "reg.kolla-openstack.com"
            docker_namespace: "kolla"
            #docker_registry_username: "sam"
            #docker_registry_password: "correcthorsebatterystaple"



# 清理镜像释放空间
```
$ docker-compose stop

$ docker run -it --name gc --rm --volumes-from registry vmware/registry:2.6.2-photon garbage-collect --dry-run /etc/registry/config.yml

$ docker run -it --name gc --rm --volumes-from registry vmware/registry:2.6.2-photon garbage-collect  /etc/registry/config.yml

$ docker-compose start
```
