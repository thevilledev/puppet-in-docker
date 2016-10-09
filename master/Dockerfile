FROM centos:7
MAINTAINER Ville Törhönen <ville@torhonen.fi>

RUN rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
RUN yum -y install puppet-server hostname tar

ADD config/autosign.conf /etc/puppet/autosign.conf
ADD config/puppet.conf /etc/puppet/puppet.conf
RUN mkdir -p /opt/puppet/conf /opt/puppet/var
VOLUME ["/opt/puppet/conf/manifests", "/opt/puppet/conf/modules", "/opt/puppet/conf/hiera"]
ADD config/hiera.yaml /opt/puppet/conf/hiera.yaml
RUN cp -rf /etc/puppet/* /opt/puppet/conf/
RUN cp -rf /var/lib/puppet/* /opt/puppet/var/

EXPOSE 8140
ENTRYPOINT [ "/usr/bin/puppet", "master", "--no-daemonize", "--verbose" ]
