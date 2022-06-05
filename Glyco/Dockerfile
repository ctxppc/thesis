# ================================
# CHERI-LLVM build image
# ================================
FROM ubuntu:focal as llvm

# Install updates & dependencies.
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -qy dist-upgrade \
	&& apt install -qy git autoconf automake libtool pkg-config clang bison cmake ninja-build samba flex texinfo libglib2.0-dev libpixman-1-dev libarchive-dev libarchive-tools libbz2-dev libattr1-dev libcap-ng-dev \
    && rm -rf /var/lib/apt/lists/*

# Create a builder user and group with /builder as its home directory. cheribuild refuses to build as root.
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /builder builder

# Ensure all further commands run as the builder user.
USER builder:builder

# Retrieve toolchain.
WORKDIR /builder
RUN git clone --recurse-submodules https://github.com/CTSRD-CHERI/cheribuild.git

# Build toolchain.
WORKDIR /builder/cheribuild
RUN ./cheribuild.py llvm-native -d

# ================================
# Sail build image
# ================================
FROM ubuntu:focal as sail

# Install updates & dependencies.
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -qy dist-upgrade \
	&& apt install -qy git opam zlib1g-dev pkg-config libgmp-dev z3 \
    && rm -rf /var/lib/apt/lists/* \
	&& opam init --disable-sandboxing -y \
	&& opam install -y sail

# Retrieve emulator repository.
WORKDIR /
RUN git clone --recurse-submodules https://github.com/CTSRD-CHERI/sail-cheri-riscv

# Build emulator.
WORKDIR /sail-cheri-riscv
RUN eval $(opam env) && make c_emulator/cheri_riscv_sim_RV64

# Prepare staging area.
RUN mkdir /staging

# Copy product to staging area.
RUN cp /sail-cheri-riscv/c_emulator/cheri_riscv_sim_RV64 /staging/cheri_riscv_sim_RV64

# ================================
# Glyco build image
# ================================
FROM swift:5.5.3-focal as glyco

# Install updates & dependencies.
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && rm -rf /var/lib/apt/lists/*

# Set up a build area for Glyco.
WORKDIR /build

# Resolve dependencies.
# This cached layer can be reused as long as Package.swift and Package.resolved do not change.
COPY ./Package.* ./
RUN swift package resolve

# Copy repository into container.
COPY . .

# Build everything.
RUN swift build -c release -Xswiftc -static-executable

# Prepare staging area.
RUN mkdir /staging

# Copy product to staging area.
RUN cp "$(swift build -c release --show-bin-path)/glyco" /staging/glyco

# ================================
# Run & test image
# ================================
FROM swift:5.5.3-focal

# Install updates & dependencies.
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && \
    apt-get -q update && apt-get -qy dist-upgrade \
    && rm -rf /var/lib/apt/lists/*

# Copy repository into container (to enable testing).
WORKDIR /glyco
COPY . .

# Copy products from build images.
COPY --from=llvm /builder/cheri /cheri
COPY --from=sail /staging /sail
COPY --from=glyco /staging /glyco

# Define environment.
ENV CHERITOOLCHAIN="/cheri"
ENV SIMULATOR="/sail/cheri_riscv_sim_RV64"

# Define entrypoint.
ENTRYPOINT ["/glyco/glyco"]
