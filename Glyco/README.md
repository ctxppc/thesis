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
Glyco is implemented as a sequence of intermediate languages, i.e., data structures, interleaved by passes, i.e., functions, defined on each source language. A list of languages as of writing, ordering languages from low-level to high-level, is printed below. This list may become outdated as the compiler is being developed.

<table>
	<tr>
		<th>Short Name</th>
		<th>Longer Name</th>
		<th>Description</th>
	</tr>
	<tr>
		<td><code>S</code></td>
		<td>CHERI-RISC-V Assembly</td>
		<td>Input for Clang</td>
	</tr>
	<tr>
		<td><code>RV</code></td>
		<td>CHERI-RISC-V</td>
		<td>Maps directly to CHERI-RISC-V (pseudo-)instructions.</td>
	</tr>
	<tr>
		<td><code>FL</code></td>
		<td>Frame Locations</td>
		<td>Introduces frame locations, i.e., memory locations relative to the frame pointer <code>fp</code>.</td>
	</tr>
	<tr>
		<td><code>FO</code></td>
		<td>Flexible Operands</td>
		<td>Introduces flexible operands in instructions, i.e., instructions that can take frame locations in all operand positions.</td>
	</tr>
	<tr>
		<td><code>BB</code></td>
		<td>Basic Blocks</td>
		<td>Groups effects into blocks of effects where blocks can only be entered at a single entry point and exited at a single exit point.</td>
	</tr>
	<tr>
		<td><code>PR</code></td>
		<td>Predicates</td>
		<td>Introduces predicates in branches.</td>
	</tr>
	<tr>
		<td><code>AL</code></td>
		<td>Abstract Locations</td>
		<td>Introduces abstract locations, i.e., locations whose physical locations are not specified by the programmer.</td>
	</tr>
</table>

Glyco focusses on a single high-level language *Gly* and thus this list can be seen as a linked list, but the nanopass approach allows for a tree of intermediate languages to be defined with `S` as the root, or even a directed (possibly acyclic) graph of languages from numerous low-level (machine) languages to high-level (programmer-optimised) languages.
