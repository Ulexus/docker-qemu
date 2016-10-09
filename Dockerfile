# QEMU/KVM 
# VERSION 0.7
FROM ubuntu:xenial
MAINTAINER ulexus@gmail.com

ENV ETCDCTL_VERSION v3.0.12
ENV ETCDCTL_ARCH linux-amd64

RUN apt-get -y update
RUN apt-get -y upgrade

# Install QEMU/KVM
RUN apt-get -y install qemu-kvm

# Install Ceph common utilities/libraries
RUN apt-get -y install ceph-common wget

# Install etcdctl
RUN wget -q -O- "https://github.com/coreos/etcd/releases/download/${ETCDCTL_VERSION}/etcd-${ETCDCTL_VERSION}-${ETCDCTL_ARCH}.tar.gz" |tar xfz - -C/tmp/ etcd-${ETCDCTL_VERSION}-${ETCDCTL_ARCH}/etcdctl
RUN mv /tmp/etcd-${ETCDCTL_VERSION}-${ETCDCTL_ARCH}/etcdctl /usr/local/bin/etcdctl

# Add entrypoint script
ADD entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD []
