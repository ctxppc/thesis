# Gly & Glyco
**Gly** (/ɣliˈ/) is a testbed programming language for the **Glyco** (/ɣliˈko/) nanopass compiler which translates Gly code into CHERI RISC-V. The **Glyco** tool vends a command-line interface to the compiler core, vended by the **GlycoKit** library.

## Usage
To be done.

## Nanopasses
Glyco is implemented as a sequence of intermediate languages, i.e., data structures, interleaved by passes, i.e., functions, defined on each source language. A list of languages as of writing, ordering languages from low-level to high-level, is printed below. This list may become outdated as the compiler is being developed.

* `RV` (CHERI-RISC-V) maps directly to CHERI-RISC-V instructions. A program is represented by `RVProgram`.
* `FL` (Frame Locations) extends `RV` with frame locations, i.e., memory locations relative to the frame pointer (`fp`). A program is represented by `FLProgram`.
* `FO` (Flexible Operands) extends `FL` with flexible operands in instructions, i.e., instructions that can take frame locations in all operand positions. A program is represented by `FOProgram`.
* …
* `AL` (Abstract Locations) extends … with abstract locations, i.e., locations with unspecified physical locations. A program is represented by `ALProgram`.

Glyco focusses on a single high-level language, Glyco, and thus this list can be seen as a linked list, but it's very conceivable that the nanopass approach allows for a tree of intermediate languages to be defined with CHERI-RISC-V as the root, or even a directed (possibly acyclic) graph of languages from numerous low-level (machine) languages to high-level (programmer-optimised) languages.
