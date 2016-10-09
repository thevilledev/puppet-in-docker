FROM centos:7
MAINTAINER Ville Törhönen <ville@torhonen.fi>

RUN rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
RUN yum -y install puppet hostname
ADD config/puppet.conf /etc/puppet/puppet.conf

CMD ["/usr/bin/puppet", "agent", "--no-daemonize", "--logdest", "console"]
