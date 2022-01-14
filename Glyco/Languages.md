
# Intermediate Languages Supported by Glyco
**Glyco** is a nanopass compiler, so-called because it consists of numerous intermediate languages and small passes.

The pipeline, from high-level to low-level is:
[`EX`](#EX) →
[`LS`](#LS) →
[`DF`](#DF) →
[`CV`](#CV) →
[`CA`](#CA) →
[`CC`](#CC) →
[`AL`](#AL) →
[`CD`](#CD) →
[`PR`](#PR) →
[`BB`](#BB) →
[`FO`](#FO) →
[`FL`](#FL) →
[`RV`](#RV) →
[`S`](#S) →
 ELF.

This document is generated automatically by [Sourcery](https://github.com/krzysztofzablocki/Sourcery) using GlycoKit's source files as input. To update it, go to the project root (`/Glyco` in the repository) and invoke `sourcery`. Pass the `--watch` flag to enable continuous updates.

## How to Use
Every intermediate language is defined by a context-free grammar, listed below. To write a program in some language, choose a production rule for that language's `Program` nonterminal (although often there's only one rule) and write a production that conforms to that rule. The rule mentions other nonterminals which are either defined in the same language are inherited from the lower language.

A program written in some language `XY` should be stored in a file with extension `.xy` (case-insensitive) since Glyco uses the extension to determine the source language.

## Shared Grammar
<dl>
	<dt><code>[<var>N</var>]</code> for any <var>N</var></dt>
	<dd>ε</dd>
	<dd><code><var>N</var> [<var>N</var>]</code></dd>
	<dt><code>Bool</code></dt>
	<dd><code>true</code></dd>
	<dd><code>"true"</code></dd>
	<dd><code>false</code></dd>
	<dd><code>"false"</code></dd>
	<dt><code>Int</code></dt>
	<dd><code>digits</code></dd>
	<dd><kbd>-</kbd><code>digits</code></dd>
	<dt><code>digits</code></dt>
	<dd><code>digit</code></dd>
	<dd><code>digit</code><code>digits</code></dd>
	<dt><code>digit</code></dt>
	<dd>Any character between 0 and 9.</dd>
	<dt><code>String</code></dt>
	<dd><code>id</code></dd>
	<dd>Zero or more printable characters enclosed in double-quotes <kbd>"</kbd>, with any occurrences of the double-quote character <kbd>"</kbd> in the string content replaced with two instances of the same, i.e., <kbd>""</kbd>.</dd>
	<dt><code>id</code></dt>
	<dd><code>idstart</code></dd>
	<dd><code>idstart</code><code>id</code></dd>
	<dt><code>idstart</code></dt>
	<dd>A character from Unicode General Category L* or M*.</dd>
	<dd><kbd>_</kbd></dd>
	<dt><code>idtail</code></dt>
	<dd>A character from Unicode General Category L*, M*, or N*.</dd>
	<dd><kbd>_</kbd></dd>
</dl>


<h2 id="EX">Grammar for EX (Expressions)</h2>
A language that introduces expression semantics for values, thereby abstracting over computation effects.

**Inherited from LS:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>Context</code>, 
<code>DataType</code>, 
<code>Label</code>, 
<code>Parameter</code>, 
<code>Symbol</code>

<dl>
<dt><code>EX.Definition</code></dt>
<dd><code>(Symbol, Value)</code></dd>
</dl>
<dl>
<dt><code>EX.Function</code></dt>
<dd><code>(Label, [Parameter], Result)</code></dd>
</dl>
<dl>
<dt><code>EX.Predicate</code></dt>
<dd><code><strong>constant</strong>(Bool)</code></dd>
<dd><code><strong>relation</strong>(Value, BranchRelation, Value)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Predicate, <strong>else:</strong> Predicate)</code></dd>
<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Predicate)</code></dd>
</dl>
<dl>
<dt><code>EX.Program</code></dt>
<dd><code>(Result, <strong>functions:</strong> [Function])</code></dd>
</dl>
<dl>
<dt><code>EX.Result</code></dt>
<dd><code><strong>value</strong>(Value)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Result, <strong>else:</strong> Result)</code></dd>
<dd><code><strong>evaluate</strong>(Label, [Value])</code></dd>
<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Result)</code></dd>
</dl>
<dl>
<dt><code>EX.Value</code></dt>
<dd><code><strong>constant</strong>(Int)</code></dd>
<dd><code><strong>vector</strong>([Value])</code></dd>
<dd><code><strong>named</strong>(Symbol)</code></dd>
<dd><code><strong>binary</strong>(Value, BinaryOperator, Value)</code></dd>
<dd><code><strong>element</strong>(<strong>of:</strong> Value, <strong>at:</strong> Value)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Value, <strong>else:</strong> Value)</code></dd>
<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Value)</code></dd>
</dl>


<h2 id="LS">Grammar for LS (Lexical Scopes)</h2>
A language that introduces lexical scopes of definitions

**Inherited from DF:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>DataType</code>, 
<code>Label</code>

<dl>
<dt><code>LS.Definition</code></dt>
<dd><code>(Symbol, Value)</code></dd>
</dl>
<dl>
<dt><code>LS.Function</code></dt>
<dd><code>(Label, [Parameter], Result)</code></dd>
</dl>
<dl>
<dt><code>LS.Parameter</code></dt>
<dd><code>(Symbol, DataType)</code></dd>
</dl>
<dl>
<dt><code>LS.Predicate</code></dt>
<dd><code><strong>constant</strong>(Bool)</code></dd>
<dd><code><strong>relation</strong>(Source, BranchRelation, Source)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Predicate, <strong>else:</strong> Predicate)</code></dd>
<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Predicate)</code></dd>
</dl>
<dl>
<dt><code>LS.Program</code></dt>
<dd><code>(Result, <strong>functions:</strong> [Function])</code></dd>
</dl>
<dl>
<dt><code>LS.Result</code></dt>
<dd><code><strong>value</strong>(Value)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Result, <strong>else:</strong> Result)</code></dd>
<dd><code><strong>evaluate</strong>(Label, [Source])</code></dd>
<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Result)</code></dd>
</dl>
<dl>
<dt><code>LS.Source</code></dt>
<dd><code><strong>constant</strong>(Int)</code></dd>
<dd><code><strong>symbol</strong>(Symbol)</code></dd>
</dl>
<dl>
<dt><code>LS.Value</code></dt>
<dd><code><strong>source</strong>(Source)</code></dd>
<dd><code><strong>binary</strong>(Source, BinaryOperator, Source)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Value, <strong>else:</strong> Value)</code></dd>
<dd><code><strong>evaluate</strong>(Label, [Source])</code></dd>
<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Value)</code></dd>
</dl>
<dl>
<dt><code>LS.Symbol</code></dt>
<dd><code>String</code></dd>
</dl>


<h2 id="DF">Grammar for DF (Definitions)</h2>
A language that introduces definitions with function-wide namespacing.

**Inherited from CV:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>Context</code>, 
<code>DataType</code>, 
<code>Label</code>, 
<code>Location</code>, 
<code>Parameter</code>, 
<code>Source</code>

<dl>
<dt><code>DF.Definition</code></dt>
<dd><code>(Location, Value)</code></dd>
</dl>
<dl>
<dt><code>DF.Function</code></dt>
<dd><code>(Label, [Parameter], Result)</code></dd>
</dl>
<dl>
<dt><code>DF.Predicate</code></dt>
<dd><code><strong>constant</strong>(Bool)</code></dd>
<dd><code><strong>relation</strong>(Source, BranchRelation, Source)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Predicate, <strong>else:</strong> Predicate)</code></dd>
<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Predicate)</code></dd>
</dl>
<dl>
<dt><code>DF.Program</code></dt>
<dd><code>(Result, <strong>functions:</strong> [Function])</code></dd>
</dl>
<dl>
<dt><code>DF.Result</code></dt>
<dd><code><strong>value</strong>(Value)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Result, <strong>else:</strong> Result)</code></dd>
<dd><code><strong>evaluate</strong>(Label, [Source])</code></dd>
<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Result)</code></dd>
</dl>
<dl>
<dt><code>DF.Value</code></dt>
<dd><code><strong>source</strong>(Source)</code></dd>
<dd><code><strong>binary</strong>(Source, BinaryOperator, Source)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Value, <strong>else:</strong> Value)</code></dd>
<dd><code><strong>evaluate</strong>(Label, [Source])</code></dd>
<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Value)</code></dd>
</dl>


