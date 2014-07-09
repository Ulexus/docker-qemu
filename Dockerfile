# QEMU/KVM 
# VERSION 0.2
FROM stackbrew/ubuntu:trusty
MAINTAINER ulexus@gmail.com

RUN apt-get -y update
RUN apt-get -y upgrade

# Install QEMU/KVM
RUN apt-get -y install qemu-kvm

# Install Ceph common utilities/libraries
RUN apt-get -y install ceph-common

# Add entrypoint script
ADD entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
