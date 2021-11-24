# Docker containers for cheri-riscv

## Sail

Contains an Ubuntu 20.04 LTS base image with compiled C emulators
for RV32 and RV64. Change the base in the Dockerfile if necessary.

- Build the container with
  ```docker build --squash -t $CI_REGISTRY_IMAGE:sail .```
  where `$CI_REGISTRY_IMAGE` points the container registry.