<h2 id="CV">Grammar for CV (Computed Values)</h2>
A language that allows computation to be attached to an assigned value.

**Inherited from CA:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>Context</code>, 
<code>DataType</code>, 
<code>Label</code>, 
<code>Location</code>, 
<code>Parameter</code>, 
<code>Source</code>

<dl>
<dt><code>CV.Effect</code></dt>
<dd><code><strong>do</strong>([Effect])</code></dd>
<dd><code><strong>set</strong>(Location, <strong>to:</strong> Value)</code></dd>
<dd><code><strong>setElement</strong>(<strong>of:</strong> Location, <strong>at:</strong> Source, <strong>to:</strong> Source)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Effect, <strong>else:</strong> Effect)</code></dd>
<dd><code><strong>call</strong>(Label, [Source])</code></dd>
<dd><code><strong>return</strong>(Source)</code></dd>
</dl>
<dl>
<dt><code>CV.Predicate</code></dt>
<dd><code><strong>constant</strong>(Bool)</code></dd>
<dd><code><strong>relation</strong>(Source, BranchRelation, Source)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Predicate, <strong>else:</strong> Predicate)</code></dd>
<dd><code><strong>do</strong>([Effect], <strong>then:</strong> Predicate)</code></dd>
</dl>
<dl>
<dt><code>CV.Procedure</code></dt>
<dd><code>(Label, [Parameter], Effect)</code></dd>
</dl>
<dl>
<dt><code>CV.Program</code></dt>
<dd><code>(Effect, <strong>procedures:</strong> [Procedure])</code></dd>
</dl>
<dl>
<dt><code>CV.Value</code></dt>
<dd><code><strong>source</strong>(Source)</code></dd>
<dd><code><strong>binary</strong>(Source, BinaryOperator, Source)</code></dd>
<dd><code><strong>element</strong>(<strong>of:</strong> Location, <strong>at:</strong> Source)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Value, <strong>else:</strong> Value)</code></dd>
<dd><code><strong>do</strong>([Effect], <strong>then:</strong> Value)</code></dd>
<dd><code><strong>call</strong>(Label, [Source])</code></dd>
</dl>


