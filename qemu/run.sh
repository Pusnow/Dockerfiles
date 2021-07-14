#!/bin/sh

if [ ! -z "$QEMU_RTC" ]; then
    QEMU_RTC_ARG="-rtc base=$QEMU_RTC"
fi

if [ ! -f "$QEMU_DISK" ] && [ ! -z "$QEMU_DISK_INITIALIZE" ]; then
    qemu-img create -f qcow2 $QEMU_DISK $QEMU_DISK_INITIALIZE
fi

if [ ! -f "$QEMU_DISK2" ] && [ ! -z "$QEMU_DISK2_INITIALIZE" ]; then
    qemu-img create -f qcow2 $QEMU_DISK2 $QEMU_DISK2_INITIALIZE
fi

if [ -f "$QEMU_DISK" ] && [ ! -z "$QEMU_DISK" ]; then
    QEMU_DISK_ARG="-drive file=$QEMU_DISK,if=virtio,cache=writeback,cache.direct=on,aio=native,format=qcow2"
fi

if [ -f "$QEMU_DISK2" ] && [ ! -z "$QEMU_DISK2" ]; then
    QEMU_DISK2_ARG="-drive file=$QEMU_DISK2,if=virtio,cache=writeback,cache.direct=on,aio=native,format=qcow2"
fi

if [ -f "$QEMU_ISO" ] && [ ! -z "$QEMU_ISO" ]; then
    QEMU_ISO_ARG="-drive file=$QEMU_ISO,media=cdrom"
fi

if [ -f "$QEMU_ISO2" ] && [ ! -z "$QEMU_ISO2" ]; then
    QEMU_ISO2_ARG="-drive file=$QEMU_ISO2,media=cdrom"
fi

if [ ! -z "$QEMU_MAC" ]; then
    QEMU_MAC_ARGS=",mac=$QEMU_MAC"
fi

QEMU_NET_HOSTFWD=""

if [ ! -z "$QEMU_PORT_1" ]; then
    QEMU_NET_HOSTFWD="$QEMU_NET_HOSTFWD,hostfwd=tcp::$QEMU_PORT_1-:$QEMU_PORT_1,hostfwd=udp::$QEMU_PORT_1-:$QEMU_PORT_1"
fi

if [ ! -z "$QEMU_PORT_2" ]; then
    QEMU_NET_HOSTFWD="$QEMU_NET_HOSTFWD,hostfwd=tcp::$QEMU_PORT_2-:$QEMU_PORT_2,hostfwd=udp::$QEMU_PORT_2-:$QEMU_PORT_2"
fi

if [ ! -z "$QEMU_PORT_3" ]; then
    QEMU_NET_HOSTFWD="$QEMU_NET_HOSTFWD,hostfwd=tcp::$QEMU_PORT_3-:$QEMU_PORT_3,hostfwd=udp::$QEMU_PORT_3-:$QEMU_PORT_3"
fi

if [ ! -z "$QEMU_VHOST" ]; then
    QEMU_VHOST_ARGS=",vhost=$QEMU_VHOST"
fi

if [ ! -z "$QEMU_TAP" ]; then
    QEMU_NET_ARGS="-nic tap,script=no,downscript=no,ifname=$QEMU_TAP,model=virtio-net-pci$QEMU_MAC_ARGS$QEMU_VHOST_ARGS"
else
    QEMU_NET_ARGS="-nic user,model=virtio-net-pci$QEMU_MAC_ARGS$QEMU_NET_HOSTFWD"
fi

if [ ! -z "$QEMU_VNC" ]; then
    QEMU_VNC_ARG="-vnc $QEMU_VNC"
else
    QEMU_VNC_ARG="-vnc 0.0.0.0:0"
fi

qemu-system-x86_64 \
    -machine q35,accel=kvm \
    -cpu host -smp $QEMU_SMP \
    -m $QEMU_MEMORY \
    $QEMU_VNC_ARG \
    $QEMU_RTC_ARG \
    -usb -device usb-tablet \
    -device virtio-keyboard-pci \
    -device virtio-balloon-pci \
    $QEMU_NET_ARGS \
    $QEMU_DISK_ARG \
    $QEMU_DISK2_ARG \
    $QEMU_ISO_ARG \
    $QEMU_ISO2_ARG \
    $QEMU_EXTRA_ARGS
