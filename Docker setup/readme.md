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
```