<h2 id="CA">Grammar for CA (Canonical Assignments)</h2>
A language that groups all effects that write to a location under one canonical assignment effect.

**Inherited from CC:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>Context</code>, 
<code>DataType</code>, 
<code>Label</code>, 
<code>Location</code>, 
<code>Parameter</code>, 
<code>Source</code>

<dl>
<dt><code>CA.Effect</code></dt>
<dd><code><strong>do</strong>([Effect])</code></dd>
<dd><code><strong>set</strong>(Location, <strong>to:</strong> Value)</code></dd>
<dd><code><strong>setElement</strong>(<strong>of:</strong> Location, <strong>at:</strong> Source, <strong>to:</strong> Source)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Effect, <strong>else:</strong> Effect)</code></dd>
<dd><code><strong>call</strong>(Label, [Source])</code></dd>
<dd><code><strong>return</strong>(Source)</code></dd>
</dl>
<dl>
<dt><code>CA.Predicate</code></dt>
<dd><code><strong>constant</strong>(Bool)</code></dd>
<dd><code><strong>relation</strong>(Source, BranchRelation, Source)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Predicate, <strong>else:</strong> Predicate)</code></dd>
<dd><code><strong>do</strong>([Effect], <strong>then:</strong> Predicate)</code></dd>
</dl>
<dl>
<dt><code>CA.Procedure</code></dt>
<dd><code>(Label, [Parameter], Effect)</code></dd>
</dl>
<dl>
<dt><code>CA.Program</code></dt>
<dd><code>(Effect, <strong>procedures:</strong> [Procedure])</code></dd>
</dl>
<dl>
<dt><code>CA.Value</code></dt>
<dd><code><strong>source</strong>(Source)</code></dd>
<dd><code><strong>binary</strong>(Source, BinaryOperator, Source)</code></dd>
<dd><code><strong>element</strong>(<strong>of:</strong> Location, <strong>at:</strong> Source)</code></dd>
</dl>


<h2 id="CC">Grammar for CC (Calling Convention)</h2>
A language that introduces parameter passing and enforces the low-level Glyco calling convention.

**Inherited from AL:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>DataType</code>, 
<code>Label</code>, 
<code>Location</code>

