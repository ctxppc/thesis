# Docker containers for cheri-riscv

## Sail

Contains an Ubuntu 20.04 LTS base image with compiled C emulators
for RV32 and RV64. Change the base in the Dockerfile if necessary.

- Build the container with
  ```docker build --squash -t $CI_REGISTRY_IMAGE:sail .```
  where `$CI_REGISTRY_IMAGE` points the container registry.


## CheriBSD

This contains a build of cheribsd that is booted using qemu. The
extra-files change the configuration of the SSH server to allow root
logins without password, so you should not expose this to the
internets. You can use this image as a service to a Gitlab CI job
by including:


```
  services:
    - name: $CI_REGISTRY_IMAGE:cheribsd
      alias: cheribsd
```

The gitlab runner waits until the ports that are marked as exposed in
the image, i.e. `10022` in the cheribsd image, are open.
Unfortunately, this is the time qemu listens to connections and not
the time that the SSH server is up. This means you'll have to include
some logic to wait for this. For example;

```
  before_script:
    - |
      for i in $(seq 1 30); do
        echo -n '.'
        ssh -p 10022 -o StrictHostKeyChecking=no -o ConnectTimeout=10 cheribsd uname -a 2> /dev/null && break
        sleep 10
      done
```
