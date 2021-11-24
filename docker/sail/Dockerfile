FROM ubuntu:focal as build

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install -yq --no-install-recommends git opam zlib1g-dev pkg-config libgmp-dev z3 ocaml-nox m4 rsync ca-certificates
RUN useradd -ms /bin/bash sail

USER sail

RUN opam init --disable-sandboxing -y
RUN opam install -yj$(nproc) sail

WORKDIR /home/sail

RUN git clone --depth=1 --recurse-submodules https://github.com/CTSRD-CHERI/sail-cheri-riscv
RUN cd sail-cheri-riscv && eval $(opam env) && make -j$(nproc) c_emulator/cheri_riscv_sim_RV32 c_emulator/cheri_riscv_sim_RV64

FROM ubuntu:focal

COPY --from=build --chown=0:0 /home/sail/sail-cheri-riscv/c_emulator/ /usr/local/bin

