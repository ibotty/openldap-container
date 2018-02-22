# Openldap container

This container can be run on openshift using a provided random uid.
Configuration (what is usually in `/etc/openldap`) has to be mounted in `/data/ldap/config`, the data will reside in `/data/ldap/data`.

## R/o Replicas

Usecase is r/o openldap servers as sidecars without maintaining state on the leader openldap server (provider).

Multi-Master etc will need either a "director" that will prune old state from the leader or will not allow automatic deployment of new followers.

### How to
envsubst < cn=config.ldif.tmpl | slapadd -b cn=config -F /etc/openldap/slapd.d
