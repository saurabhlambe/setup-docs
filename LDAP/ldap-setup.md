https://community.cloudera.com/t5/Community-Articles/How-to-setup-OpenLDAP-2-4-on-CentOS-7/ta-p/249263

===

admin
{SSHA}3RnwgaKrBeM4SHfZ8KIo03uW5EkvMKOw

===

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=field,dc=hortonworks,dc=com

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=ldapadm,dc=field,dc=hortonworks,dc=com

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: {SSHA}3RnwgaKrBeM4SHfZ8KIo03uW5EkvMKOw

===

[root@c2232-node1 ~]# ldapmodify -Y EXTERNAL -H ldapi:/// -f db.ldif
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
modifying entry "olcDatabase={2}hdb,cn=config"

modifying entry "olcDatabase={2}hdb,cn=config"

modifying entry "olcDatabase={2}hdb,cn=config"

===

[root@c2232-node1 ~]# cat monitor.ldif
dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external, cn=auth" read by dn.base="cn=ldapadm,dc=field,dc=hortonworks,dc=com" read by * none

===

[root@c2232-node1 ~]# ldapmodify -Y EXTERNAL -H ldapi:/// -f monitor.ldif
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
modifying entry "olcDatabase={1}monitor,cn=config"

===

[root@c2232-node1 ~]# openssl req -new -x509 -nodes -out /etc/openldap/certs/myldap.field.hortonworks.com.cert -keyout /etc/openldap/certs/myldap.field.hortonworks.com.key -days 365

===

Country Name (2 letter code) [XX]:IN
State or Province Name (full name) []:
Locality Name (eg, city) [Default City]:Bangalore
Organization Name (eg, company) [Default Company Ltd]:Cloudera
Organizational Unit Name (eg, section) []:
Common Name (eg, your name or your server's hostname) []:
Email Address []:

===

chown ldap:ldap /etc/openldap/certs/myldap.field.hortonworks.com.cert
chown ldap:ldap /etc/openldap/certs/myldap.field.hortonworks.com.key

===

[root@c2232-node1 ~]# vim certs.ldif

dn: cn=config
changetype: modify
replace: olcTLSCertificateFile
olcTLSCertificateFile: /etc/openldap/certs/myldap.field.hortonworks.com.cert

dn: cn=config
changetype: modify
replace: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/openldap/certs/myldap.field.hortonworks.com.key

===

[root@c2232-node1 ~]# ldapmodify -Y EXTERNAL -H ldapi:/// -f certs.ldif
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
modifying entry "cn=config"
ldap_modify: Other (e.g., implementation specific) error (80)

===

[root@c2232-node1 ~]# slaptest -u
config file testing succeeded

===

[root@c2232-node1 ~]# cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG

[root@c2232-node1 ~]# chown ldap:ldap /var/lib/ldap/*

===

[root@c2232-node1 ~]# ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
adding new entry "cn=cosine,cn=schema,cn=config"

===

[root@c2232-node1 ~]# ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
adding new entry "cn=nis,cn=schema,cn=config"

===

[root@c2232-node1 ~]# ldapadd  -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
adding new entry "cn=inetorgperson,cn=schema,cn=config"

===

[root@c2232-node1 ~]# cat base.ldif
dn: dc=field,dc=hortonworks,dc=com
dc: field
objectClass: top
objectClass: domain

dn: cn=ldapadm,dc=field,dc=hortonworks,dc=com
objectClass: organizationalRole
cn: ldapadm
description: LDAP Manager

dn: ou=People,dc=field,dc=hortonworks,dc=com
objectClass: organizationalUnit
ou: People

dn: ou=Group,dc=field,dc=hortonworks,dc=com
objectClass: organizationalUnit
ou: Group

===

[root@c2232-node1 ~]# ldapadd -x -W -D "cn=ldapadm,dc=field,dc=hortonworks,dc=com" -f base.ldif
Enter LDAP Password:
adding new entry "dc=field,dc=hortonworks,dc=com"

adding new entry "cn=ldapadm,dc=field,dc=hortonworks,dc=com"

adding new entry "ou=People,dc=field,dc=hortonworks,dc=com"

adding new entry "ou=Group,dc=field,dc=hortonworks,dc=com"

===

ldapsearch -D "cn=ldapadm,dc=field,dc=hortonworks,dc=com" -wadmin -p 389 -h `hostname` -b "dc=field,dc=hortonworks,dc=com"
