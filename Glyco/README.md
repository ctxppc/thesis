# Gly & Glyco
**Gly** (/ɣliˈ/) is a testbed programming language for the **Glyco** (/ɣliˈko/) nanopass compiler which translates Gly code into CHERI RISC-V. The **Glyco** tool vends a command-line interface to the compiler core, vended by the **GlycoKit** library.

## Usage

    Glyco <source> [--language <language>] [--target <target>] [--output <output>]

where

* *source* is a Gly or intermediate file — the file‘s extension must be `.gly` or the name of an intermediate language: `.s`, `.rv`, `.fl`, etc.;
* *language* is the intermediate language (S, FL, FO, etc.) to emit — omit to build an ELF file;
* *target* is the target (CheriBSD or Sail) to build for — omit to build for Sail; and
* *output* is the name of the ELF to produce — omit to discard the ELF file or to print the intermediate representation to standard out.

Glyco requires a CHERI-RISC-V toolchain and a CheriBSD system root, as built by cheribuild. The path to the toolchain can be provided through the `CHERITOOLCHAIN` environment variable; if omitted, Glyco assumes it‘s in `~/cheri`. The path to the system root can be provided through the `CHERISYSROOT` environment variable; if omitted, Glyco assumes it‘s in `output/rootfs-riscv64-purecap` within the toolchain.

## Nanopasses
Glyco is implemented as a sequence of intermediate languages, i.e., data structures, interleaved by passes, i.e., functions, defined on each source language. A list of languages with their grammar can be found in [Languages](Languages.md).

Glyco focusses on a single high-level language *Gly* (to be designed) and thus this list can be seen as a linked list, but the nanopass approach allows for a tree of intermediate languages to be defined with `S` as the root, or even a directed (possibly acyclic) graph of languages from numerous low-level (machine) languages to high-level (programmer-optimised) languages.
