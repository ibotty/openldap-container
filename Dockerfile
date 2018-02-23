FROM centos:7
LABEL maintainer="Tobias Florek tob@butter.sh"
EXPOSE 33389/tcp


# set env vars that are required by ldapvi
ENV PAGER=more EDITOR=vi HOME=/var/lib/ldap \
    TMPLDIR=/var/lib/openldap-container/templates

RUN set -x \
 && rpmkeys --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 \
 && yum --setopt=tsflags=nodocs -y install epel-release \
 && rpmkeys --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 \
 && yum --setopt=tsflags=nodocs -y install \
        openldap-servers openldap-clients ldapvi gettext \
 && yum clean all \
 && echo '>>> checking slapd uid' \
 && test "$(id -u ldap)" = 55 \
 && echo '>>> fixing permissions' \
 && mkdir /data/ldap/data "$TMPLDIR" -p \
 && mv /etc/openldap /data/ldap/config \
 && rmdir /var/lib/ldap \
 && ln -s /data/ldap/config /etc/openldap \
 && ln -s /data/ldap/data /var/lib/ldap \
 && for d in /data/ldap /var/run; do \
        chmod -R a+rwX "$d"; \
    done

ADD templates /var/lib/openldap-container/templates
ADD bin /usr/libexec/openldap-container

USER 55

ENTRYPOINT [ "/usr/libexec/openldap-container/entrypoint.sh" ]
# log only config messages

VOLUME ["/data/ldap"]
