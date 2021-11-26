FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -yq --no-install-recommends \
  ca-certificates git make patch ssh-client xz-utils \
  autoconf automake libtool pkg-config clang bison cmake ninja-build samba flex texinfo libglib2.0-dev libpixman-1-dev libarchive-dev libarchive-tools libbz2-dev libattr1-dev libcap-ng-dev

RUN useradd -ms /bin/bash cheri

USER cheri
WORKDIR /home/cheri
RUN git clone --depth=1 https://github.com/CTSRD-CHERI/cheribuild.git

WORKDIR /home/cheri/cheribuild
RUN ./cheribuild.py -vv -j$(nproc) llvm
RUN ./cheribuild.py -vv -j$(nproc) qemu

ADD --chown=cheri:cheri extra-files/ /home/cheri/cheri/extra-files/
RUN ./cheribuild.py -vv -j$(nproc) cheribsd-riscv64-purecap
RUN ./cheribuild.py -vv -j$(nproc) disk-image-riscv64-purecap
RUN /home/cheri/cheri/output/sdk/bin/qemu-img convert -c -f raw -O qcow2 /home/cheri/cheri/output/cheribsd-riscv64-purecap.img /home/cheri/cheri/output/cheribsd-riscv64-purecap.qcow2
RUN /home/cheri/cheri/output/sdk/bin/qemu-img info /home/cheri/cheri/output/cheribsd-riscv64-purecap.qcow2

FROM ctsrd/qemu-cheri
WORKDIR /home/cheri
COPY --from=0 /home/cheri/cheri/output/cheribsd-riscv64-purecap.qcow2 .
COPY --from=0 /home/cheri/cheri/output/rootfs-riscv64-purecap/boot/kernel/kernel .

CMD \
  /opt/cheri/output/sdk/bin/qemu-system-riscv64cheri -M virt -m 2048 -nographic \
  -bios bbl-riscv64cheri-virt-fw_jump.bin \
  -kernel kernel \
  -drive if=none,file=cheribsd-riscv64-purecap.qcow2,id=drv,format=qcow2 \
  -device virtio-blk-device,drive=drv -device virtio-net-device,netdev=net0 \
  -netdev 'user,id=net0,hostfwd=tcp::10022-:22' -device virtio-rng-pci
EXPOSE 10022
