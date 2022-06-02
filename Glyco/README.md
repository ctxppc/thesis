# Glyco
**Glyco** (/ɣliˈko/) is a nanopass compiler that builds CHERI-RISC-V executables.

Glyco is implemented as a sequence of intermediate languages interleaved by nanopasses. A list of languages with their grammar can be found in [Languages](Languages.md).

## Building
### Using Docker
Glyco and the Sail-based emulator can be run as a [Docker](https://www.docker.com/get-started/) container. To build an image from source, go to the `Glyco` directory in the repository and `docker build . -t glyco` away! The tag name can be anything. Please brew a coffee while you wait.

### Glyco
Glyco is written in [Swift](https://www.swift.org/), an opinionated programming language developed by a famous fruit stand.

For Linux-based distros, install the toolchain's prerequisites (command shown below for Ubuntu 20.04), [download the toolchain](https://www.swift.org/download/), and untar it — Swift 5.6.1 and newer should be okay.

	apt-get install binutils git gnupg2 libc6-dev libcurl4 libedit2 libgcc-9-dev libpython2.7 libsqlite3-0 libstdc++-9-dev libxml2 libz3-dev pkg-config tzdata uuid-dev zlib1g-dev

You can (should?) verify the download's PGP signature. The toolchain contains a `usr/bin` folder; update your `PATH` variable to include a path to that folder.

Swift is available as part of Xcode (and Xcode Command Line Tools) on macOS.

Build Glyco using Xcode (macOS only) or by running `swift build -c release`. For development builds, do `swift build` instead. The `glyco` binary is located at the path printed by `swift build -c release --show-bin-path`/`swift build --show-bin-path`.

### CHERI-RISC-V toolchain
Glyco depends on [CHERI-LLVM](https://github.com/CTSRD-CHERI/llvm-project) for assembling & linking. CHERI-LLVM is part of the CHERI-RISC-V toolchain, which also contains an QEMU emulator and a FreeBSD fork named CheriBSD.

The following command installs the toolchain's prerequisites on macOS, assuming [Homebrew](https://brew.sh/) is already installed.

	brew install cmake ninja libarchive git glib gnu-sed automake autoconf coreutils llvm make wget pixman pkg-config xz

Similarly, the following command installs toolchain's prerequisites on Ubuntu et al.

	apt install autoconf automake libtool pkg-config clang bison cmake ninja-build samba flex texinfo libglib2.0-dev libpixman-1-dev libarchive-dev libarchive-tools libbz2-dev libattr1-dev libcap-ng-dev

The toolchain can be built using [cheribuild](https://github.com/CTSRD-CHERI/cheribuild). From within the toolchain project's directory, run `./cheribuild.py llvm-native -d` to build CHERI-LLVM. (To build & run the QEMU emulator with CheriBSD, run `./cheribuild.py run-riscv64-purecap -d`. The `root` account has an empty password.)

Building CheriBSD or anything with LLVM from scratch takes a possibly excruciating amount of time (hours). However, subsequent builds should be considerably faster.

### Sail-based emulator (optional)
Glyco creates ELF executables that can be run on a [Sail-based emulator of CHERI-RISC-V](https://github.com/CTSRD-CHERI/sail-cheri-riscv), which runs on at least macOS 11.x, Ubuntu 20.04, and likely older and newer versions of these OSes.

The following commands install the emulator on Ubuntu 20.04. Remove `-y` to enable social mode.

	sudo apt install -y opam zlib1g-dev pkg-config libgmp-dev z3
	opam init -y
	opam install -y sail
	git clone --recurse-submodules https://github.com/CTSRD-CHERI/sail-cheri-riscv
	cd sail-cheri-riscv
	eval $(opam env) && make c_emulator/cheri_riscv_sim_RV64

The following commands install the emulator on macOS 11.x, assuming [Homebrew](https://brew.sh/) is already installed.

	xcode-select --install	# or choose an Xcode installation in Xcode Preferences
	brew install gmp z3 pkg-config
	opam init -y
	opam install -y sail
	git clone --recurse-submodules https://github.com/CTSRD-CHERI/sail-cheri-riscv
	cd sail-cheri-riscv
	eval $(opam env) && make c_emulator/cheri_riscv_sim_RV64

All Glyco features except `-s`/`--simulate` continue to work when no simulator is present.

## Usage

    glyco <source>
		[--languages <language> ...]
		[--target sail | cheriBSD]
		[--output <output>]
		[--cc conventional | heap]
		[--argument-registers <register> ...]
		[--simulate]
		[--continuous]

where

* *source* is (a relative path to) an intermediate file — the file‘s extension must be the name of an intermediate language: `.s`, `.rv`, `.cc`, `.ex`, etc.;
* *language* is an intermediate language (S, FO, CC, EX, etc.) to emit — omit to build an ELF file;
* *output* is (a relative path to) the IL/ELF program to produce — omit to output to the current directory; and
* *register* is a RISC-V register to use for argument passing — omit for `a0 a1 a2 a3 a4 a5 a6 a7`.

The `--simulate` (`-s`) flag runs the program in the Sail-based emulator. The path to the simulator can be specified via the `SIMULATOR` environment variable (not needed in Docker container).

The `--continuous` flag makes Glyco observe the filesystem and recompile any changes to the source files. The flag is only available on macOS.

Glyco requires a CHERI-RISC-V toolchain and a CheriBSD system root, as built by cheribuild. The path to the toolchain can be provided through the `CHERITOOLCHAIN` environment variable; if omitted, Glyco assumes it‘s in `~/cheri`. The path to the system root can be provided through the `CHERISYSROOT` environment variable; if omitted, Glyco assumes it‘s in `output/rootfs-riscv64-purecap` within the toolchain.

### Example
To compile `myprogram.al` (an AL program) in the current directory to `myprogram.rv` (an RV program), run the following command.

	glyco myprogram.al -l rv

To do the same using Glyco in a Docker image tagged `glyco`, run the following command.

	docker run -it -v (pwd):(pwd) -w (pwd) glyco myprogram.al -l rv	# fish
	docker run -it -v `pwd`:`pwd` -w `pwd` glyco myprogram.al -l rv	# bash

The Docker option `-v` mounts the current directory of the host terminal as a volume in the container while `-w` changes the current directory of the container's terminal.
