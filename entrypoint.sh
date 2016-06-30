#!/bin/bash
set -e

# Function for extracting keys from etcdctl if they exist
# sets getKeyReturn to value of requested key (or "" if it doesn't exist)
function getKey() {
   getKeyReturn=""
   if [ -n $1 ]; then
      val=$(etcdctl get $1)
      if [ $? -eq 0 ]; then
         getKeyReturn=$val
      fi
   fi
   return
}

# Create the kvm node (required --privileged)
if [ ! -e /dev/kvm ]; then
   set +e
   mknod /dev/kvm c 10 $(grep '\<kvm\>' /proc/misc | cut -f 1 -d' ')   
   set -e
fi

# If we have a BRIDGE_IF set, add it to /etc/qemu/bridge.conf
if [ -n "$BRIDGE_IF" ]; then
   if [ -e /etc/qemu/bridge.conf ]; then
      echo "allow $BRIDGE_IF" >/etc/qemu/bridge.conf
   fi

   # Make sure we have the tun device node
   if [ ! -e /dev/net/tun ]; then
      set +e
      mkdir -p /dev/net
      mknod /dev/net/tun c 10 $(grep '\<tun\>' /proc/misc | cut -f 1 -d' ')
      set -e
   fi
fi

# If we were given arguments, override the default configuration
if [ $# -gt 0 ]; then
   exec /usr/bin/kvm $@
   exit $?  # Make sure we really exit
fi

# Get configuration from etcd
VM_RAM=${VM_RAM:-$(getKey /kvm/${INSTANCE}/ram; echo $getKeyReturn)}
VM_MAC=${VM_MAC:-$(getKey /kvm/${INSTANCE}/mac; echo $getKeyReturn)}
VM_RBD=${VM_RBD:-$(getKey /kvm/${INSTANCE}/rbd; echo $getKeyReturn)}
SPICE_PORT=${SPICE_PORT:-$(getKey /kvm/${INSTANCE}/spice_port; echo $getKeyReturn)}
EXTRA_FLAGS=${EXTRA_FLAGS:-$(getKey /kvm/${INSTANCE}/extra_flags; echo $getKeyReturn)}

# If we do not have the host lock, abort
if [ ${HOSTNAME} != $(etcdctl get /kvm/${INSTANCE}/host) ]; then
   echo "We do not have a host lock; aborting"
   exit 1
fi

# Execute with default settings
exec /usr/bin/kvm -vga qxl -spice port=${SPICE_PORT},addr=127.0.0.1,disable-ticketing \
   -k en-us -m ${VM_RAM} -cpu qemu64 \
   -netdev bridge,br=${BRIDGE_IF},id=net0 -device virtio-net,netdev=net0,mac=${VM_MAC} \
   -drive format=rbd,file=rbd:${VM_RBD},cache=writeback,if=virtio ${EXTRA_FLAGS}
