## 1. Install packages on Ambari node

```bash
yum install krb5-server krb5-workstation krb5-libs -y
```

---

## 2. Verify the new configuration files that were installed

- krb5.conf
- kdc.conf
- /var/kerberos/krb5/*

---

```bash
[root@c4232-node1 ~]# locate krb5.conf
/etc/krb5.conf
/etc/krb5.conf.d
/var/lib/ambari-server/resources/scripts/krb5.conf

[root@c4232-node1 ~]# locate kdc.conf
/usr/lib/tmpfiles.d/krb5-krb5kdc.conf
/var/kerberos/krb5kdc/kdc.conf

[root@c4232-node1 ~]# ll /var/kerberos/krb5
total 0
drwxr-xr-x. 1 root root 10 Sep 13 18:05 user
[root@c4232-node1 ~]# ll /var/kerberos/krb5
krb5/    krb5kdc/

drwxr-xr-x. 1 root root 10 Sep 13 18:05 user
[root@c4232-node1 ~]# ll /var/kerberos/krb5/user/

total 0
```

---

## 3. Next, lets configure the Kerberos Server (ensure that you read about each config parameter as you do these steps):

#### a. Edit krb5.conf and set the name of your realm, kdc and kadmin hostnames, domain to realm mapping. Find sample krb5.conf here.

```bash
[root@c4232-node1 ~]# cat /etc/krb5.conf

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
 default_realm = SUPPORT.COM
 default_ccache_name = KEYRING:persistent:%{uid}

[realms]
 SUPPORT.COM = {
  kdc = c4232-node1.labs.support.hortonworks.com
  admin_server = c4232-node1.labs.support.hortonworks.com
}

[domain_realm]
 .support.com = SUPPORT.COM

 support.com = SUPPORT.COM
```

---

### b. Edit kdc.conf and set the name of your realm, max tkt lifetime and max renew lifetime. Find sample kdc.conf here.

```bash
# cat /var/kerberos/krb5kdc/kdc.conf

[kdcdefaults]
 kdc_ports = 88
 kdc_tcp_ports = 88

[realms]
 SUPPORT.COM = {

  #master_key_type = aes256-cts

  acl_file = /var/kerberos/krb5kdc/kadm5.acl
  dict_file = /usr/share/dict/words
  admin_keytab = /var/kerberos/krb5kdc/kadm5.keytab
  supported_enctypes = aes256-cts:normal aes128-cts:normal des3-hmac-sha1:normal arcfour-hmac:normal camellia256-cts:normal camellia128-cts:normal des-hmac-sha1:normal des-cbc-md5:normal des-cbc-crc:normal

}
```

### c. Edit kadm5.acl file and set the name of your realm.

```bash
# cat /var/kerberos/krb5kdc/kadm5.acl

*/admin@SUPPORT.COM	*
```

---

### d. Create new Kerberos database using kdb5_util command as follows (password used: 'bigdata'):

```bash
[root@c4232-node1 ~]# kdb5_util -s create
Loading random data
Initializing database '/var/kerberos/krb5kdc/principal' for realm 'SUPPORT.COM',
master key name 'K/M@SUPPORT.COM'
You will be prompted for the database Master Password.
It is important that you NOT FORGET this password.
Enter KDC database master key:

Re-enter KDC database master key to verify:
```

---

### e. Start kdc and kadmin services

```bash
[root@c4232-node1 ~]# krb5kdc
[root@c4232-node1 ~]# kadmind
```

### f. Check how these two services are running as processes (via ps command)

```bash
[root@c4232-node1 ~]# tail -20 /var/log/krb5kdc.log
otp: Loaded
Dec 10 03:15:53 c4232-node1.labs.support.hortonworks.com krb5kdc[758](info): setting up network...
krb5kdc: setsockopt(10,IPV6_V6ONLY,1) worked
krb5kdc: setsockopt(12,IPV6_V6ONLY,1) worked
Dec 10 03:15:53 c4232-node1.labs.support.hortonworks.com krb5kdc[758](info): set up 4 sockets
Dec 10 03:15:53 c4232-node1.labs.support.hortonworks.com krb5kdc[759](info): commencing operation
[root@c4232-node1 ~]# tail -20 /var/log/kadmind.log
Dec 10 03:16:03 c4232-node1.labs.support.hortonworks.com kadmind[761](info): setting up network...
kadmind: setsockopt(10,IPV6_V6ONLY,1) worked
kadmind: setsockopt(12,IPV6_V6ONLY,1) worked
kadmind: setsockopt(14,IPV6_V6ONLY,1) worked
Dec 10 03:16:03 c4232-node1.labs.support.hortonworks.com kadmind[761](info): set up 6 sockets
Dec 10 03:16:03 c4232-node1.labs.support.hortonworks.com kadmind[762](info): Seeding random number generator