<dl>
<dt><code>CC.Effect</code></dt>
<dd><code><strong>do</strong>([Effect])</code></dd>
<dd><code><strong>set</strong>(Location, <strong>to:</strong> Source)</code></dd>
<dd><code><strong>compute</strong>(Source, BinaryOperator, Source, <strong>to:</strong> Location)</code></dd>
<dd><code><strong>getElement</strong>(<strong>of:</strong> Location, <strong>at:</strong> Source, <strong>to:</strong> Location)</code></dd>
<dd><code><strong>setElement</strong>(<strong>of:</strong> Location, <strong>at:</strong> Source, <strong>to:</strong> Source)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Effect, <strong>else:</strong> Effect)</code></dd>
<dd><code><strong>call</strong>(Label, [Source])</code></dd>
<dd><code><strong>return</strong>(Source)</code></dd>
</dl>
<dl>
<dt><code>CC.Parameter</code></dt>
<dd><code>(Location, DataType)</code></dd>
</dl>
<dl>
<dt><code>CC.Predicate</code></dt>
<dd><code><strong>constant</strong>(Bool)</code></dd>
<dd><code><strong>relation</strong>(Source, BranchRelation, Source)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Predicate, <strong>else:</strong> Predicate)</code></dd>
<dd><code><strong>do</strong>([Effect], <strong>then:</strong> Predicate)</code></dd>
</dl>
<dl>
<dt><code>CC.Procedure</code></dt>
<dd><code>(Label, [Parameter], Effect)</code></dd>
</dl>
<dl>
<dt><code>CC.Program</code></dt>
<dd><code>(Effect, <strong>procedures:</strong> [Procedure])</code></dd>
</dl>
<dl>
<dt><code>CC.Source</code></dt>
<dd><code><strong>immediate</strong>(Int)</code></dd>
<dd><code><strong>location</strong>(Location)</code></dd>
</dl>


<h2 id="AL">Grammar for AL (Abstract Locations)</h2>
A language that introduces abstract locations, i.e., locations whose physical locations are not specified by the programmer.

**Inherited from CD:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>DataType</code>, 
<code>Frame</code>, 
<code>Label</code>

<dl>
<dt><code>AL.Effect</code></dt>
<dd><code><strong>do</strong>([Effect])</code></dd>
<dd><code><strong>set</strong>(Location, <strong>to:</strong> Source)</code></dd>
<dd><code><strong>compute</strong>(Source, BinaryOperator, Source, <strong>to:</strong> Location)</code></dd>
<dd><code><strong>getElement</strong>(<strong>of:</strong> Location, <strong>at:</strong> Source, <strong>to:</strong> Location)</code></dd>
<dd><code><strong>setElement</strong>(<strong>of:</strong> Location, <strong>at:</strong> Source, <strong>to:</strong> Source)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Effect, <strong>else:</strong> Effect)</code></dd>
<dd><code><strong>call</strong>(Label, [ParameterLocation])</code></dd>
<dd><code><strong>return</strong>(Source)</code></dd>
</dl>
<dl>
<dt><code>AL.Location</code></dt>
<dd><code><strong>abstract</strong>(AbstractLocation)</code></dd>
<dd><code><strong>parameter</strong>(ParameterLocation)</code></dd>
</dl>
<dl>
<dt><code>AL.ParameterLocation</code></dt>
<dd><code><strong>register</strong>(Register)</code></dd>
<dd><code><strong>frame</strong>(Frame.Location)</code></dd>
</dl>
<dl>
<dt><code>AL.Predicate</code></dt>
<dd><code><strong>constant</strong>(Bool)</code></dd>
<dd><code><strong>relation</strong>(Source, BranchRelation, Source)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Predicate, <strong>else:</strong> Predicate)</code></dd>
<dd><code><strong>do</strong>([Effect], <strong>then:</strong> Predicate)</code></dd>
</dl>
<dl>
<dt><code>AL.Procedure</code></dt>
<dd><code>(Label, Effect)</code></dd>
</dl>
<dl>
<dt><code>AL.Program</code></dt>
<dd><code>(Effect, <strong>procedures:</strong> [Procedure])</code></dd>
</dl>
<dl>
<dt><code>AL.Register</code></dt>
<dd><code><strong>sp</strong></code></dd>
<dd><code><strong>fp</strong></code></dd>
<dd><code><strong>a0</strong></code></dd>
<dd><code><strong>a1</strong></code></dd>
<dd><code><strong>a2</strong></code></dd>
<dd><code><strong>a3</strong></code></dd>
<dd><code><strong>a4</strong></code></dd>
<dd><code><strong>a5</strong></code></dd>
<dd><code><strong>a6</strong></code></dd>
<dd><code><strong>a7</strong></code></dd>
</dl>
<dl>
<dt><code>AL.Source</code></dt>
<dd><code><strong>immediate</strong>(Int)</code></dd>
<dd><code><strong>location</strong>(Location)</code></dd>
</dl>
<dl>
<dt><code>AL.AbstractLocation</code></dt>
<dd><code>String</code></dd>
</dl>


<h2 id="CD">Grammar for CD (Conditionals)</h2>
A language that introduces conditionals in effects and predicates, thereby abstracting over blocks (and jumps).

