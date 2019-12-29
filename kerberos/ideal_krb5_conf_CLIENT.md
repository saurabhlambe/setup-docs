```
[root@c2232-node2 ~]# cat /etc/krb5.conf

[libdefaults]
  renew_lifetime = 7d
  forwardable = true
  default_realm = ENG.COM
  ticket_lifetime = 24h
  dns_lookup_realm = false
  dns_lookup_kdc = false
  #default_ccache_name = /tmp/krb5cc_%{uid}
  #default_tgs_enctypes = aes des3-cbc-sha1 rc4 des-cbc-md5
  #default_tkt_enctypes = aes des3-cbc-sha1 rc4 des-cbc-md5

[logging]
  default = FILE:/var/log/krb5kdc.log
  admin_server = FILE:/var/log/kadmind.log
  kdc = FILE:/var/log/krb5kdc.log

[realms]
  ENG.COM = {
    admin_server = c2232-node1.squadron.support.hortonworks.com
    kdc = c2232-node1.squadron.support.hortonworks.com
    kdc = c2232-node2.squadron.support.hortonworks.com
    kdc = c2232-node3.squadron.support.hortonworks.com
    kdc = c2232-node4.squadron.support.hortonworks.com
  }

  SUP.COM = {
    admin_server = c1232-node1.squadron.support.hortonworks.com
    kdc = c1232-node1.squadron.support.hortonworks.com
    kdc = c1232-node2.squadron.support.hortonworks.com
    kdc = c1232-node3.squadron.support.hortonworks.com
    kdc = c1232-node4.squadron.support.hortonworks.com
}

[capaths]
  ENG.COM = {
	SUP.COM = .
}

[domain_realm]
 .eng.com = ENG.COM
 eng.com = ENG.COM

 c2232-node1.squadron.support.hortonworks.com = ENG.COM
 c2232-node2.squadron.support.hortonworks.com = ENG.COM
 c2232-node3.squadron.support.hortonworks.com = ENG.COM
 c2232-node4.squadron.support.hortonworks.com = ENG.COM
 c1232-node1.squadron.support.hortonworks.com = SUP.COM
 c1232-node2.squadron.support.hortonworks.com = SUP.COM
 c1232-node3.squadron.support.hortonworks.com = SUP.COM
 c1232-node4.squadron.support.hortonworks.com = SUP.COM
```