Dec 10 03:16:03 c4232-node1.labs.support.hortonworks.com kadmind[762](info): starting
---

[root@c4232-node1 ~]# ps -ef | grep krb5kdc
root         759       1  0 03:15 ?        00:00:00 krb5kdc
root         779     413  0 03:18 pts/0    00:00:00 grep --color=auto krb5kdc
[root@c4232-node1 ~]# date
Tue Dec 10 03:18:18 UTC 2019
[root@c4232-node1 ~]# ps -ef | grep kadmin
root         762       1  0 03:16 ?        00:00:00 kadmind

root         783     413  0 03:18 pts/0    00:00:00 grep --color=auto kadmin
```

---

## 4. With the Kerberos Server in place and configured correctly, lets go ahead and create a few principals:

https://web.mit.edu/kerberos/krb5-1.12/doc/admin/database.html#add-mod-del-princs

### a. Use kadmin.local interface on KDC server locally or kadmin interface via any remote node to create principals.

```bash
[root@c4232-node1 ~]# kadmin.local
Authenticating as principal root/admin@SUPPORT.COM with password.

kadmin.local:
```

---

### b. Create these principals with password “kerberos101”:

- admin/admin 
- your short username (e.g. vrathor) 
- knox/<node2-fqdn>

```bash
kadmin.local:  addprinc admin/admin
WARNING: no policy specified for admin/admin@SUPPORT.COM; defaulting to no policy
Enter password for principal "admin/admin@SUPPORT.COM":
Re-enter password for principal "admin/admin@SUPPORT.COM":
Principal "admin/admin@SUPPORT.COM" created.

kadmin.local:  addprinc slambe
WARNING: no policy specified for slambe@SUPPORT.COM; defaulting to no policy
Enter password for principal "slambe@SUPPORT.COM":
Re-enter password for principal "slambe@SUPPORT.COM":
Principal "slambe@SUPPORT.COM" created.

[root@c4232-node1 ~]# kadmin.local
Authenticating as principal root/admin@SUPPORT.COM with password.
kadmin.local:  addprinc knox/c4232-node2.labs.support.hortonworks.com
WARNING: no policy specified for knox/c4232-node2.labs.support.hortonworks.com@SUPPORT.COM; defaulting to no policy
Enter password for principal "knox/c4232-node2.labs.support.hortonworks.com@SUPPORT.COM":
Re-enter password for principal "knox/c4232-node2.labs.support.hortonworks.com@SUPPORT.COM":

Principal "knox/c4232-node2.labs.support.hortonworks.com@SUPPORT.COM" created.
```

---

### c. Check if you can get TGT for admin/admin principal and your user principal by using kinit command.

```bash
[root@c4232-node1 ~]# kinit admin/admin
Password for admin/admin@SUPPORT.COM:
[root@c4232-node1 ~]# klist
Ticket cache: FILE:/tmp/krb5cc_0
Default principal: admin/admin@SUPPORT.COM

Valid starting     Expires            Service principal

12/10/19 03:37:10  12/11/19 03:37:10  krbtgt/SUPPORT.COM@SUPPORT.COM
```

**Debug Note** : It is very vital to understand what happens behind the scene when you run kinit command. Export the following environment variable to enable Kerberos debug and observe the output that it generates:

```bash
[root@c4232-node1 ~]# export KRB5_TRACE=/tmp/kinit.log
[root@c4232-node1 ~]# kinit admin/admin

