# ================================
# Build image
# ================================
FROM swift:5.5.3-focal as build

# Install updates & dependencies.
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && rm -rf /var/lib/apt/lists/*

# Set up a build area.
WORKDIR /build

# Resolve dependencies.
# This cached layer can be reused as long as Package.swift and Package.resolved do not change.
COPY ./Package.* ./
RUN swift package resolve

# Copy entire repo into container.
COPY . .

# Build everything.
RUN swift build -c release -Xswiftc -static-executable

# Switch to the staging area.
WORKDIR /staging

# Copy products to staging area.
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/Glyco" ./

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

# Copy built executable from builder.
COPY --from=build --chown=glyco:glyco /staging /glyco

# Ensure all further commands run as the glyco user.
USER glyco:glyco

# Define entrypoint.
ENTRYPOINT ["./Glyco"]
