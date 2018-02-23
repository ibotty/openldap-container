#!/bin/bash
# TODO: verify env before envsubst
set -eu
set -o pipefail

LDAP_LISTEN_URIS="${LDAP_LISTEN_URIS-ldap://:33389 ldapi:///}"
LDAP_SYNC_INTERVAL="${LDAP_SYNC_INTERVAL-00:00:30:00}"

generate_config() {
    local ldif

    GID="$(id -g)"
    export GID UID

    case "$1" in
        /*)
            ldif="$1"
            ;;
        *)
            if [ -f "$TMPLDIR/$1" ]; then
                ldif="$TMPLDIR/$1"
            elif [ -f "$TMPLDIR/$1.tmpl" ]; then
                ldif="$TMPLDIR/$1.tmpl"
            else
                log "Template $1 does not exist!"
                exit 1
            fi
            ;;
    esac
    mkdir -p /data/ldap/config /data/ldap/data /etc/openldap/slapd.d
    envsubst < "$ldif" | /usr/sbin/slapadd -b cn=config -F /etc/openldap/slapd.d
}

run() {
    local args

    if [ $# -eq 0 ]; then
        args=(-h "$LDAP_LISTEN_URIS" -d config)
    else
        args=("$@")
    fi
    set -x
    exec /usr/sbin/slapd "${args[@]}"
}

if [ $# -ge 1 ]; then
    case "$1" in
        consumer)
            generate_config simple_consumer
            ;;
        generate_config)
            if [ $# -ge 2 ]; then
                generate_config "$2"
                shift
            else
                log "no config given to generate"
                exit 1
            fi
            ;;
    esac
    shift
fi

run "$@"