**Inherited from PR:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>DataType</code>, 
<code>Frame</code>, 
<code>Label</code>, 
<code>Location</code>, 
<code>Register</code>, 
<code>Source</code>

<dl>
<dt><code>CD.Effect</code></dt>
<dd><code><strong>do</strong>([Effect])</code></dd>
<dd><code><strong>set</strong>(DataType, Location, <strong>to:</strong> Source)</code></dd>
<dd><code><strong>compute</strong>(Source, BinaryOperator, Source, <strong>to:</strong> Location)</code></dd>
<dd><code><strong>getElement</strong>(DataType, <strong>of:</strong> Location, <strong>at:</strong> Source, <strong>to:</strong> Location)</code></dd>
<dd><code><strong>setElement</strong>(DataType, <strong>of:</strong> Location, <strong>at:</strong> Source, <strong>to:</strong> Source)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Effect, <strong>else:</strong> Effect)</code></dd>
<dd><code><strong>call</strong>(Label)</code></dd>
<dd><code><strong>return</strong>(DataType, Source)</code></dd>
</dl>
<dl>
<dt><code>CD.Predicate</code></dt>
<dd><code><strong>constant</strong>(Bool)</code></dd>
<dd><code><strong>relation</strong>(Source, BranchRelation, Source)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Predicate, <strong>else:</strong> Predicate)</code></dd>
<dd><code><strong>do</strong>([Effect], <strong>then:</strong> Predicate)</code></dd>
</dl>
<dl>
<dt><code>CD.Procedure</code></dt>
<dd><code>(Label, Effect)</code></dd>
</dl>
<dl>
<dt><code>CD.Program</code></dt>
<dd><code>(Effect, <strong>procedures:</strong> [Procedure])</code></dd>
</dl>


<h2 id="PR">Grammar for PR (Predicates)</h2>
A language that introduces predicates in branches.

**Inherited from BB:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>DataType</code>, 
<code>Effect</code>, 
<code>Frame</code>, 
<code>Label</code>, 
<code>Location</code>, 
<code>Register</code>, 
<code>Source</code>

<dl>
<dt><code>PR.Block</code></dt>
<dd><code><strong>intermediate</strong>(Label, [Effect], <strong>then:</strong> Label)</code></dd>
<dd><code><strong>branch</strong>(Label, [Effect], <strong>if:</strong> Predicate, <strong>then:</strong> Label, <strong>else:</strong> Label)</code></dd>
<dd><code><strong>final</strong>(Label, [Effect], <strong>result:</strong> Source, <strong>type:</strong> DataType)</code></dd>
</dl>
<dl>
<dt><code>PR.Predicate</code></dt>
<dd><code><strong>constant</strong>(Bool)</code></dd>
<dd><code><strong>not</strong>(Predicate)</code></dd>
<dd><code><strong>relation</strong>(Source, BranchRelation, Source)</code></dd>
</dl>
<dl>
<dt><code>PR.Program</code></dt>
<dd><code>([Block])</code></dd>
</dl>


<h2 id="BB">Grammar for BB (Basic Blocks)</h2>
A language that groups effects into blocks of effects where blocks can only be entered at a single entry point and exited at a single exit point.

**Inherited from FO:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>DataType</code>, 
<code>Frame</code>, 
<code>Label</code>, 
<code>Location</code>, 
<code>Register</code>, 
<code>Source</code>

<dl>
<dt><code>BB.Block</code></dt>
<dd><code><strong>intermediate</strong>(Label, [Effect], <strong>then:</strong> Label)</code></dd>
<dd><code><strong>branch</strong>(Label, [Effect], <strong>lhs:</strong> Source, <strong>relation:</strong> BranchRelation, <strong>rhs:</strong> Source, <strong>then:</strong> Label, <strong>else:</strong> Label)</code></dd>
<dd><code><strong>final</strong>(Label, [Effect], <strong>result:</strong> Source, <strong>type:</strong> DataType)</code></dd>
</dl>
<dl>
<dt><code>BB.Effect</code></dt>
<dd><code><strong>set</strong>(DataType, Location, <strong>to:</strong> Source)</code></dd>
<dd><code><strong>compute</strong>(Source, BinaryOperator, Source, <strong>to:</strong> Location)</code></dd>
<dd><code><strong>getElement</strong>(DataType, <strong>of:</strong> Location, <strong>at:</strong> Source, <strong>to:</strong> Location)</code></dd>
<dd><code><strong>setElement</strong>(DataType, <strong>of:</strong> Location, <strong>at:</strong> Source, <strong>to:</strong> Source)</code></dd>
</dl>
<dl>
<dt><code>BB.Program</code></dt>
<dd><code>([BB.Block])</code></dd>
</dl>


