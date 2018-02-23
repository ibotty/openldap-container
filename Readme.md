# Openldap container

This container can be run on openshift using a provided random uid.
Configuration (what is usually in `/etc/openldap`) has to be mounted in `/data/ldap/config`, the data will reside in `/data/ldap/data`.

## Basic Usage

Provide an openldap configuration (/etc/openldap) directory in /data/ldap/config and its (/var/lib/ldap) in /data/ldap/data. Then start the container. It will listen on Port 33389 (or when setting `LDAP_LISTEN_URIS` to these URIs).


## R/o Replicas

Usecase is r/o openldap servers as sidecars without maintaining state on the leader openldap server (provider).

The simple consumer config will set up an openldap server that will replicate the `$LDAP_SYNC_DB_DN` database (e.g. `olcDatabase={1}mdb,cn=config`) and all the provider's schemas.

To set it up, the following environment variables have to be set.

 * `LDAP_SYNC_DB_DN`, the database to replicate,
 * `LDAP_PROVIDER_URI`, the openldap server providing the database,
 * `LDAP_SYNC_BINDDN`, the sync user's bind dn (as configured on the provider),
 * `LDAP_SYNC_PASSWORD`, the sync user's password,
 * `LDAP_SYNC_INTERVAL`, the interval to sync (defaults to "00:00:30:00", half an hour).

## Advanced Replication

Multi-Master and other sophisticated setups will need either a "director" that will prune old state from the leader or will not allow automatic deployment of new followers.
