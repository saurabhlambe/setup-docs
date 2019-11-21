# DataPlane app and DLM app setup

## 1. Install docker
### Remove old versions
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

### Setup the repo
```
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```
### Install Docker engine
```
yum install docker-ce docker-ce-cli containerd.io -y
```
### Start Docker and verify if Docker engine is running
```
systemctl start docker
docker run hello-world
```
