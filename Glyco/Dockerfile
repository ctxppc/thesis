# ================================
# Build image
# ================================
FROM swift:5.5.3-focal as build

# Install updates & dependencies.
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
	&& apt install -qy opam zlib1g-dev pkg-config libgmp-dev z3 \
    && rm -rf /var/lib/apt/lists/* \
	&& opam init --disable-sandboxing -y \
	&& opam install -y sail

# Retrieve the emulator.
WORKDIR /
RUN git clone --recurse-submodules https://github.com/CTSRD-CHERI/sail-cheri-riscv

# Build the emulator.
WORKDIR /sail-cheri-riscv
RUN eval $(opam env) && make c_emulator/cheri_riscv_sim_RV64

# Set up a build area for Glyco.
WORKDIR /build

# Resolve dependencies.
# This cached layer can be reused as long as Package.swift and Package.resolved do not change.
COPY ./Package.* ./
RUN swift package resolve

# Copy entire repo into container.
COPY . .

# Build everything.
RUN swift build -c release -Xswiftc -static-executable

# Prepare staging area.
RUN mkdir /staging

# Copy products to staging area.
RUN cp /sail-cheri-riscv/c_emulator/cheri_riscv_sim_RV64 /staging/cheri_riscv_sim_RV64
RUN cp "$(swift build -c release --show-bin-path)/glyco" /staging/glyco

# ================================
# Run image
# ================================
FROM swift:5.5.3-focal

# Install any updates since the build image & runtime dependencies.
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && \
    apt-get -q update && apt-get -q dist-upgrade -y \
    && rm -rf /var/lib/apt/lists/*

# Create a glyco user and group with /glyco as its home directory.
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /glyco glyco

# Switch to the new home directory.
WORKDIR /glyco

# Copy products from builder.
COPY --from=build --chown=glyco:glyco /staging /glyco

# Ensure all further commands run as the glyco user.
USER glyco:glyco

# Define environment.
ENV SIMULATOR="/glyco/cheri_riscv_sim_RV64"

# Define entrypoint.
ENTRYPOINT ["/glyco/glyco"]
