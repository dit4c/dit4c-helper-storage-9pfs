# dit4c-helper-storage-9pfs

DIT4C storage connector based on 9pfs-over-SSH.

For use with [dit4c-fileserver-9pfs][dit4c-fileserver-9pfs].

While version v0.1.0 used `9pfuse` to connect to the server, the current version directly uses the 9p kernel driver for slightly higher performance. While this places a dependency on the kernel to embed 9p, this can be relied upon when using [rkt](https://github.com/coreos/rkt)'s KVM/QEMU stage 1, and you *really* shouldn't be using anything else given that mounting storage requires `--insecure-options=seccomp,paths`.

[dit4c-fileserver-9pfs]: https://github.com/dit4c/dit4c-fileserver-9pfs
