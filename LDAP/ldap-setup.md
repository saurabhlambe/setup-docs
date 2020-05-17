# LDAP installation CentOS-7

> References\n
https://simp.readthedocs.io/en/master/getting_started_guide/Just_Install.html\n
https://www.tecmint.com/install-openldap-server-for-centralized-authentication

## I. Install LDAP server

### 1. Install OpenLDAP packages
```bash
yum install -y openldap openldap-servers openldap-clients
```

### 2. Start slapd service
```bash
systemctl start slapd
```

## II. Configure LDAP server

### 1. Set password for admin user
```bash
slappasswd
New password:
Re-enter new password:
{SSHA}Ar1nsZgFrUeql5aWZwvHUXcQ0BaHpO5w
```

### 2. Create LDIF file
```bash
cat ldaprootpasswd.ldif
--
dn: olcDatabase={0}config,cn=config
changetype: modify
add: olcRootPW
olcRootPW: {SSHA}Ar1nsZgFrUeql5aWZwvHUXcQ0BaHpO5w
```
> olcDatabase: indicates a specific database instance name and can be typically found inside /etc/openldap/slapd.d/cn=config.
cn=config: indicates global config options.
PASSWORD: is the hashed string obtained while creating the administrative user.

### 3. Add the corresponding LDAP entry by specifying the URI referring to the ldap server and the file above
```bash
ldapadd -Y EXTERNAL -H ldapi:/// -f ldaprootpasswd.ldif
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
modifying entry "olcDatabase={0}config,cn=config"
```

## III. Configure LDAP database

### 1. Copy the sample database configuration file for slapd into the /var/lib/ldap directory
```bash
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
chown -R ldap:ldap /var/lib/ldap/DB_CONFIG
systemctl restart slapd
```

### 2. Import basic LDAP schemas from /etc/openldap/schema
```bash
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
adding new entry "cn=cosine,cn=schema,cn=config"

ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
adding new entry "cn=nis,cn=schema,cn=config"

ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
adding new entry "cn=inetorgperson,cn=schema,cn=config"
```

### 3. Add your domain in the LDAP database
#### 3.1. Create ldif file
```bash
cat ldapdomain.ldif
--
dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth"
  read by dn.base="cn=admin,dc=ironmaiden,dc=com" read by * none

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=ironmaiden,dc=com

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=admin,dc=ironmaiden,dc=com

dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcRootPW
olcRootPW: {SSHA}Ar1nsZgFrUeql5aWZwvHUXcQ0BaHpO5w

dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcAccess
olcAccess: {0}to attrs=userPassword,shadowLastChange by
  dn="cn=admin,dc=ironmaiden,dc=com" write by anonymous auth by self write by * none
olcAccess: {1}to dn.base="" by * read
olcAccess: {2}to * by dn="cn=admin,dc=ironmaiden,dc=com" write by * read
```
#### 3.2. Add the above configuration to the LDAP database
```bash
ldapmodify -Y EXTERNAL -H ldapi:/// -f ldapdomain.ldif
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
modifying entry "olcDatabase={1}monitor,cn=config"

modifying entry "olcDatabase={2}hdb,cn=config"

modifying entry "olcDatabase={2}hdb,cn=config"

modifying entry "olcDatabase={2}hdb,cn=config"

modifying entry "olcDatabase={2}hdb,cn=config"

```

## IV. Create new users, groups, and user-group mappings

### 1. Add some entries to the LDAP directory
#### 1.1. Create ldif file
```bash
cat baseldapdomain.ldif
--
dn: dc=ironmaiden,dc=com
objectClass: top
objectClass: dcObject
objectclass: organization
o: ironmaiden com
dc: ironmaiden

dn: cn=admin,dc=ironmaiden,dc=com
objectClass: organizationalRole
cn: admin
description: Directory admin

dn: ou=People,dc=ironmaiden,dc=com
objectClass: organizationalUnit
ou: People

dn: ou=Group,dc=ironmaiden,dc=com
objectClass: organizationalUnit
ou: Group
```
#### 1.2. Add above entries to LDAP directory
```bash
ldapadd  -x -D cn=admin,dc=ironmaiden,dc=com -W -f baseldapdomain.ldif
```

### 2. Create a new LDAP user
#### 2.1. Create ldif file
```bash
cat add_user_with_password.ldif
--
dn: uid=lionel,ou=People,dc=ironmaiden,dc=com
uid: lionel
cn: lionel
givenName: Lionel
sn: Messi
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: top
objectClass: shadowAccount
shadowLastChange: 0
shadowMax: 0
shadowWarning: 0
loginShell: /bin/bash
uidNumber: 2003
gidNumber: 1006
homeDirectory: /home/lionel
userPassword: {SSHA}eB9CAYFoQ3YzJ3A49nSgt0udeveEWMoj
```
#### 2.2. Run ldapadd command
```bash
ldapadd -Z -x -W -D "cn=admin,dc=ironmaiden,dc=com" -f add_user_with_passwd.ldif
```

### 3. Create new LDAP group
#### 3.1. Create ldif file
```bash
cat group_add.ldif
--
dn: cn=hr,ou=Group,dc=ironmaiden,dc=com
objectClass: posixGroup
objectClass: top
cn: support
gidNumber: 1008
description: "HR team group"
```
#### 3.2. Push ldif file
```bash
ldapadd -Z -x -W -D "cn=admin,dc=ironmaiden,dc=com" -f add_user_with_passwd.ldif
```

### 4. Add a user to a group
#### 4.1. Create ldif file
```bash
cat group_mod.ldif
--
dn: cn=hr,ou=Group,dc=your,dc=domain
changetype: modify
add: memberUid
memberUid: uid=tom,ou=People,dc=ironmaiden,dc=com
```
#### 4.2. Push changes using ldapmodify command
```bash
ldapmodify -Z -x -W -D "cn=admin,dc=ironmaiden,dc=com" -f group_mod.ldif
```