<h2 id="FO">Grammar for FO (Frame Operands)</h2>
A language that introduces flexible operands in instructions, i.e., instructions that can take frame locations in all operand positions.

**Inherited from FL:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>DataType</code>, 
<code>Label</code>

<dl>
<dt><code>FO.Effect</code></dt>
<dd><code><strong>set</strong>(DataType, Location, <strong>to:</strong> Source)</code></dd>
<dd><code><strong>compute</strong>(Source, BinaryOperator, Source, <strong>to:</strong> Location)</code></dd>
<dd><code><strong>getElement</strong>(DataType, <strong>of:</strong> Location, <strong>at:</strong> Source, <strong>to:</strong> Location)</code></dd>
<dd><code><strong>setElement</strong>(DataType, <strong>of:</strong> Location, <strong>at:</strong> Source, <strong>to:</strong> Source)</code></dd>
<dd><code><strong>branch</strong>(<strong>to:</strong> Label, Source, BranchRelation, Source)</code></dd>
<dd><code><strong>jump</strong>(<strong>to:</strong> Label)</code></dd>
<dd><code><strong>call</strong>(Label)</code></dd>
<dd><code><strong>return</strong></code></dd>
<dd><code><strong>labelled</strong>(Label, Effect)</code></dd>
</dl>
<dl>
<dt><code>FO.HaltEffect</code></dt>
<dd><code>(<strong>result:</strong> Source, <strong>type:</strong> DataType)</code></dd>
</dl>
<dl>
<dt><code>FO.Location</code></dt>
<dd><code><strong>register</strong>(Register)</code></dd>
<dd><code><strong>frameCell</strong>(Frame.Location)</code></dd>
</dl>
<dl>
<dt><code>FO.Program</code></dt>
<dd><code>(<strong>effects:</strong> [Effect])</code></dd>
</dl>
<dl>
<dt><code>FO.Register</code></dt>
<dd><code><strong>zero</strong></code></dd>
<dd><code><strong>ra</strong></code></dd>
<dd><code><strong>sp</strong></code></dd>
<dd><code><strong>gp</strong></code></dd>
<dd><code><strong>tp</strong></code></dd>
<dd><code><strong>fp</strong></code></dd>
<dd><code><strong>s1</strong></code></dd>
<dd><code><strong>a0</strong></code></dd>
<dd><code><strong>a1</strong></code></dd>
<dd><code><strong>a2</strong></code></dd>
<dd><code><strong>a3</strong></code></dd>
<dd><code><strong>a4</strong></code></dd>
<dd><code><strong>a5</strong></code></dd>
<dd><code><strong>a6</strong></code></dd>
<dd><code><strong>a7</strong></code></dd>
<dd><code><strong>s2</strong></code></dd>
<dd><code><strong>s3</strong></code></dd>
<dd><code><strong>s4</strong></code></dd>
<dd><code><strong>s5</strong></code></dd>
<dd><code><strong>s6</strong></code></dd>
<dd><code><strong>s7</strong></code></dd>
<dd><code><strong>s8</strong></code></dd>
<dd><code><strong>s9</strong></code></dd>
<dd><code><strong>s10</strong></code></dd>
<dd><code><strong>s11</strong></code></dd>
<dd><code><strong>t4</strong></code></dd>
<dd><code><strong>t5</strong></code></dd>
<dd><code><strong>t6</strong></code></dd>
</dl>
<dl>
<dt><code>FO.Source</code></dt>
<dd><code><strong>location</strong>(Location)</code></dd>
<dd><code><strong>immediate</strong>(Int)</code></dd>
</dl>


<h2 id="FL">Grammar for FL (Frame Locations)</h2>
A language that introduces frame locations, i.e., memory locations relative to the frame capability `cfp`.

**Inherited from RV:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>DataType</code>, 
<code>Label</code>

