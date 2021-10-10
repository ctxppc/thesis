# Gly & Glyco
**Gly** (/ɣliˈ/) is a testbed programming language for the **Glyco** (/ɣliˈko/) nanopass compiler which translates Gly code into CHERI RISC-V. The **Glyco** tool vends a command-line interface to the compiler core, vended by the **GlycoKit** library.

## Usage
To be done.

## Nanopasses
Glyco is implemented as a sequence of intermediate languages, i.e., data structures, interleaved by passes, i.e., functions, defined on each source language. A list of languages as of writing, ordering languages from low-level to high-level, is printed below. This list may become outdated as the compiler is being developed.

<table>
	<tr>
		<th>Short Name</th>
		<th>Longer Name</th>
		<th>Description</th>
		<th>Program Represented By…</th>
	</tr>
	<tr>
		<td><code>RV</code></td>
		<td>CHERI-RISC-V</td>
		<td>Maps directly to CHERI-RISC-V instructions</td>
		<td><code>RVProgram</code></td>
	</tr>
	<tr>
		<td><code>FL</code></td>
		<td>Frame Locations</td>
		<td>Introduces frame locations, i.e., memory locations relative to the frame pointer (<code>fp</code>).</td>
		<td><code>FLProgram</code></td>
	</tr>
	<tr>
		<td><code>FO</code></td>
		<td>Flexible Operands</td>
		<td>Introduces flexible operands in instructions, i.e., instructions that can take frame locations in all operand positions.</td>
		<td><code>FOProgram</code></td>
	</tr>
	<tr>
		<td><code>NE</code></td>
		<td>Nested Effects</td>
		<td>Introduces an effect that can contain a sequence of effects.</td>
		<td><code>NEProgram</code></td>
	</tr>
	<tr>
		<td><code>AL</code></td>
		<td>Abstract Locations</td>
		<td>Introduces abstract locations, i.e., locations whose physical locations is not specified by the programmer.</td>
		<td><code>ALProgram</code></td>
	</tr>
</table>

Glyco focusses on a single high-level language, Glyco, and thus this list can be seen as a linked list, but it's very conceivable that the nanopass approach allows for a tree of intermediate languages to be defined with CHERI-RISC-V as the root, or even a directed (possibly acyclic) graph of languages from numerous low-level (machine) languages to high-level (programmer-optimised) languages.
