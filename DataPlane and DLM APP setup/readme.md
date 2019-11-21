# Docker installation and setup
## Remove old versions
```
yum remove docker \
       docker-client \
       docker-client-latest \
       docker-common \
       docker-latest \
       docker-latest-logrotate \
       docker-logrotate \
       docker-engine
```

## Setup the repo
```
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```
## Install Docker engine
```
yum install docker-ce docker-ce-cli containerd.io -y
```
## Start Docker and verify if Docker engine is running
```
systemctl start docker
docker run hello-world
```

# Uninstall Docker
## Remove Docker package
```
yum remove docker-ce
```
## Remove Docker dir
```
rm -rf /var/lib/docker
```
