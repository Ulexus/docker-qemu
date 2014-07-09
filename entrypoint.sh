#!/bin/bash

# Create the kvm node (required --privileged)
if [ ! -e /dev/kvm ]; then
   mknod /dev/kvm c 10 $(grep '\<kvm\>' /proc/misc | cut -f 1 -d' ')   
fi

# If we have a BRIDGE_IF set, add it to /etc/qemu/bridge.conf
if [ -n "$BRIDGE_IF" ]; then
   echo "allow $BRIDGE_IF" >/etc/qemu/bridge.conf
fi

exec /usr/bin/kvm $@
