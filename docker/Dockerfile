FROM openshift/base-centos7

RUN yum install -y telnet traceroute openssl java-1.8.0-openjdk-devel && yum clean all

COPY startup.sh /sbin/startup.sh
RUN chmod +x /sbin/startup.sh

ENTRYPOINT ["startup.sh"]