Password for admin/admin@SUPPORT.COM:
---

[927] 1575949458.437445: Destroying ccache FILE:/tmp/krb5cc_0
[929] 1575949463.359553: Getting initial credentials for admin/admin@SUPPORT.COM
[929] 1575949463.359555: Sending unauthenticated request
[929] 1575949463.359556: Sending request (197 bytes) to SUPPORT.COM
[929] 1575949463.359557: Resolving hostname c4232-node1.labs.support.hortonworks.com
[929] 1575949463.359558: Sending initial UDP request to dgram 172.25.35.1:88
[929] 1575949463.359559: Received answer (726 bytes) from dgram 172.25.35.1:88
[929] 1575949463.359560: Response was not from master KDC
[929] 1575949463.359561: Processing preauth types: PA-ETYPE-INFO2 (19)
[929] 1575949463.359562: Selected etype info: etype aes256-cts, salt "SUPPORT.COMadminadmin", params ""
[929] 1575949463.359563: Produced preauth for next request: (empty)
[929] 1575949463.359564: Getting AS key, salt "SUPPORT.COMadminadmin", params ""
[929] 1575949487.548688: AS key obtained from gak_fct: aes256-cts/F028
[929] 1575949487.548689: Decrypted AS reply; session key is: aes256-cts/9C80
[929] 1575949487.548690: FAST negotiation: available
[929] 1575949487.548691: Initializing FILE:/tmp/krb5cc_0 with default princ admin/admin@SUPPORT.COM
[929] 1575949487.548692: Storing admin/admin@SUPPORT.COM -> krbtgt/SUPPORT.COM@SUPPORT.COM in FILE:/tmp/krb5cc_0
[929] 1575949487.548693: Storing config in FILE:/tmp/krb5cc_0 for krbtgt/SUPPORT.COM@SUPPORT.COM: fast_avail: yes
[929] 1575949487.548694: Storing admin/admin@SUPPORT.COM -> krb5_ccache_conf_data/fast_avail/krbtgt\/SUPPORT.COM\@SUPPORT.COM@X-CACHECONF: in FILE:/tmp/krb5cc_0

/tmp/kinit.log (END)
```

---

## 5. Another important artifact in Kerberos setup is a Keytab. Keytabs are nothing but keys of principals stored on a binary file on disk. Hence keytabs become a secret that needs to be protected at all costs. Next, lets create and use keytabs:

### a. On KDC, generate keytab for knox/<node2-fqdn> principal by name knox.keytab

```bash
[root@c4232-node1 ~]# kadmin
Authenticating as principal admin/admin@SUPPORT.COM with password.
Password for admin/admin@SUPPORT.COM:

kadmin:  ktadd -k knox.keytab knox/c4232-node2.labs.support.hortonworks.com
Entry for principal knox/c4232-node2.labs.support.hortonworks.com with kvno 4, encryption type aes256-cts-hmac-sha1-96 added to keytab WRFILE:knox.keytab.
Entry for principal knox/c4232-node2.labs.support.hortonworks.com with kvno 4, encryption type aes128-cts-hmac-sha1-96 added to keytab WRFILE:knox.keytab.
Entry for principal knox/c4232-node2.labs.support.hortonworks.com with kvno 4, encryption type des3-cbc-sha1 added to keytab WRFILE:knox.keytab.
Entry for principal knox/c4232-node2.labs.support.hortonworks.com with kvno 4, encryption type arcfour-hmac added to keytab WRFILE:knox.keytab.
Entry for principal knox/c4232-node2.labs.support.hortonworks.com with kvno 4, encryption type camellia256-cts-cmac added to keytab WRFILE:knox.keytab.
Entry for principal knox/c4232-node2.labs.support.hortonworks.com with kvno 4, encryption type camellia128-cts-cmac added to keytab WRFILE:knox.keytab.
Entry for principal knox/c4232-node2.labs.support.hortonworks.com with kvno 4, encryption type des-hmac-sha1 added to keytab WRFILE:knox.keytab.