<dl>
<dt><code>FL.BinaryExpression</code></dt>
<dd><code><strong>registerRegister</strong>(Register, BinaryOperator, Register)</code></dd>
<dd><code><strong>registerImmediate</strong>(Register, BinaryOperator, Int)</code></dd>
</dl>
<dl>
<dt><code>FL.Effect</code></dt>
<dd><code><strong>copy</strong>(DataType, <strong>into:</strong> Register, <strong>from:</strong> Register)</code></dd>
<dd><code><strong>compute</strong>(<strong>into:</strong> Register, <strong>value:</strong> BinaryExpression)</code></dd>
<dd><code><strong>load</strong>(DataType, <strong>into:</strong> Register, <strong>from:</strong> Frame.Location)</code></dd>
<dd><code><strong>store</strong>(DataType, <strong>into:</strong> Frame.Location, <strong>from:</strong> Register)</code></dd>
<dd><code><strong>loadElement</strong>(DataType, <strong>into:</strong> Register, <strong>vector:</strong> Register, <strong>index:</strong> Register)</code></dd>
<dd><code><strong>storeElement</strong>(DataType, <strong>vector:</strong> Register, <strong>index:</strong> Register, <strong>from:</strong> Register)</code></dd>
<dd><code><strong>branch</strong>(<strong>to:</strong> Label, Register, BranchRelation, Register)</code></dd>
<dd><code><strong>jump</strong>(<strong>to:</strong> Label)</code></dd>
<dd><code><strong>call</strong>(Label)</code></dd>
<dd><code><strong>return</strong></code></dd>
<dd><code><strong>labelled</strong>(Label, Effect)</code></dd>
</dl>
<dl>
<dt><code>FL.Frame.Location</code></dt>
<dd><code>(<strong>offset:</strong> Int)</code></dd>
</dl>
<dl>
<dt><code>FL.Location</code></dt>
<dd><code><strong>register</strong>(Register)</code></dd>
<dd><code><strong>frameCell</strong>(Frame.Location)</code></dd>
</dl>
<dl>
<dt><code>FL.Program</code></dt>
<dd><code>([Effect])</code></dd>
</dl>
<dl>
<dt><code>FL.Register</code></dt>
<dd><code><strong>zero</strong></code></dd>
<dd><code><strong>ra</strong></code></dd>
<dd><code><strong>sp</strong></code></dd>
<dd><code><strong>gp</strong></code></dd>
<dd><code><strong>tp</strong></code></dd>
<dd><code><strong>t1</strong></code></dd>
<dd><code><strong>t2</strong></code></dd>
<dd><code><strong>fp</strong></code></dd>
<dd><code><strong>s1</strong></code></dd>
<dd><code><strong>a0</strong></code></dd>
<dd><code><strong>a1</strong></code></dd>
<dd><code><strong>a2</strong></code></dd>
<dd><code><strong>a3</strong></code></dd>
<dd><code><strong>a4</strong></code></dd>
<dd><code><strong>a5</strong></code></dd>
<dd><code><strong>a6</strong></code></dd>
<dd><code><strong>a7</strong></code></dd>
<dd><code><strong>s2</strong></code></dd>
<dd><code><strong>s3</strong></code></dd>
<dd><code><strong>s4</strong></code></dd>
<dd><code><strong>s5</strong></code></dd>
<dd><code><strong>s6</strong></code></dd>
<dd><code><strong>s7</strong></code></dd>
<dd><code><strong>s8</strong></code></dd>
<dd><code><strong>s9</strong></code></dd>
<dd><code><strong>s10</strong></code></dd>
<dd><code><strong>s11</strong></code></dd>
<dd><code><strong>t3</strong></code></dd>
<dd><code><strong>t4</strong></code></dd>
<dd><code><strong>t5</strong></code></dd>
<dd><code><strong>t6</strong></code></dd>
</dl>


<h2 id="RV">Grammar for RV (CHERI-RISC-V)</h2>
A language that maps directly to CHERI-RISC-V (pseudo-)instructions.

**Inherited from S:**
N/A

