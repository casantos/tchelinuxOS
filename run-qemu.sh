#!/bin/sh

hostfwd=;
quiet=;
qemu=;
if [ -x host/bin/qemu-system-x86_64 ]; then
    qemu=host/bin/qemu-system-x86_64;
else
    if [ -x /usr/bin/qemu-system-x86_64 ]; then
        qemu=/usr/bin/qemu-system-x86_64;
    else
        if [ -x /usr/libexec/qemu-kvm ]; then
            qemu=/usr/libexec/qemu-kvm;
        else
            echo "qemu not found" 1>&2;
            return;
        fi;
    fi;
fi;
for opt in "$@";
do
    case "$opt" in 
        --http)
            hostfwd="${hostfwd},hostfwd=tcp:127.0.0.1:8080-:80"
        ;;
        --quiet)
            quiet=" quiet"
        ;;
        --ssh)
            hostfwd="${hostfwd},hostfwd=tcp:127.0.0.1:2222-:22"
        ;;
    esac;
done;
test -f images/bzImage || { 
    echo "images/bzImage is missing" 1>&2;
    return 1
};
test -f images/rootfs.ext2 || { 
    echo "images/rootfs.ext2 is missing" 1>&2;
    return 1
};
$qemu -M pc -m 1024 -kernel "images/bzImage" -drive file=images/rootfs.ext2,if=virtio,format=raw -append "root=/dev/vda console=ttyS0,115200n8 net.ifnames=0${quiet}" -net nic,model=virtio -net "user${hostfwd}" -nographic -enable-kvm -rtc base=utc -device virtio-rng-pci -watchdog i6300esb
