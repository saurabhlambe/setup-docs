```
[root@c1232-node2 ~]# cat /etc/krb5.conf
# Configuration snippets may be placed in this directory as well
includedir /etc/krb5.conf.d/

[logging]
 default = FILE:/var/log/krb5libs.log
 kdc = FILE:/var/log/krb5kdc.log
 admin_server = FILE:/var/log/kadmind.log

[libdefaults]
 dns_lookup_realm = false
 ticket_lifetime = 24h
 renew_lifetime = 7d
 forwardable = true
 rdns = false
 pkinit_anchors = /etc/pki/tls/certs/ca-bundle.crt
 default_realm = SUP.CLOUDERA.COM
 #default_ccache_name = KEYRING:persistent:%{uid}

[realms]
  SUP.CLOUDERA.COM = {
  kdc = c1232-node1.coelab.cloudera.com
  admin_server = c1232-node1.coelab.cloudera.com
  }
  ENG.CLOUDERA.COM = {
  kdc = c3232-node1.coelab.cloudera.com
  admin_server = c3232-node1.coelab.cloudera.com
  }

[domain_realm]
 .sup.cloudera.com = SUP.CLOUDERA.COM
 sup.cloudera.com = SUP.CLOUDERA.COM
 .eng.cloudera.com = ENG.CLOUDERA.COM
 eng.cloudera.com = ENG.CLOUDERA.COM
 c3232-node1.coelab.cloudera.com = ENG.CLOUDERA.COM
 c3232-node2.coelab.cloudera.com = ENG.CLOUDERA.COM
 c3232-node3.coelab.cloudera.com = ENG.CLOUDERA.COM
 c3232-node4.coelab.cloudera.com = ENG.CLOUDERA.COM

[capaths]
 SUP.CLOUDERA.COM = {
	ENG.CLOUDERA.COM = .
}
```