<dl>
<dt><code>RV.BinaryOperator</code></dt>
<dd><code><strong>add</strong></code></dd>
<dd><code><strong>sub</strong></code></dd>
<dd><code><strong>and</strong></code></dd>
<dd><code><strong>or</strong></code></dd>
<dd><code><strong>xor</strong></code></dd>
<dd><code><strong>sll</strong></code></dd>
<dd><code><strong>srl</strong></code></dd>
<dd><code><strong>sra</strong></code></dd>
</dl>
<dl>
<dt><code>RV.BranchRelation</code></dt>
<dd><code><strong>eq</strong></code></dd>
<dd><code><strong>ne</strong></code></dd>
<dd><code><strong>lt</strong></code></dd>
<dd><code><strong>le</strong></code></dd>
<dd><code><strong>gt</strong></code></dd>
<dd><code><strong>ge</strong></code></dd>
</dl>
<dl>
<dt><code>RV.DataType</code></dt>
<dd><code><strong>word</strong></code></dd>
<dd><code><strong>capability</strong></code></dd>
</dl>
<dl>
<dt><code>RV.Instruction</code></dt>
<dd><code><strong>copy</strong>(DataType, <strong>destination:</strong> Register, <strong>source:</strong> Register)</code></dd>
<dd><code><strong>registerRegister</strong>(<strong>operation:</strong> BinaryOperator, <strong>rd:</strong> Register, <strong>rs1:</strong> Register, <strong>rs2:</strong> Register)</code></dd>
<dd><code><strong>registerImmediate</strong>(<strong>operation:</strong> BinaryOperator, <strong>rd:</strong> Register, <strong>rs1:</strong> Register, <strong>imm:</strong> Int)</code></dd>
<dd><code><strong>loadWord</strong>(<strong>destination:</strong> Register, <strong>address:</strong> Register)</code></dd>
<dd><code><strong>loadCapability</strong>(<strong>destination:</strong> Register, <strong>address:</strong> Register, <strong>offset:</strong> Int)</code></dd>
<dd><code><strong>storeWord</strong>(<strong>source:</strong> Register, <strong>address:</strong> Register)</code></dd>
<dd><code><strong>storeCapability</strong>(<strong>source:</strong> Register, <strong>address:</strong> Register, <strong>offset:</strong> Int)</code></dd>
<dd><code><strong>offsetCapability</strong>(<strong>destination:</strong> Register, <strong>source:</strong> Register, <strong>offset:</strong> Register)</code></dd>
<dd><code><strong>offsetCapabilityWithImmediate</strong>(<strong>destination:</strong> Register, <strong>source:</strong> Register, <strong>offset:</strong> Int)</code></dd>
<dd><code><strong>branch</strong>(<strong>rs1:</strong> Register, <strong>relation:</strong> BranchRelation, <strong>rs2:</strong> Register, <strong>target:</strong> Label)</code></dd>
<dd><code><strong>jump</strong>(<strong>target:</strong> Label)</code></dd>
<dd><code><strong>call</strong>(<strong>target:</strong> Label)</code></dd>
<dd><code><strong>return</strong></code></dd>
<dd><code><strong>labelled</strong>(Label, Instruction)</code></dd>
</dl>
<dl>
<dt><code>RV.Program</code></dt>
<dd><code>(<strong>instructions:</strong> [Instruction])</code></dd>
</dl>
<dl>
<dt><code>RV.Register</code></dt>
<dd><code><strong>zero</strong></code></dd>
<dd><code><strong>ra</strong></code></dd>
<dd><code><strong>sp</strong></code></dd>
<dd><code><strong>gp</strong></code></dd>
<dd><code><strong>tp</strong></code></dd>
<dd><code><strong>t0</strong></code></dd>
<dd><code><strong>t1</strong></code></dd>
<dd><code><strong>t2</strong></code></dd>
<dd><code><strong>fp</strong></code></dd>
<dd><code><strong>s1</strong></code></dd>
<dd><code><strong>a0</strong></code></dd>
<dd><code><strong>a1</strong></code></dd>
<dd><code><strong>a2</strong></code></dd>
<dd><code><strong>a3</strong></code></dd>
<dd><code><strong>a4</strong></code></dd>
<dd><code><strong>a5</strong></code></dd>
<dd><code><strong>a6</strong></code></dd>
<dd><code><strong>a7</strong></code></dd>
<dd><code><strong>s2</strong></code></dd>
<dd><code><strong>s3</strong></code></dd>
<dd><code><strong>s4</strong></code></dd>
<dd><code><strong>s5</strong></code></dd>
<dd><code><strong>s6</strong></code></dd>
<dd><code><strong>s7</strong></code></dd>
<dd><code><strong>s8</strong></code></dd>
<dd><code><strong>s9</strong></code></dd>
<dd><code><strong>s10</strong></code></dd>
<dd><code><strong>s11</strong></code></dd>
<dd><code><strong>t3</strong></code></dd>
<dd><code><strong>t4</strong></code></dd>
<dd><code><strong>t5</strong></code></dd>
<dd><code><strong>t6</strong></code></dd>
</dl>
<dl>
<dt><code>RV.Label</code></dt>
<dd><code>String</code></dd>
</dl>


<h2 id="S">Grammar for S (CHERI-RISC-V Assembly)</h2>
The ground language as provided to Clang for assembly and linking.


<dl>
<dt><code>S.Program</code></dt>
<dd><code>(<strong>assembly:</strong> String)</code></dd>
</dl>