Entry for principal knox/c4232-node2.labs.support.hortonworks.com with kvno 4, encryption type des-cbc-md5 added to keytab WRFILE:knox.keytab.
```

---

### b. Copy knox.keytab to node2

```bash
[root@c4232-node1 ~]# scp knox.keytab c4232-node2.labs.support.hortonworks.com@SUPPORT.COM:/
```

---

### c. Try listing the keytab entries using klist -kte command:

```bash
[root@c4232-node1 ~]# klist -kte knox.keytab
Keytab name: FILE:knox.keytab
KVNO Timestamp         Principal

---- ----------------- --------------------------------------------------------

   4 12/10/19 04:12:11 knox/c4232-node2.labs.support.hortonworks.com@SUPPORT.COM (aes256-cts-hmac-sha1-96)
   4 12/10/19 04:12:11 knox/c4232-node2.labs.support.hortonworks.com@SUPPORT.COM (aes128-cts-hmac-sha1-96)
   4 12/10/19 04:12:11 knox/c4232-node2.labs.support.hortonworks.com@SUPPORT.COM (des3-cbc-sha1)
   4 12/10/19 04:12:11 knox/c4232-node2.labs.support.hortonworks.com@SUPPORT.COM (arcfour-hmac)
   4 12/10/19 04:12:11 knox/c4232-node2.labs.support.hortonworks.com@SUPPORT.COM (camellia256-cts-cmac)
   4 12/10/19 04:12:11 knox/c4232-node2.labs.support.hortonworks.com@SUPPORT.COM (camellia128-cts-cmac)
   4 12/10/19 04:12:11 knox/c4232-node2.labs.support.hortonworks.com@SUPPORT.COM (des-hmac-sha1)
   4 12/10/19 04:12:11 knox/c4232-node2.labs.support.hortonworks.com@SUPPORT.COM (des-cbc-md5)

[root@c4232-node1 ~]# klist -kt knox.keytab
Keytab name: FILE:knox.keytab
KVNO Timestamp         Principal

---- ----------------- --------------------------------------------------------

  4 12/10/19 04:12:11 knox/c4232-node2.labs.support.hortonworks.com@SUPPORT.COM
  4 12/10/19 04:12:11 knox/c4232-node2.labs.support.hortonworks.com@SUPPORT.COM
  4 12/10/19 04:12:11 knox/c4232-node2.labs.support.hortonworks.com@SUPPORT.COM
  4 12/10/19 04:12:11 knox/c4232-node2.labs.support.hortonworks.com@SUPPORT.COM
  4 12/10/19 04:12:11 knox/c4232-node2.labs.support.hortonworks.com@SUPPORT.COM
  4 12/10/19 04:12:11 knox/c4232-node2.labs.support.hortonworks.com@SUPPORT.COM
  4 12/10/19 04:12:11 knox/c4232-node2.labs.support.hortonworks.com@SUPPORT.COM

  4 12/10/19 04:12:11 knox/c4232-node2.labs.support.hortonworks.com@SUPPORT.COM
```

---

## 4. To test a keytab file for correctness, try to get a TGT for knox service principal by using the new keytab:

---

```bash
[root@c4232-node1 ~]# kinit -kt knox.keytab knox/c4232-node2.labs.support.hortonworks.com

[root@c4232-node1 ~]# klist
Ticket cache: FILE:/tmp/krb5cc_0
Default principal: knox/c4232-node2.labs.support.hortonworks.com@SUPPORT.COM

Valid starting     Expires            Service principal

12/10/19 04:17:11  12/11/19 04:17:11  krbtgt/SUPPORT.COM@SUPPORT.COM
```

---

## 5. If you are able to get a TGT without any error, then keytab is good & valid.

## 6. While troubleshooting a Kerberos issue, there are times when you need to ensure that whether a user is able to get a service ticket (TGS) for a service principal or not. You can use kvno command to test a TGS request.

```bash
[root@c4232-node1 ~]# kvno admin/admin
admin/admin@SUPPORT.COM: kvno = 1
[root@c4232-node1 ~]# kvno knox/c4232-node2.labs.support.hortonworks.com
knox/c4232-node2.labs.support.hortonworks.com@SUPPORT.COM: kvno = 4
```
