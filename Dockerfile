FROM centos:7
MAINTAINER Tobias Florek tob@butter.sh

EXPOSE 33389/udp

RUN set -x \
 && rpmkeys --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 \
 && yum --setopt=tsflags=nodocs -y install epel-release \
 && rpmkeys --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 \
 && yum --setopt=tsflags=nodocs -y install openldap-servers ldapvi \
 && yum clean all \
 && echo '>>> checking slapd uid' \
 && test "$(id -u ldap)" = 55 \
 && echo '>>> fixing permissions' \
 && for d in /etc/openldap /var/lib/ldap /var/run; do \
        chmod -R a+rwX "$d"; \
    done

USER 55

# log only config messages
CMD ["/usr/sbin/slapd", "-h", "ldap://:33333/ ldapi:///", "-d", "config"]

VOLUME ["/etc/openldap", "/var/lib/ldap"]
