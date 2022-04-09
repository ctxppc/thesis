
# Intermediate Languages Supported by Glyco
**Glyco** is a nanopass compiler, so-called because it consists of numerous intermediate languages and small passes.

The pipeline, from high-level to low-level is:
[`OB`](#OB) →
[`NT`](#NT) →
[`Λ`](#Λ) →
[`EX`](#EX) →
[`LS`](#LS) →
[`DF`](#DF) →
[`CV`](#CV) →
[`CA`](#CA) →
[`CC`](#CC) →
[`SV`](#SV) →
[`ID`](#ID) →
[`AL`](#AL) →
[`ALA`](#ALA) →
[`CD`](#CD) →
[`PR`](#PR) →
[`BB`](#BB) →
[`FO`](#FO) →
[`MM`](#MM) →
[`RT`](#RT) →
[`CE`](#CE) →
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
	<dd><kbd>$</kbd></dd>
	<dd><kbd>%</kbd></dd>
	<dt><code>idtail</code></dt>
	<dd>A character from Unicode General Category L*, M*, or N*.</dd>
	<dd><kbd>_</kbd></dd>
	<dd><kbd>$</kbd></dd>
	<dd><kbd>%</kbd></dd>
</dl>


<h2 id="OB">Grammar for OB (Objects)</h2>
A language that introduces objects, i.e., encapsulated values with methods.

**Inherited from NT:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>Label</code>, 
<code>Symbol</code>, 
<code>TypeName</code>
<dl>
	<dt><code>OB.Program</code></dt>
	<dd><code>(Result, <strong>functions:</strong> [Function])</code></dd>
</dl>
<dl>
	<dt><code>OB.Predicate</code></dt>
	<dd><code><strong>constant</strong>(Bool)</code></dd>
	<dd><code><strong>relation</strong>(Value, BranchRelation, Value)</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Predicate, <strong>else:</strong> Predicate)</code></dd>
	<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Predicate)</code></dd>
</dl>
<dl>
	<dt><code>OB.Parameter</code></dt>
	<dd><code>(Symbol, ValueType)</code></dd>
</dl>
<dl>
	<dt><code>OB.Function</code></dt>
	<dd><code>(Label, <strong>takes:</strong> [Parameter], <strong>returns:</strong> ValueType, <strong>in:</strong> Result)</code></dd>
</dl>
<dl>
	<dt><code>OB.RecordType</code></dt>
	<dd><code>([Field])</code></dd>
</dl>
<dl>
	<dt><code>OB.Field</code></dt>
	<dd><code>(Name, ValueType)</code></dd>
</dl>
<dl>
	<dt><code>OB.Effect</code></dt>
	<dd><code><strong>do</strong>([Effect])</code></dd>
	<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Effect)</code></dd>
	<dd><code><strong>setField</strong>(Field.Name, <strong>of:</strong> Value, <strong>to:</strong> Value)</code></dd>
	<dd><code><strong>setElement</strong>(<strong>of:</strong> Value, <strong>at:</strong> Value, <strong>to:</strong> Value)</code></dd>
</dl>
<dl>
	<dt><code>OB.Value</code></dt>
	<dd><code><strong>self</strong></code></dd>
	<dd><code><strong>constant</strong>(Int)</code></dd>
	<dd><code><strong>named</strong>(Symbol)</code></dd>
	<dd><code><strong>record</strong>(RecordType)</code></dd>
	<dd><code><strong>field</strong>(Field.Name, <strong>of:</strong> Value)</code></dd>
	<dd><code><strong>vector</strong>(ValueType, <strong>count:</strong> Int)</code></dd>
	<dd><code><strong>element</strong>(<strong>of:</strong> Value, <strong>at:</strong> Value)</code></dd>
	<dd><code><strong>object</strong>(TypeName, [Value])</code></dd>
	<dd><code><strong>function</strong>(Label)</code></dd>
	<dd><code><strong>seal</strong></code></dd>
	<dd><code><strong>sealed</strong>(Value, <strong>with:</strong> Value)</code></dd>
	<dd><code><strong>binary</strong>(Value, BinaryOperator, Value)</code></dd>
	<dd><code><strong>evaluate</strong>(Value, [Value])</code></dd>
	<dd><code><strong>message</strong>(Value, Method.Name, [Value])</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Value, <strong>else:</strong> Value)</code></dd>
	<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Value)</code></dd>
	<dd><code><strong>letType</strong>([TypeDefinition], <strong>in:</strong> Value)</code></dd>
	<dd><code><strong>do</strong>([Effect], <strong>then:</strong> Value)</code></dd>
</dl>
<dl>
	<dt><code>OB.ObjectType</code></dt>
	<dd><code>(<strong>initialiser:</strong> Constructor, <strong>methods:</strong> [Method], <strong>state:</strong> RecordType)</code></dd>
</dl>
<dl>
	<dt><code>OB.Result</code></dt>
	<dd><code><strong>value</strong>(Value)</code></dd>
	<dd><code><strong>evaluate</strong>(Value, [Value])</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Result, <strong>else:</strong> Result)</code></dd>
	<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Result)</code></dd>
	<dd><code><strong>do</strong>([Effect], <strong>then:</strong> Result)</code></dd>
</dl>
<dl>
	<dt><code>OB.ValueType</code></dt>
	<dd><code><strong>named</strong>(TypeName)</code></dd>
	<dd><code><strong>u8</strong></code></dd>
	<dd><code><strong>s32</strong></code></dd>
	<dd><code><strong>cap</strong>(CapabilityType)</code></dd>
</dl>
<dl>
	<dt><code>OB.Constructor</code></dt>
	<dd><code>(<strong>takes:</strong> [Parameter], <strong>in:</strong> Result)</code></dd>
</dl>
<dl>
	<dt><code>OB.CapabilityType</code></dt>
	<dd><code><strong>vector</strong>(<strong>of:</strong> ValueType)</code></dd>
	<dd><code><strong>record</strong>(RecordType)</code></dd>
	<dd><code><strong>procedure</strong>(<strong>takes:</strong> [Parameter], <strong>returns:</strong> ValueType)</code></dd>
	<dd><code><strong>object</strong>(TypeName)</code></dd>
</dl>
<dl>
	<dt><code>OB.Method</code></dt>
	<dd><code>(Symbol, <strong>takes:</strong> [Parameter], <strong>returns:</strong> ValueType, <strong>in:</strong> Result)</code></dd>
</dl>
<dl>
	<dt><code>OB.Definition</code></dt>
	<dd><code>(Symbol, Value)</code></dd>
</dl>
<dl>
	<dt><code>OB.TypeDefinition</code></dt>
	<dd><code><strong>structural</strong>(TypeName, ValueType)</code></dd>
	<dd><code><strong>nominal</strong>(TypeName, ValueType)</code></dd>
	<dd><code><strong>object</strong>(TypeName, ObjectType)</code></dd>
</dl>

<h2 id="NT">Grammar for NT (Named Types)</h2>
A language that introduces named structural and nominal types.

**Inherited from Λ:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>Label</code>, 
<code>Symbol</code>
<dl>
	<dt><code>NT.Program</code></dt>
	<dd><code>(Result, <strong>functions:</strong> [Function])</code></dd>
</dl>
<dl>
	<dt><code>NT.Effect</code></dt>
	<dd><code><strong>do</strong>([Effect])</code></dd>
	<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Effect)</code></dd>
	<dd><code><strong>setField</strong>(Field.Name, <strong>of:</strong> Value, <strong>to:</strong> Value)</code></dd>
	<dd><code><strong>setElement</strong>(<strong>of:</strong> Value, <strong>at:</strong> Value, <strong>to:</strong> Value)</code></dd>
</dl>
<dl>
	<dt><code>NT.GlobalDeclaration</code></dt>
</dl>
<dl>
	<dt><code>NT.CapabilityType</code></dt>
	<dd><code><strong>vector</strong>(<strong>of:</strong> ValueType, <strong>sealed:</strong> Bool)</code></dd>
	<dd><code><strong>record</strong>(RecordType, <strong>sealed:</strong> Bool)</code></dd>
	<dd><code><strong>procedure</strong>(<strong>takes:</strong> [Parameter], <strong>returns:</strong> ValueType)</code></dd>
	<dd><code><strong>seal</strong>(<strong>sealed:</strong> Bool)</code></dd>
</dl>
<dl>
	<dt><code>NT.Result</code></dt>
	<dd><code><strong>value</strong>(Value)</code></dd>
	<dd><code><strong>evaluate</strong>(Value, [Value])</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Result, <strong>else:</strong> Result)</code></dd>
	<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Result)</code></dd>
	<dd><code><strong>do</strong>([Effect], <strong>then:</strong> Result)</code></dd>
</dl>
<dl>
	<dt><code>NT.TypeDefinition</code></dt>
	<dd><code><strong>structural</strong>(TypeName, ValueType)</code></dd>
	<dd><code><strong>nominal</strong>(TypeName, ValueType)</code></dd>
</dl>
<dl>
	<dt><code>NT.Value</code></dt>
	<dd><code><strong>constant</strong>(Int)</code></dd>
	<dd><code><strong>named</strong>(Symbol)</code></dd>
	<dd><code><strong>record</strong>(RecordType)</code></dd>
	<dd><code><strong>field</strong>(Field.Name, <strong>of:</strong> Value)</code></dd>
	<dd><code><strong>vector</strong>(ValueType, <strong>count:</strong> Int)</code></dd>
	<dd><code><strong>element</strong>(<strong>of:</strong> Value, <strong>at:</strong> Value)</code></dd>
	<dd><code><strong>λ</strong>(<strong>takes:</strong> [Parameter], <strong>returns:</strong> ValueType, <strong>in:</strong> Result)</code></dd>
	<dd><code><strong>function</strong>(Label)</code></dd>
	<dd><code><strong>seal</strong></code></dd>
	<dd><code><strong>sealed</strong>(Value, <strong>with:</strong> Value)</code></dd>
	<dd><code><strong>binary</strong>(Value, BinaryOperator, Value)</code></dd>
	<dd><code><strong>evaluate</strong>(Value, [Value])</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Value, <strong>else:</strong> Value)</code></dd>
	<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Value)</code></dd>
	<dd><code><strong>letType</strong>([TypeDefinition], <strong>in:</strong> Value)</code></dd>
	<dd><code><strong>do</strong>([Effect], <strong>then:</strong> Value)</code></dd>
</dl>
<dl>
	<dt><code>NT.Definition</code></dt>
	<dd><code>(Symbol, Value)</code></dd>
</dl>
<dl>
	<dt><code>NT.RecordType</code></dt>
	<dd><code>([Field])</code></dd>
</dl>
<dl>
	<dt><code>NT.Field</code></dt>
	<dd><code>(Name, ValueType)</code></dd>
</dl>
<dl>
	<dt><code>NT.TypeName</code></dt>
	<dd><code>String</code></dd>
</dl>
<dl>
	<dt><code>NT.Function</code></dt>
	<dd><code>(Label, <strong>takes:</strong> [Parameter], <strong>returns:</strong> ValueType, <strong>in:</strong> Result)</code></dd>
</dl>
<dl>
	<dt><code>NT.ValueType</code></dt>
	<dd><code><strong>named</strong>(TypeName)</code></dd>
	<dd><code><strong>u8</strong></code></dd>
	<dd><code><strong>s32</strong></code></dd>
	<dd><code><strong>cap</strong>(CapabilityType)</code></dd>
</dl>
<dl>
	<dt><code>NT.Predicate</code></dt>
	<dd><code><strong>constant</strong>(Bool)</code></dd>
	<dd><code><strong>relation</strong>(Value, BranchRelation, Value)</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Predicate, <strong>else:</strong> Predicate)</code></dd>
	<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Predicate)</code></dd>
</dl>
<dl>
	<dt><code>NT.Parameter</code></dt>
	<dd><code>(Symbol, ValueType, <strong>sealed:</strong> Bool)</code></dd>
</dl>

<h2 id="Λ">Grammar for Λ (Lambdas)</h2>
A language that introduces anonymous functions and function values.

**Inherited from EX:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>CapabilityType</code>, 
<code>Field</code>, 
<code>Label</code>, 
<code>Parameter</code>, 
<code>RecordType</code>, 
<code>Symbol</code>, 
<code>ValueType</code>
<dl>
	<dt><code>Λ.Program</code></dt>
	<dd><code>(Result, <strong>functions:</strong> [Function])</code></dd>
</dl>
<dl>
	<dt><code>Λ.Value</code></dt>
	<dd><code><strong>constant</strong>(Int)</code></dd>
	<dd><code><strong>named</strong>(Symbol)</code></dd>
	<dd><code><strong>record</strong>(RecordType)</code></dd>
	<dd><code><strong>field</strong>(Field.Name, <strong>of:</strong> Value)</code></dd>
	<dd><code><strong>vector</strong>(ValueType, <strong>count:</strong> Int)</code></dd>
	<dd><code><strong>element</strong>(<strong>of:</strong> Value, <strong>at:</strong> Value)</code></dd>
	<dd><code><strong>λ</strong>(<strong>takes:</strong> [Parameter], <strong>returns:</strong> ValueType, <strong>in:</strong> Result)</code></dd>
	<dd><code><strong>function</strong>(Label)</code></dd>
	<dd><code><strong>seal</strong></code></dd>
	<dd><code><strong>sealed</strong>(Value, <strong>with:</strong> Value)</code></dd>
	<dd><code><strong>binary</strong>(Value, BinaryOperator, Value)</code></dd>
	<dd><code><strong>evaluate</strong>(Value, [Value])</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Value, <strong>else:</strong> Value)</code></dd>
	<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Value)</code></dd>
	<dd><code><strong>do</strong>([Effect], <strong>then:</strong> Value)</code></dd>
</dl>
<dl>
	<dt><code>Λ.Predicate</code></dt>
	<dd><code><strong>constant</strong>(Bool)</code></dd>
	<dd><code><strong>relation</strong>(Value, BranchRelation, Value)</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Predicate, <strong>else:</strong> Predicate)</code></dd>
	<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Predicate)</code></dd>
</dl>
<dl>
	<dt><code>Λ.Effect</code></dt>
	<dd><code><strong>do</strong>([Effect])</code></dd>
	<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Effect)</code></dd>
	<dd><code><strong>setField</strong>(Field.Name, <strong>of:</strong> Value, <strong>to:</strong> Value)</code></dd>
	<dd><code><strong>setElement</strong>(<strong>of:</strong> Value, <strong>at:</strong> Value, <strong>to:</strong> Value)</code></dd>
</dl>
<dl>
	<dt><code>Λ.Function</code></dt>
	<dd><code>(Label, <strong>takes:</strong> [Parameter], <strong>returns:</strong> ValueType, <strong>in:</strong> Result)</code></dd>
</dl>
<dl>
	<dt><code>Λ.Result</code></dt>
	<dd><code><strong>value</strong>(Value)</code></dd>
	<dd><code><strong>evaluate</strong>(Value, [Value])</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Result, <strong>else:</strong> Result)</code></dd>
	<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Result)</code></dd>
	<dd><code><strong>do</strong>([Effect], <strong>then:</strong> Result)</code></dd>
</dl>
<dl>
	<dt><code>Λ.Definition</code></dt>
	<dd><code>(Symbol, Value)</code></dd>
</dl>

<h2 id="EX">Grammar for EX (Expressions)</h2>
A language that introduces expression semantics for values, thereby abstracting over computation effects.

**Inherited from LS:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>CapabilityType</code>, 
<code>Field</code>, 
<code>Label</code>, 
<code>Parameter</code>, 
<code>RecordType</code>, 
<code>Symbol</code>, 
<code>ValueType</code>
<dl>
	<dt><code>EX.Program</code></dt>
	<dd><code>(Result, <strong>functions:</strong> [Function])</code></dd>
</dl>
<dl>
	<dt><code>EX.Value</code></dt>
	<dd><code><strong>constant</strong>(Int)</code></dd>
	<dd><code><strong>named</strong>(Symbol)</code></dd>
	<dd><code><strong>record</strong>(RecordType)</code></dd>
	<dd><code><strong>field</strong>(Field.Name, <strong>of:</strong> Value)</code></dd>
	<dd><code><strong>vector</strong>(ValueType, <strong>count:</strong> Int)</code></dd>
	<dd><code><strong>element</strong>(<strong>of:</strong> Value, <strong>at:</strong> Value)</code></dd>
	<dd><code><strong>function</strong>(Label)</code></dd>
	<dd><code><strong>seal</strong></code></dd>
	<dd><code><strong>sealed</strong>(Value, <strong>with:</strong> Value)</code></dd>
	<dd><code><strong>binary</strong>(Value, BinaryOperator, Value)</code></dd>
	<dd><code><strong>evaluate</strong>(Value, [Value])</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Value, <strong>else:</strong> Value)</code></dd>
	<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Value)</code></dd>
	<dd><code><strong>do</strong>([Effect], <strong>then:</strong> Value)</code></dd>
</dl>
<dl>
	<dt><code>EX.Definition</code></dt>
	<dd><code>(Symbol, Value)</code></dd>
</dl>
<dl>
	<dt><code>EX.Predicate</code></dt>
	<dd><code><strong>constant</strong>(Bool)</code></dd>
	<dd><code><strong>relation</strong>(Value, BranchRelation, Value)</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Predicate, <strong>else:</strong> Predicate)</code></dd>
	<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Predicate)</code></dd>
</dl>
<dl>
	<dt><code>EX.Function</code></dt>
	<dd><code>(Label, <strong>takes:</strong> [Parameter], <strong>returns:</strong> ValueType, <strong>in:</strong> Result)</code></dd>
</dl>
<dl>
	<dt><code>EX.Effect</code></dt>
	<dd><code><strong>do</strong>([Effect])</code></dd>
	<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Effect)</code></dd>
	<dd><code><strong>setField</strong>(Field.Name, <strong>of:</strong> Value, <strong>to:</strong> Value)</code></dd>
	<dd><code><strong>setElement</strong>(<strong>of:</strong> Value, <strong>at:</strong> Value, <strong>to:</strong> Value)</code></dd>
</dl>
<dl>
	<dt><code>EX.Result</code></dt>
	<dd><code><strong>value</strong>(Value)</code></dd>
	<dd><code><strong>evaluate</strong>(Value, [Value])</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Result, <strong>else:</strong> Result)</code></dd>
	<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Result)</code></dd>
	<dd><code><strong>do</strong>([Effect], <strong>then:</strong> Result)</code></dd>
</dl>

<h2 id="LS">Grammar for LS (Lexical Scopes)</h2>
A language that introduces lexical scopes of definitions, thereby removing name clashes.

**Inherited from DF:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>Label</code>
<dl>
	<dt><code>LS.Program</code></dt>
	<dd><code>(Result, <strong>functions:</strong> [Function])</code></dd>
</dl>
<dl>
	<dt><code>LS.Symbol</code></dt>
	<dd><code>String</code></dd>
</dl>
<dl>
	<dt><code>LS.Predicate</code></dt>
	<dd><code><strong>constant</strong>(Bool)</code></dd>
	<dd><code><strong>relation</strong>(Source, BranchRelation, Source)</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Predicate, <strong>else:</strong> Predicate)</code></dd>
	<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Predicate)</code></dd>
</dl>
<dl>
	<dt><code>LS.Parameter</code></dt>
	<dd><code>(Symbol, ValueType, <strong>sealed:</strong> Bool)</code></dd>
</dl>
<dl>
	<dt><code>LS.ValueType</code></dt>
	<dd><code><strong>u8</strong></code></dd>
	<dd><code><strong>s32</strong></code></dd>
	<dd><code><strong>cap</strong>(CapabilityType)</code></dd>
</dl>
<dl>
	<dt><code>LS.Value</code></dt>
	<dd><code><strong>source</strong>(Source)</code></dd>
	<dd><code><strong>binary</strong>(Source, BinaryOperator, Source)</code></dd>
	<dd><code><strong>record</strong>(RecordType)</code></dd>
	<dd><code><strong>field</strong>(Field.Name, <strong>of:</strong> Symbol)</code></dd>
	<dd><code><strong>vector</strong>(ValueType, <strong>count:</strong> Int)</code></dd>
	<dd><code><strong>element</strong>(<strong>of:</strong> Symbol, <strong>at:</strong> Source)</code></dd>
	<dd><code><strong>seal</strong></code></dd>
	<dd><code><strong>sealed</strong>(Symbol, <strong>with:</strong> Symbol)</code></dd>
	<dd><code><strong>evaluate</strong>(Source, [Source])</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Value, <strong>else:</strong> Value)</code></dd>
	<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Value)</code></dd>
	<dd><code><strong>do</strong>([Effect], <strong>then:</strong> Value)</code></dd>
</dl>
<dl>
	<dt><code>LS.Function</code></dt>
	<dd><code>(Label, <strong>takes:</strong> [Parameter], <strong>returns:</strong> ValueType, <strong>in:</strong> Result)</code></dd>
</dl>
<dl>
	<dt><code>LS.CapabilityType</code></dt>
	<dd><code><strong>vector</strong>(<strong>of:</strong> ValueType, <strong>sealed:</strong> Bool)</code></dd>
	<dd><code><strong>record</strong>(RecordType, <strong>sealed:</strong> Bool)</code></dd>
	<dd><code><strong>procedure</strong>(<strong>takes:</strong> [Parameter], <strong>returns:</strong> ValueType)</code></dd>
	<dd><code><strong>seal</strong>(<strong>sealed:</strong> Bool)</code></dd>
</dl>
<dl>
	<dt><code>LS.Source</code></dt>
	<dd><code><strong>constant</strong>(Int)</code></dd>
	<dd><code><strong>named</strong>(Symbol)</code></dd>
	<dd><code><strong>function</strong>(Label)</code></dd>
</dl>
<dl>
	<dt><code>LS.Definition</code></dt>
	<dd><code>(Symbol, Value)</code></dd>
</dl>
<dl>
	<dt><code>LS.Effect</code></dt>
	<dd><code><strong>do</strong>([Effect])</code></dd>
	<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Effect)</code></dd>
	<dd><code><strong>setField</strong>(Field.Name, <strong>of:</strong> Symbol, <strong>to:</strong> Source)</code></dd>
	<dd><code><strong>setElement</strong>(<strong>of:</strong> Symbol, <strong>at:</strong> Source, <strong>to:</strong> Source)</code></dd>
</dl>
<dl>
	<dt><code>LS.Result</code></dt>
	<dd><code><strong>value</strong>(Value)</code></dd>
	<dd><code><strong>evaluate</strong>(Source, [Source])</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Result, <strong>else:</strong> Result)</code></dd>
	<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Result)</code></dd>
	<dd><code><strong>do</strong>([Effect], <strong>then:</strong> Result)</code></dd>
</dl>
<dl>
	<dt><code>LS.RecordType</code></dt>
	<dd><code>([Field])</code></dd>
</dl>
<dl>
	<dt><code>LS.Field</code></dt>
	<dd><code>(Name, ValueType)</code></dd>
</dl>

<h2 id="DF">Grammar for DF (Definitions)</h2>
A language that introduces definitions with function-wide namespacing.

**Inherited from CV:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>CapabilityType</code>, 
<code>Field</code>, 
<code>Label</code>, 
<code>Location</code>, 
<code>Parameter</code>, 
<code>RecordType</code>, 
<code>Source</code>, 
<code>ValueType</code>
<dl>
	<dt><code>DF.Program</code></dt>
	<dd><code>(Result, <strong>functions:</strong> [Function])</code></dd>
</dl>
<dl>
	<dt><code>DF.Effect</code></dt>
	<dd><code><strong>do</strong>([Effect])</code></dd>
	<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Effect)</code></dd>
	<dd><code><strong>setField</strong>(Field.Name, <strong>of:</strong> Location, <strong>to:</strong> Source)</code></dd>
	<dd><code><strong>setElement</strong>(<strong>of:</strong> Location, <strong>at:</strong> Source, <strong>to:</strong> Source)</code></dd>
</dl>
<dl>
	<dt><code>DF.Result</code></dt>
	<dd><code><strong>value</strong>(Value)</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Result, <strong>else:</strong> Result)</code></dd>
	<dd><code><strong>evaluate</strong>(Source, [Source])</code></dd>
	<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Result)</code></dd>
	<dd><code><strong>do</strong>([Effect], <strong>then:</strong> Result)</code></dd>
</dl>
<dl>
	<dt><code>DF.Definition</code></dt>
	<dd><code>(Location, Value)</code></dd>
</dl>
<dl>
	<dt><code>DF.Predicate</code></dt>
	<dd><code><strong>constant</strong>(Bool)</code></dd>
	<dd><code><strong>relation</strong>(Source, BranchRelation, Source)</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Predicate, <strong>else:</strong> Predicate)</code></dd>
	<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Predicate)</code></dd>
</dl>
<dl>
	<dt><code>DF.Value</code></dt>
	<dd><code><strong>source</strong>(Source)</code></dd>
	<dd><code><strong>binary</strong>(Source, BinaryOperator, Source)</code></dd>
	<dd><code><strong>record</strong>(RecordType)</code></dd>
	<dd><code><strong>field</strong>(Field.Name, <strong>of:</strong> Location)</code></dd>
	<dd><code><strong>vector</strong>(ValueType, <strong>count:</strong> Int)</code></dd>
	<dd><code><strong>element</strong>(<strong>of:</strong> Location, <strong>at:</strong> Source)</code></dd>
	<dd><code><strong>seal</strong></code></dd>
	<dd><code><strong>sealed</strong>(Location, <strong>with:</strong> Location)</code></dd>
	<dd><code><strong>evaluate</strong>(Source, [Source])</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Value, <strong>else:</strong> Value)</code></dd>
	<dd><code><strong>let</strong>([Definition], <strong>in:</strong> Value)</code></dd>
	<dd><code><strong>do</strong>([Effect], <strong>then:</strong> Value)</code></dd>
</dl>
<dl>
	<dt><code>DF.Function</code></dt>
	<dd><code>(Label, <strong>takes:</strong> [Parameter], <strong>returns:</strong> ValueType, <strong>in:</strong> Result)</code></dd>
</dl>

<h2 id="CV">Grammar for CV (Computed Values)</h2>
A language that allows a computation to be attached to a value.

**Inherited from CA:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>CapabilityType</code>, 
<code>Context</code>, 
<code>Field</code>, 
<code>Label</code>, 
<code>Location</code>, 
<code>Parameter</code>, 
<code>RecordType</code>, 
<code>Source</code>, 
<code>ValueType</code>
<dl>
	<dt><code>CV.Program</code></dt>
	<dd><code>(Effect, <strong>procedures:</strong> [Procedure])</code></dd>
</dl>
<dl>
	<dt><code>CV.Predicate</code></dt>
	<dd><code><strong>constant</strong>(Bool)</code></dd>
	<dd><code><strong>relation</strong>(Source, BranchRelation, Source)</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Predicate, <strong>else:</strong> Predicate)</code></dd>
	<dd><code><strong>do</strong>([Effect], <strong>then:</strong> Predicate)</code></dd>
</dl>
<dl>
	<dt><code>CV.Effect</code></dt>
	<dd><code><strong>do</strong>([Effect])</code></dd>
	<dd><code><strong>set</strong>(Location, <strong>to:</strong> Value)</code></dd>
	<dd><code><strong>setField</strong>(Field.Name, <strong>of:</strong> Location, <strong>to:</strong> Source)</code></dd>
	<dd><code><strong>setElement</strong>(<strong>of:</strong> Location, <strong>at:</strong> Source, <strong>to:</strong> Source)</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Effect, <strong>else:</strong> Effect)</code></dd>
	<dd><code><strong>return</strong>(Source)</code></dd>
</dl>
<dl>
	<dt><code>CV.Procedure</code></dt>
	<dd><code>(Label, <strong>takes:</strong> [Parameter], <strong>returns:</strong> ValueType, <strong>in:</strong> Effect)</code></dd>
</dl>
<dl>
	<dt><code>CV.Value</code></dt>
	<dd><code><strong>source</strong>(Source)</code></dd>
	<dd><code><strong>binary</strong>(Source, BinaryOperator, Source)</code></dd>
	<dd><code><strong>record</strong>(RecordType)</code></dd>
	<dd><code><strong>field</strong>(Field.Name, <strong>of:</strong> Location)</code></dd>
	<dd><code><strong>vector</strong>(ValueType, <strong>count:</strong> Int)</code></dd>
	<dd><code><strong>element</strong>(<strong>of:</strong> Location, <strong>at:</strong> Source)</code></dd>
	<dd><code><strong>seal</strong></code></dd>
	<dd><code><strong>sealed</strong>(Location, <strong>with:</strong> Location)</code></dd>
	<dd><code><strong>evaluate</strong>(Source, [Source])</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Value, <strong>else:</strong> Value)</code></dd>
	<dd><code><strong>do</strong>([Effect], <strong>then:</strong> Value)</code></dd>
</dl>

<h2 id="CA">Grammar for CA (Canonical Assignments)</h2>
A language that groups all effects that write to a location under one canonical assignment effect.

**Inherited from CC:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>CapabilityType</code>, 
<code>Context</code>, 
<code>Field</code>, 
<code>Label</code>, 
<code>Location</code>, 
<code>Parameter</code>, 
<code>RecordType</code>, 
<code>Source</code>, 
<code>ValueType</code>
<dl>
	<dt><code>CA.Program</code></dt>
	<dd><code>(Effect, <strong>procedures:</strong> [Procedure])</code></dd>
</dl>
<dl>
	<dt><code>CA.Procedure</code></dt>
	<dd><code>(Label, <strong>takes:</strong> [Parameter], <strong>returns:</strong> ValueType, <strong>in:</strong> Effect)</code></dd>
</dl>
<dl>
	<dt><code>CA.Effect</code></dt>
	<dd><code><strong>do</strong>([Effect])</code></dd>
	<dd><code><strong>set</strong>(Location, <strong>to:</strong> Value)</code></dd>
	<dd><code><strong>setField</strong>(Field.Name, <strong>of:</strong> Location, <strong>to:</strong> Source)</code></dd>
	<dd><code><strong>setElement</strong>(<strong>of:</strong> Location, <strong>at:</strong> Source, <strong>to:</strong> Source)</code></dd>
	<dd><code><strong>call</strong>(Source, [Source], <strong>result:</strong> Location)</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Effect, <strong>else:</strong> Effect)</code></dd>
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
	<dt><code>CA.Value</code></dt>
	<dd><code><strong>source</strong>(Source)</code></dd>
	<dd><code><strong>binary</strong>(Source, BinaryOperator, Source)</code></dd>
	<dd><code><strong>record</strong>(RecordType)</code></dd>
	<dd><code><strong>field</strong>(Field.Name, <strong>of:</strong> Location)</code></dd>
	<dd><code><strong>vector</strong>(ValueType, <strong>count:</strong> Int)</code></dd>
	<dd><code><strong>element</strong>(<strong>of:</strong> Location, <strong>at:</strong> Source)</code></dd>
	<dd><code><strong>seal</strong></code></dd>
	<dd><code><strong>sealed</strong>(Location, <strong>with:</strong> Location)</code></dd>
</dl>

<h2 id="CC">Grammar for CC (Calling Convention)</h2>
A language that introduces parameters & result values in procedures via the low-level Glyco calling convention.

**Inherited from SV:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>Label</code>, 
<code>Location</code>
<dl>
	<dt><code>CC.Program</code></dt>
	<dd><code>(Effect, <strong>procedures:</strong> [Procedure])</code></dd>
</dl>
<dl>
	<dt><code>CC.CapabilityType</code></dt>
	<dd><code><strong>vector</strong>(<strong>of:</strong> ValueType, <strong>sealed:</strong> Bool)</code></dd>
	<dd><code><strong>record</strong>(RecordType, <strong>sealed:</strong> Bool)</code></dd>
	<dd><code><strong>procedure</strong>(<strong>takes:</strong> [Parameter], <strong>returns:</strong> ValueType)</code></dd>
	<dd><code><strong>seal</strong>(<strong>sealed:</strong> Bool)</code></dd>
</dl>
<dl>
	<dt><code>CC.RecordType</code></dt>
	<dd><code>([Field])</code></dd>
</dl>
<dl>
	<dt><code>CC.Field</code></dt>
	<dd><code>(Name, ValueType)</code></dd>
</dl>
<dl>
	<dt><code>CC.Parameter</code></dt>
	<dd><code>(Location, ValueType, <strong>sealed:</strong> Bool)</code></dd>
</dl>
<dl>
	<dt><code>CC.Predicate</code></dt>
	<dd><code><strong>constant</strong>(Bool)</code></dd>
	<dd><code><strong>relation</strong>(Source, BranchRelation, Source)</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Predicate, <strong>else:</strong> Predicate)</code></dd>
	<dd><code><strong>do</strong>([Effect], <strong>then:</strong> Predicate)</code></dd>
</dl>
<dl>
	<dt><code>CC.Source</code></dt>
	<dd><code><strong>constant</strong>(Int)</code></dd>
	<dd><code><strong>location</strong>(Location)</code></dd>
	<dd><code><strong>procedure</strong>(Label)</code></dd>
</dl>
<dl>
	<dt><code>CC.Effect</code></dt>
	<dd><code><strong>do</strong>([Effect])</code></dd>
	<dd><code><strong>set</strong>(Location, <strong>to:</strong> Source)</code></dd>
	<dd><code><strong>compute</strong>(Location, Source, BinaryOperator, Source)</code></dd>
	<dd><code><strong>createRecord</strong>(RecordType, <strong>capability:</strong> Location, <strong>scoped:</strong> Bool)</code></dd>
	<dd><code><strong>getField</strong>(Field.Name, <strong>of:</strong> Location, <strong>to:</strong> Location)</code></dd>
	<dd><code><strong>setField</strong>(Field.Name, <strong>of:</strong> Location, <strong>to:</strong> Source)</code></dd>
	<dd><code><strong>createVector</strong>(ValueType, <strong>count:</strong> Int, <strong>capability:</strong> Location, <strong>scoped:</strong> Bool)</code></dd>
	<dd><code><strong>getElement</strong>(<strong>of:</strong> Location, <strong>index:</strong> Source, <strong>to:</strong> Location)</code></dd>
	<dd><code><strong>setElement</strong>(<strong>of:</strong> Location, <strong>index:</strong> Source, <strong>to:</strong> Source)</code></dd>
	<dd><code><strong>createSeal</strong>(<strong>in:</strong> Location)</code></dd>
	<dd><code><strong>seal</strong>(<strong>into:</strong> Location, <strong>source:</strong> Location, <strong>seal:</strong> Location)</code></dd>
	<dd><code><strong>destroyScopedValue</strong>(<strong>capability:</strong> Source)</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Effect, <strong>else:</strong> Effect)</code></dd>
	<dd><code><strong>call</strong>(Source, [Source], <strong>result:</strong> Location)</code></dd>
	<dd><code><strong>return</strong>(Source)</code></dd>
</dl>
<dl>
	<dt><code>CC.ValueType</code></dt>
	<dd><code><strong>u8</strong></code></dd>
	<dd><code><strong>s32</strong></code></dd>
	<dd><code><strong>cap</strong>(CapabilityType)</code></dd>
</dl>
<dl>
	<dt><code>CC.Procedure</code></dt>
	<dd><code>(Label, <strong>takes:</strong> [Parameter], <strong>returns:</strong> ValueType, <strong>in:</strong> Effect)</code></dd>
</dl>

<h2 id="SV">Grammar for SV (Structured Values)</h2>
A language that introduces structured values, i.e., vectors and records.

**Inherited from ID:**
<code>AbstractLocation</code>, 
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>Frame</code>, 
<code>Label</code>, 
<code>Location</code>, 
<code>Register</code>
<dl>
	<dt><code>SV.Program</code></dt>
	<dd><code>(Effect, <strong>procedures:</strong> [Procedure])</code></dd>
</dl>
<dl>
	<dt><code>SV.ValueType</code></dt>
	<dd><code><strong>u8</strong></code></dd>
	<dd><code><strong>s32</strong></code></dd>
	<dd><code><strong>cap</strong>(CapabilityType)</code></dd>
	<dd><code><strong>registerDatum</strong></code></dd>
</dl>
<dl>
	<dt><code>SV.Source</code></dt>
	<dd><code><strong>constant</strong>(Int)</code></dd>
	<dd><code><strong>abstract</strong>(AbstractLocation)</code></dd>
	<dd><code><strong>register</strong>(Register, ValueType)</code></dd>
	<dd><code><strong>frame</strong>(Frame.Location)</code></dd>
	<dd><code><strong>capability</strong>(<strong>to:</strong> Label)</code></dd>
</dl>
<dl>
	<dt><code>SV.Effect</code></dt>
	<dd><code><strong>do</strong>([Effect])</code></dd>
	<dd><code><strong>set</strong>(Location, <strong>to:</strong> Source)</code></dd>
	<dd><code><strong>compute</strong>(Location, Source, BinaryOperator, Source)</code></dd>
	<dd><code><strong>createRecord</strong>(RecordType, <strong>capability:</strong> Location, <strong>scoped:</strong> Bool)</code></dd>
	<dd><code><strong>getField</strong>(Field.Name, <strong>of:</strong> Location, <strong>to:</strong> Location)</code></dd>
	<dd><code><strong>setField</strong>(Field.Name, <strong>of:</strong> Location, <strong>to:</strong> Source)</code></dd>
	<dd><code><strong>createVector</strong>(ValueType, <strong>count:</strong> Int, <strong>capability:</strong> Location, <strong>scoped:</strong> Bool)</code></dd>
	<dd><code><strong>getElement</strong>(<strong>of:</strong> Location, <strong>index:</strong> Source, <strong>to:</strong> Location)</code></dd>
	<dd><code><strong>setElement</strong>(<strong>of:</strong> Location, <strong>index:</strong> Source, <strong>to:</strong> Source)</code></dd>
	<dd><code><strong>destroyScopedValue</strong>(<strong>capability:</strong> Source)</code></dd>
	<dd><code><strong>createSeal</strong>(<strong>in:</strong> Location)</code></dd>
	<dd><code><strong>seal</strong>(<strong>into:</strong> Location, <strong>source:</strong> Location, <strong>seal:</strong> Location)</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Effect, <strong>else:</strong> Effect)</code></dd>
	<dd><code><strong>pushScope</strong></code></dd>
	<dd><code><strong>popScope</strong></code></dd>
	<dd><code><strong>clearAll</strong>(<strong>except:</strong> [Register])</code></dd>
	<dd><code><strong>call</strong>(Source, <strong>parameters:</strong> [Register])</code></dd>
	<dd><code><strong>callSealed</strong>(Source, <strong>data:</strong> Source, <strong>unsealedParameters:</strong> [Register])</code></dd>
	<dd><code><strong>return</strong>(<strong>to:</strong> Source)</code></dd>
</dl>
<dl>
	<dt><code>SV.CapabilityType</code></dt>
	<dd><code><strong>vector</strong>(<strong>of:</strong> ValueType, <strong>sealed:</strong> Bool)</code></dd>
	<dd><code><strong>record</strong>(RecordType, <strong>sealed:</strong> Bool)</code></dd>
	<dd><code><strong>code</strong></code></dd>
	<dd><code><strong>seal</strong>(<strong>sealed:</strong> Bool)</code></dd>
</dl>
<dl>
	<dt><code>SV.RecordType</code></dt>
	<dd><code>([Field])</code></dd>
</dl>
<dl>
	<dt><code>SV.Field</code></dt>
	<dd><code>(Name, ValueType)</code></dd>
</dl>
<dl>
	<dt><code>SV.Predicate</code></dt>
	<dd><code><strong>constant</strong>(Bool)</code></dd>
	<dd><code><strong>relation</strong>(Source, BranchRelation, Source)</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Predicate, <strong>else:</strong> Predicate)</code></dd>
	<dd><code><strong>do</strong>([Effect], <strong>then:</strong> Predicate)</code></dd>
</dl>
<dl>
	<dt><code>SV.Procedure</code></dt>
	<dd><code>(Label, <strong>in:</strong> Effect)</code></dd>
</dl>

<h2 id="ID">Grammar for ID (Inferred Declarations)</h2>
A language that infers declarations from definitions.

**Inherited from AL:**
<code>AbstractLocation</code>, 
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>DataType</code>, 
<code>Declarations</code>, 
<code>Frame</code>, 
<code>Label</code>, 
<code>Location</code>, 
<code>Register</code>, 
<code>Source</code>
<dl>
	<dt><code>ID.Program</code></dt>
	<dd><code>(Effect, <strong>procedures:</strong> [Procedure])</code></dd>
</dl>
<dl>
	<dt><code>ID.Procedure</code></dt>
	<dd><code>(Label, <strong>in:</strong> Effect)</code></dd>
</dl>
<dl>
	<dt><code>ID.Effect</code></dt>
	<dd><code><strong>do</strong>([Effect])</code></dd>
	<dd><code><strong>set</strong>(Location, <strong>to:</strong> Source)</code></dd>
	<dd><code><strong>compute</strong>(Location, Source, BinaryOperator, Source)</code></dd>
	<dd><code><strong>createBuffer</strong>(<strong>bytes:</strong> Int, <strong>capability:</strong> Location, <strong>scoped:</strong> Bool)</code></dd>
	<dd><code><strong>destroyBuffer</strong>(<strong>capability:</strong> Source)</code></dd>
	<dd><code><strong>getElement</strong>(DataType, <strong>of:</strong> Location, <strong>offset:</strong> Source, <strong>to:</strong> Location)</code></dd>
	<dd><code><strong>setElement</strong>(DataType, <strong>of:</strong> Location, <strong>offset:</strong> Source, <strong>to:</strong> Source)</code></dd>
	<dd><code><strong>createSeal</strong>(<strong>in:</strong> Location)</code></dd>
	<dd><code><strong>seal</strong>(<strong>into:</strong> Location, <strong>source:</strong> Location, <strong>seal:</strong> Location)</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Effect, <strong>else:</strong> Effect)</code></dd>
	<dd><code><strong>pushScope</strong></code></dd>
	<dd><code><strong>popScope</strong></code></dd>
	<dd><code><strong>clearAll</strong>(<strong>except:</strong> [Register])</code></dd>
	<dd><code><strong>call</strong>(Source, <strong>parameters:</strong> [Register])</code></dd>
	<dd><code><strong>callSealed</strong>(Source, <strong>data:</strong> Source, <strong>unsealedParameters:</strong> [Register])</code></dd>
	<dd><code><strong>return</strong>(<strong>to:</strong> Source)</code></dd>
</dl>
<dl>
	<dt><code>ID.Predicate</code></dt>
	<dd><code><strong>constant</strong>(Bool)</code></dd>
	<dd><code><strong>relation</strong>(Source, BranchRelation, Source)</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Predicate, <strong>else:</strong> Predicate)</code></dd>
	<dd><code><strong>do</strong>([Effect], <strong>then:</strong> Predicate)</code></dd>
</dl>

<h2 id="AL">Grammar for AL (Abstract Locations)</h2>
A language that introduces abstract locations, i.e., locations whose physical locations are not specified by the programmer.

**Inherited from ALA:**
<code>AbstractLocation</code>, 
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>Context</code>, 
<code>DataType</code>, 
<code>Declarations</code>, 
<code>Frame</code>, 
<code>Label</code>, 
<code>Location</code>, 
<code>Register</code>, 
<code>Source</code>
<dl>
	<dt><code>AL.Program</code></dt>
	<dd><code>(<strong>locals:</strong> Declarations, <strong>in:</strong> Effect, <strong>procedures:</strong> [Procedure])</code></dd>
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
	<dd><code>(Label, <strong>locals:</strong> Declarations, <strong>in:</strong> Effect)</code></dd>
</dl>
<dl>
	<dt><code>AL.Effect</code></dt>
	<dd><code><strong>do</strong>([Effect])</code></dd>
	<dd><code><strong>set</strong>(Location, <strong>to:</strong> Source)</code></dd>
	<dd><code><strong>compute</strong>(Location, Source, BinaryOperator, Source)</code></dd>
	<dd><code><strong>createBuffer</strong>(<strong>bytes:</strong> Int, <strong>capability:</strong> Location, <strong>scoped:</strong> Bool)</code></dd>
	<dd><code><strong>destroyBuffer</strong>(<strong>capability:</strong> Source)</code></dd>
	<dd><code><strong>getElement</strong>(DataType, <strong>of:</strong> Location, <strong>offset:</strong> Source, <strong>to:</strong> Location)</code></dd>
	<dd><code><strong>setElement</strong>(DataType, <strong>of:</strong> Location, <strong>offset:</strong> Source, <strong>to:</strong> Source)</code></dd>
	<dd><code><strong>createSeal</strong>(<strong>in:</strong> Location)</code></dd>
	<dd><code><strong>seal</strong>(<strong>into:</strong> Location, <strong>source:</strong> Location, <strong>seal:</strong> Location)</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Effect, <strong>else:</strong> Effect)</code></dd>
	<dd><code><strong>pushScope</strong></code></dd>
	<dd><code><strong>popScope</strong></code></dd>
	<dd><code><strong>clearAll</strong>(<strong>except:</strong> [Register])</code></dd>
	<dd><code><strong>call</strong>(Source, <strong>parameters:</strong> [Register])</code></dd>
	<dd><code><strong>callSealed</strong>(Source, <strong>data:</strong> Source, <strong>unsealedParameters:</strong> [Register])</code></dd>
	<dd><code><strong>return</strong>(<strong>to:</strong> Source)</code></dd>
</dl>

<h2 id="ALA">Grammar for ALA (Abstract Locations, Analysed)</h2>
A language that introduces abstract locations, annotated with liveness and conflict information.

**Inherited from CD:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>DataType</code>, 
<code>Frame</code>, 
<code>Label</code>, 
<code>Register</code>
<dl>
	<dt><code>ALA.Program</code></dt>
	<dd><code>(<strong>locals:</strong> Declarations, <strong>in:</strong> Effect, <strong>procedures:</strong> [Procedure])</code></dd>
</dl>
<dl>
	<dt><code>ALA.ConflictGraph</code></dt>
	<dd><code>([Conflict])</code></dd>
</dl>
<dl>
	<dt><code>ALA.Conflict</code></dt>
	<dd><code>(Location, Location)</code></dd>
</dl>
<dl>
	<dt><code>ALA.Declarations</code></dt>
	<dd><code>([Declaration])</code></dd>
</dl>
<dl>
	<dt><code>ALA.AbstractLocation</code></dt>
	<dd><code>String</code></dd>
</dl>
<dl>
	<dt><code>ALA.Predicate</code></dt>
	<dd><code><strong>constant</strong>(Bool, <strong>analysisAtEntry:</strong> Analysis)</code></dd>
	<dd><code><strong>relation</strong>(Source, BranchRelation, Source, <strong>analysisAtEntry:</strong> Analysis)</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Predicate, <strong>else:</strong> Predicate, <strong>analysisAtEntry:</strong> Analysis)</code></dd>
	<dd><code><strong>do</strong>([Effect], <strong>then:</strong> Predicate, <strong>analysisAtEntry:</strong> Analysis)</code></dd>
</dl>
<dl>
	<dt><code>ALA.Source</code></dt>
	<dd><code><strong>constant</strong>(Int)</code></dd>
	<dd><code><strong>abstract</strong>(AbstractLocation)</code></dd>
	<dd><code><strong>register</strong>(Register, DataType)</code></dd>
	<dd><code><strong>frame</strong>(Frame.Location)</code></dd>
	<dd><code><strong>capability</strong>(<strong>to:</strong> Label)</code></dd>
</dl>
<dl>
	<dt><code>ALA.Declaration</code></dt>
	<dd><code><strong>abstract</strong>(AbstractLocation, DataType)</code></dd>
	<dd><code><strong>frame</strong>(Frame.Location, DataType)</code></dd>
</dl>
<dl>
	<dt><code>ALA.Effect</code></dt>
	<dd><code><strong>do</strong>([Effect], <strong>analysisAtEntry:</strong> Analysis)</code></dd>
	<dd><code><strong>set</strong>(Location, <strong>to:</strong> Source, <strong>analysisAtEntry:</strong> Analysis)</code></dd>
	<dd><code><strong>compute</strong>(Location, Source, BinaryOperator, Source, <strong>analysisAtEntry:</strong> Analysis)</code></dd>
	<dd><code><strong>createBuffer</strong>(<strong>bytes:</strong> Int, <strong>capability:</strong> Location, <strong>scoped:</strong> Bool, <strong>analysisAtEntry:</strong> Analysis)</code></dd>
	<dd><code><strong>destroyBuffer</strong>(<strong>capability:</strong> Source, <strong>analysisAtEntry:</strong> Analysis)</code></dd>
	<dd><code><strong>getElement</strong>(DataType, <strong>of:</strong> Location, <strong>offset:</strong> Source, <strong>to:</strong> Location, <strong>analysisAtEntry:</strong> Analysis)</code></dd>
	<dd><code><strong>setElement</strong>(DataType, <strong>of:</strong> Location, <strong>offset:</strong> Source, <strong>to:</strong> Source, <strong>analysisAtEntry:</strong> Analysis)</code></dd>
	<dd><code><strong>createSeal</strong>(<strong>in:</strong> Location, <strong>analysisAtEntry:</strong> Analysis)</code></dd>
	<dd><code><strong>seal</strong>(<strong>into:</strong> Location, <strong>source:</strong> Location, <strong>seal:</strong> Location, <strong>analysisAtEntry:</strong> Analysis)</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Effect, <strong>else:</strong> Effect, <strong>analysisAtEntry:</strong> Analysis)</code></dd>
	<dd><code><strong>pushScope</strong>(<strong>analysisAtEntry:</strong> Analysis)</code></dd>
	<dd><code><strong>popScope</strong>(<strong>analysisAtEntry:</strong> Analysis)</code></dd>
	<dd><code><strong>clearAll</strong>(<strong>except:</strong> [Register], <strong>analysisAtEntry:</strong> Analysis)</code></dd>
	<dd><code><strong>call</strong>(Source, <strong>parameters:</strong> [Register], <strong>analysisAtEntry:</strong> Analysis)</code></dd>
	<dd><code><strong>callSealed</strong>(Source, <strong>data:</strong> Source, <strong>unsealedParameters:</strong> [Register], <strong>analysisAtEntry:</strong> Analysis)</code></dd>
	<dd><code><strong>return</strong>(<strong>to:</strong> Source, <strong>analysisAtEntry:</strong> Analysis)</code></dd>
</dl>
<dl>
	<dt><code>ALA.Location</code></dt>
	<dd><code><strong>abstract</strong>(AbstractLocation)</code></dd>
	<dd><code><strong>register</strong>(Register)</code></dd>
	<dd><code><strong>frame</strong>(Frame.Location)</code></dd>
</dl>
<dl>
	<dt><code>ALA.Procedure</code></dt>
	<dd><code>(Label, <strong>locals:</strong> Declarations, <strong>in:</strong> Effect)</code></dd>
</dl>
<dl>
	<dt><code>ALA.Analysis</code></dt>
	<dd><code>(<strong>conflicts:</strong> ConflictGraph, <strong>possiblyLiveLocations:</strong> Set<Location>)</code></dd>
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
	<dt><code>CD.Program</code></dt>
	<dd><code>(Effect, <strong>procedures:</strong> [Procedure])</code></dd>
</dl>
<dl>
	<dt><code>CD.Predicate</code></dt>
	<dd><code><strong>constant</strong>(Bool)</code></dd>
	<dd><code><strong>relation</strong>(Source, BranchRelation, Source)</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Predicate, <strong>else:</strong> Predicate)</code></dd>
	<dd><code><strong>do</strong>([Effect], <strong>then:</strong> Predicate)</code></dd>
</dl>
<dl>
	<dt><code>CD.Effect</code></dt>
	<dd><code><strong>do</strong>([Effect])</code></dd>
	<dd><code><strong>set</strong>(DataType, Location, <strong>to:</strong> Source)</code></dd>
	<dd><code><strong>compute</strong>(Location, Source, BinaryOperator, Source)</code></dd>
	<dd><code><strong>createBuffer</strong>(<strong>bytes:</strong> Int, <strong>capability:</strong> Location, <strong>onFrame:</strong> Bool)</code></dd>
	<dd><code><strong>destroyBuffer</strong>(<strong>capability:</strong> Source)</code></dd>
	<dd><code><strong>getElement</strong>(DataType, <strong>of:</strong> Location, <strong>offset:</strong> Source, <strong>to:</strong> Location)</code></dd>
	<dd><code><strong>setElement</strong>(DataType, <strong>of:</strong> Location, <strong>offset:</strong> Source, <strong>to:</strong> Source)</code></dd>
	<dd><code><strong>createSeal</strong>(<strong>in:</strong> Location)</code></dd>
	<dd><code><strong>seal</strong>(<strong>into:</strong> Location, <strong>source:</strong> Location, <strong>seal:</strong> Location)</code></dd>
	<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Effect, <strong>else:</strong> Effect)</code></dd>
	<dd><code><strong>pushFrame</strong>(Frame)</code></dd>
	<dd><code><strong>popFrame</strong></code></dd>
	<dd><code><strong>clearAll</strong>(<strong>except:</strong> [Register])</code></dd>
	<dd><code><strong>call</strong>(Source)</code></dd>
	<dd><code><strong>callSealed</strong>(Source, <strong>data:</strong> Source)</code></dd>
	<dd><code><strong>return</strong>(<strong>to:</strong> Source)</code></dd>
</dl>
<dl>
	<dt><code>CD.Procedure</code></dt>
	<dd><code>(Label, <strong>in:</strong> Effect)</code></dd>
</dl>

<h2 id="PR">Grammar for PR (Predicates)</h2>
A language that introduces predicates in branches.

**Inherited from BB:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>Context</code>, 
<code>DataType</code>, 
<code>Effect</code>, 
<code>Frame</code>, 
<code>Label</code>, 
<code>Location</code>, 
<code>Register</code>, 
<code>Source</code>
<dl>
	<dt><code>PR.Program</code></dt>
	<dd><code>([Block])</code></dd>
</dl>
<dl>
	<dt><code>PR.Block</code></dt>
	<dd><code>(<strong>name:</strong> Label, <strong>do:</strong> [Effect], <strong>then:</strong> Continuation)</code></dd>
</dl>
<dl>
	<dt><code>PR.Continuation</code></dt>
	<dd><code><strong>continue</strong>(<strong>to:</strong> Label)</code></dd>
	<dd><code><strong>branch</strong>(<strong>if:</strong> Predicate, <strong>then:</strong> Label, <strong>else:</strong> Label)</code></dd>
	<dd><code><strong>call</strong>(Source, <strong>returnPoint:</strong> Label)</code></dd>
	<dd><code><strong>callSealed</strong>(Source, <strong>data:</strong> Source, <strong>returnPoint:</strong> Label)</code></dd>
	<dd><code><strong>return</strong>(<strong>to:</strong> Source)</code></dd>
</dl>
<dl>
	<dt><code>PR.Predicate</code></dt>
	<dd><code><strong>constant</strong>(Bool)</code></dd>
	<dd><code><strong>relation</strong>(Source, BranchRelation, Source)</code></dd>
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
	<dt><code>BB.Program</code></dt>
	<dd><code>([BB.Block])</code></dd>
</dl>
<dl>
	<dt><code>BB.Effect</code></dt>
	<dd><code><strong>set</strong>(DataType, Location, <strong>to:</strong> Source)</code></dd>
	<dd><code><strong>compute</strong>(Location, Source, BinaryOperator, Source)</code></dd>
	<dd><code><strong>createBuffer</strong>(<strong>bytes:</strong> Int, <strong>capability:</strong> Location, <strong>onFrame:</strong> Bool)</code></dd>
	<dd><code><strong>destroyBuffer</strong>(<strong>capability:</strong> Source)</code></dd>
	<dd><code><strong>getElement</strong>(DataType, <strong>of:</strong> Location, <strong>offset:</strong> Source, <strong>to:</strong> Location)</code></dd>
	<dd><code><strong>setElement</strong>(DataType, <strong>of:</strong> Location, <strong>offset:</strong> Source, <strong>to:</strong> Source)</code></dd>
	<dd><code><strong>createSeal</strong>(<strong>in:</strong> Location)</code></dd>
	<dd><code><strong>seal</strong>(<strong>into:</strong> Location, <strong>source:</strong> Location, <strong>seal:</strong> Location)</code></dd>
	<dd><code><strong>pushFrame</strong>(Frame)</code></dd>
	<dd><code><strong>popFrame</strong></code></dd>
	<dd><code><strong>clearAll</strong>(<strong>except:</strong> [Register])</code></dd>
</dl>
<dl>
	<dt><code>BB.Continuation</code></dt>
	<dd><code><strong>continue</strong>(<strong>to:</strong> Label)</code></dd>
	<dd><code><strong>branch</strong>(Source, BranchRelation, Source, <strong>then:</strong> Label, <strong>else:</strong> Label)</code></dd>
	<dd><code><strong>call</strong>(Source, <strong>returnPoint:</strong> Label)</code></dd>
	<dd><code><strong>callSealed</strong>(Source, <strong>data:</strong> Source, <strong>returnPoint:</strong> Label)</code></dd>
	<dd><code><strong>return</strong>(<strong>to:</strong> Source)</code></dd>
</dl>
<dl>
	<dt><code>BB.Block</code></dt>
	<dd><code>(<strong>name:</strong> Label, <strong>do:</strong> [Effect], <strong>then:</strong> Continuation)</code></dd>
</dl>

<h2 id="FO">Grammar for FO (Flexible Operands)</h2>
A language that introduces flexible operands in instructions, i.e., instructions that can take frame locations in all operand positions.

**Inherited from MM:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>DataType</code>, 
<code>Label</code>
<dl>
	<dt><code>FO.Program</code></dt>
	<dd><code>([Effect])</code></dd>
</dl>
<dl>
	<dt><code>FO.Source</code></dt>
	<dd><code><strong>constant</strong>(Int)</code></dd>
	<dd><code><strong>register</strong>(Register)</code></dd>
	<dd><code><strong>frame</strong>(Frame.Location)</code></dd>
	<dd><code><strong>capability</strong>(<strong>to:</strong> Label)</code></dd>
</dl>
<dl>
	<dt><code>FO.Effect</code></dt>
	<dd><code><strong>set</strong>(DataType, Location, <strong>to:</strong> Source)</code></dd>
	<dd><code><strong>compute</strong>(Location, Source, BinaryOperator, Source)</code></dd>
	<dd><code><strong>createBuffer</strong>(<strong>bytes:</strong> Int, <strong>capability:</strong> Location, <strong>onFrame:</strong> Bool)</code></dd>
	<dd><code><strong>destroyBuffer</strong>(<strong>capability:</strong> Source)</code></dd>
	<dd><code><strong>getElement</strong>(DataType, <strong>of:</strong> Location, <strong>offset:</strong> Source, <strong>to:</strong> Location)</code></dd>
	<dd><code><strong>setElement</strong>(DataType, <strong>of:</strong> Location, <strong>offset:</strong> Source, <strong>to:</strong> Source)</code></dd>
	<dd><code><strong>createSeal</strong>(<strong>in:</strong> Location)</code></dd>
	<dd><code><strong>seal</strong>(<strong>into:</strong> Location, <strong>source:</strong> Location, <strong>seal:</strong> Location)</code></dd>
	<dd><code><strong>pushFrame</strong>(Frame)</code></dd>
	<dd><code><strong>popFrame</strong></code></dd>
	<dd><code><strong>clearAll</strong>(<strong>except:</strong> [Register])</code></dd>
	<dd><code><strong>branch</strong>(<strong>to:</strong> Label, Source, BranchRelation, Source)</code></dd>
	<dd><code><strong>jump</strong>(<strong>to:</strong> Label)</code></dd>
	<dd><code><strong>call</strong>(Source)</code></dd>
	<dd><code><strong>invoke</strong>(<strong>target:</strong> Source, <strong>data:</strong> Source)</code></dd>
	<dd><code><strong>return</strong>(<strong>to:</strong> Source)</code></dd>
	<dd><code><strong>labelled</strong>(Label, Effect)</code></dd>
</dl>
<dl>
	<dt><code>FO.Location</code></dt>
	<dd><code><strong>register</strong>(Register)</code></dd>
	<dd><code><strong>frame</strong>(Frame.Location)</code></dd>
</dl>
<dl>
	<dt><code>FO.Register</code></dt>
	<dd><code><strong>zero</strong></code></dd>
	<dd><code><strong>ra</strong></code></dd>
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
	<dd><code><strong>invocationData</strong></code></dd>
</dl>

<h2 id="MM">Grammar for MM (Managed Memory)</h2>
A language that introduces a runtime, call stack, heap, and operations on them.

**Inherited from RT:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>DataType</code>, 
<code>Label</code>, 
<code>Permission</code>
<dl>
	<dt><code>MM.Program</code></dt>
	<dd><code>([Effect])</code></dd>
</dl>
<dl>
	<dt><code>MM.Effect</code></dt>
	<dd><code><strong>copy</strong>(DataType, <strong>into:</strong> Register, <strong>from:</strong> Register)</code></dd>
	<dd><code><strong>compute</strong>(<strong>destination:</strong> Register, Register, BinaryOperator, Source)</code></dd>
	<dd><code><strong>load</strong>(DataType, <strong>into:</strong> Register, <strong>from:</strong> Frame.Location)</code></dd>
	<dd><code><strong>store</strong>(DataType, <strong>into:</strong> Frame.Location, <strong>from:</strong> Register)</code></dd>
	<dd><code><strong>createBuffer</strong>(<strong>bytes:</strong> Source, <strong>capability:</strong> Register, <strong>onFrame:</strong> Bool)</code></dd>
	<dd><code><strong>destroyBuffer</strong>(<strong>capability:</strong> Register)</code></dd>
	<dd><code><strong>loadElement</strong>(DataType, <strong>into:</strong> Register, <strong>buffer:</strong> Register, <strong>offset:</strong> Source)</code></dd>
	<dd><code><strong>storeElement</strong>(DataType, <strong>buffer:</strong> Register, <strong>offset:</strong> Source, <strong>from:</strong> Register)</code></dd>
	<dd><code><strong>deriveCapability</strong>(<strong>in:</strong> Register, <strong>to:</strong> Label)</code></dd>
	<dd><code><strong>createSeal</strong>(<strong>in:</strong> Register)</code></dd>
	<dd><code><strong>seal</strong>(<strong>into:</strong> Register, <strong>source:</strong> Register, <strong>seal:</strong> Register)</code></dd>
	<dd><code><strong>pushFrame</strong>(Frame)</code></dd>
	<dd><code><strong>popFrame</strong></code></dd>
	<dd><code><strong>permit</strong>([Permission], <strong>destination:</strong> Register, <strong>source:</strong> Register)</code></dd>
	<dd><code><strong>clearAll</strong>(<strong>except:</strong> [Register])</code></dd>
	<dd><code><strong>branch</strong>(<strong>to:</strong> Label, Register, BranchRelation, Register)</code></dd>
	<dd><code><strong>jump</strong>(<strong>to:</strong> Target)</code></dd>
	<dd><code><strong>call</strong>(Target)</code></dd>
	<dd><code><strong>invoke</strong>(<strong>target:</strong> Register, <strong>data:</strong> Register)</code></dd>
	<dd><code><strong>return</strong>(<strong>to:</strong> Target)</code></dd>
	<dd><code><strong>labelled</strong>(Label, Effect)</code></dd>
</dl>
<dl>
	<dt><code>MM.Register</code></dt>
	<dd><code><strong>zero</strong></code></dd>
	<dd><code><strong>ra</strong></code></dd>
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
	<dd><code><strong>invocationData</strong></code></dd>
</dl>
<dl>
	<dt><code>MM.Target</code></dt>
	<dd><code><strong>label</strong>(Label)</code></dd>
	<dd><code><strong>register</strong>(Register)</code></dd>
</dl>
<dl>
	<dt><code>MM.Source</code></dt>
	<dd><code><strong>constant</strong>(Int)</code></dd>
	<dd><code><strong>register</strong>(Register)</code></dd>
</dl>
<dl>
	<dt><code>MM.Frame</code></dt>
	<dd><code>(<strong>allocatedByteSize:</strong> Int)</code></dd>
</dl>

<h2 id="RT">Grammar for RT (Runtime)</h2>
A language that introduces a runtime system and runtime routines.

**Inherited from CE:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>DataType</code>, 
<code>Label</code>, 
<code>Permission</code>, 
<code>Register</code>, 
<code>Source</code>, 
<code>Target</code>
<dl>
	<dt><code>RT.Program</code></dt>
	<dd><code>([Statement])</code></dd>
</dl>
<dl>
	<dt><code>RT.Effect</code></dt>
	<dd><code><strong>copy</strong>(DataType, <strong>into:</strong> Register, <strong>from:</strong> Register)</code></dd>
	<dd><code><strong>compute</strong>(<strong>destination:</strong> Register, Register, BinaryOperator, Source)</code></dd>
	<dd><code><strong>load</strong>(DataType, <strong>destination:</strong> Register, <strong>address:</strong> Register, <strong>offset:</strong> Int)</code></dd>
	<dd><code><strong>store</strong>(DataType, <strong>address:</strong> Register, <strong>source:</strong> Register, <strong>offset:</strong> Int)</code></dd>
	<dd><code><strong>deriveCapabilityFromPCC</strong>(<strong>destination:</strong> Register, <strong>upperBits:</strong> UInt)</code></dd>
	<dd><code><strong>deriveCapabilityFromLabel</strong>(<strong>destination:</strong> Register, <strong>label:</strong> Label)</code></dd>
	<dd><code><strong>offsetCapability</strong>(<strong>destination:</strong> Register, <strong>source:</strong> Register, <strong>offset:</strong> Source)</code></dd>
	<dd><code><strong>getCapabilityLength</strong>(<strong>destination:</strong> Register, <strong>source:</strong> Register)</code></dd>
	<dd><code><strong>setCapabilityBounds</strong>(<strong>destination:</strong> Register, <strong>base:</strong> Register, <strong>length:</strong> Source)</code></dd>
	<dd><code><strong>getCapabilityAddress</strong>(<strong>destination:</strong> Register, <strong>source:</strong> Register)</code></dd>
	<dd><code><strong>setCapabilityAddress</strong>(<strong>destination:</strong> Register, <strong>source:</strong> Register, <strong>address:</strong> Register)</code></dd>
	<dd><code><strong>getCapabilityDistance</strong>(<strong>destination:</strong> Register, <strong>cs1:</strong> Register, <strong>cs2:</strong> Register)</code></dd>
	<dd><code><strong>seal</strong>(<strong>destination:</strong> Register, <strong>source:</strong> Register, <strong>seal:</strong> Register)</code></dd>
	<dd><code><strong>sealEntry</strong>(<strong>destination:</strong> Register, <strong>source:</strong> Register)</code></dd>
	<dd><code><strong>permit</strong>([Permission], <strong>destination:</strong> Register, <strong>source:</strong> Register, <strong>using:</strong> Register)</code></dd>
	<dd><code><strong>clear</strong>([Register])</code></dd>
	<dd><code><strong>branch</strong>(<strong>to:</strong> Label, Register, BranchRelation, Register)</code></dd>
	<dd><code><strong>jump</strong>(<strong>to:</strong> Target, <strong>link:</strong> Register)</code></dd>
	<dd><code><strong>invoke</strong>(<strong>target:</strong> Register, <strong>data:</strong> Register)</code></dd>
	<dd><code><strong>callRuntimeRoutine</strong>(<strong>capability:</strong> Label, <strong>link:</strong> Register)</code></dd>
</dl>
<dl>
	<dt><code>RT.Statement</code></dt>
	<dd><code><strong>effect</strong>(Effect)</code></dd>
	<dd><code><strong>padding</strong>(<strong>alignment:</strong> DataType)</code></dd>
	<dd><code><strong>data</strong>(<strong>type:</strong> DataType, <strong>value:</strong> Int, <strong>count:</strong> Int)</code></dd>
	<dd><code><strong>bssSection</strong></code></dd>
	<dd><code><strong>labelled</strong>(Label, Statement)</code></dd>
</dl>

<h2 id="CE">Grammar for CE (Canonical Effects)</h2>
A language grouping related instructions under a single effect.

**Inherited from RV:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>Label</code>, 
<code>Register</code>
<dl>
	<dt><code>CE.Program</code></dt>
	<dd><code>([Statement])</code></dd>
</dl>
<dl>
	<dt><code>CE.Statement</code></dt>
	<dd><code><strong>effect</strong>(Effect)</code></dd>
	<dd><code><strong>padding</strong>(<strong>alignment:</strong> DataType)</code></dd>
	<dd><code><strong>data</strong>(<strong>type:</strong> DataType, <strong>value:</strong> Int, <strong>count:</strong> Int)</code></dd>
	<dd><code><strong>bssSection</strong></code></dd>
	<dd><code><strong>labelled</strong>(Label, Statement)</code></dd>
</dl>
<dl>
	<dt><code>CE.Permission</code></dt>
	<dd><code><strong>global</strong></code></dd>
	<dd><code><strong>execute</strong></code></dd>
	<dd><code><strong>load</strong></code></dd>
	<dd><code><strong>store</strong></code></dd>
	<dd><code><strong>loadCapability</strong></code></dd>
	<dd><code><strong>storeCapability</strong></code></dd>
	<dd><code><strong>storeLocalCapability</strong></code></dd>
	<dd><code><strong>seal</strong></code></dd>
	<dd><code><strong>invoke</strong></code></dd>
	<dd><code><strong>unseal</strong></code></dd>
	<dd><code><strong>setCID</strong></code></dd>
</dl>
<dl>
	<dt><code>CE.DataType</code></dt>
	<dd><code><strong>u8</strong></code></dd>
	<dd><code><strong>s32</strong></code></dd>
	<dd><code><strong>cap</strong></code></dd>
</dl>
<dl>
	<dt><code>CE.Source</code></dt>
	<dd><code><strong>constant</strong>(Int)</code></dd>
	<dd><code><strong>register</strong>(Register)</code></dd>
</dl>
<dl>
	<dt><code>CE.Target</code></dt>
	<dd><code><strong>label</strong>(Label)</code></dd>
	<dd><code><strong>register</strong>(Register)</code></dd>
</dl>
<dl>
	<dt><code>CE.Effect</code></dt>
	<dd><code><strong>copy</strong>(DataType, <strong>into:</strong> Register, <strong>from:</strong> Register)</code></dd>
	<dd><code><strong>compute</strong>(<strong>destination:</strong> Register, Register, BinaryOperator, Source)</code></dd>
	<dd><code><strong>load</strong>(DataType, <strong>destination:</strong> Register, <strong>address:</strong> Register, <strong>offset:</strong> Int)</code></dd>
	<dd><code><strong>store</strong>(DataType, <strong>address:</strong> Register, <strong>source:</strong> Register, <strong>offset:</strong> Int)</code></dd>
	<dd><code><strong>deriveCapabilityFromPCC</strong>(<strong>destination:</strong> Register, <strong>upperBits:</strong> UInt)</code></dd>
	<dd><code><strong>deriveCapabilityFromLabel</strong>(<strong>destination:</strong> Register, <strong>label:</strong> Label)</code></dd>
	<dd><code><strong>offsetCapability</strong>(<strong>destination:</strong> Register, <strong>source:</strong> Register, <strong>offset:</strong> Source)</code></dd>
	<dd><code><strong>getCapabilityLength</strong>(<strong>destination:</strong> Register, <strong>source:</strong> Register)</code></dd>
	<dd><code><strong>setCapabilityBounds</strong>(<strong>destination:</strong> Register, <strong>base:</strong> Register, <strong>length:</strong> Source)</code></dd>
	<dd><code><strong>getCapabilityAddress</strong>(<strong>destination:</strong> Register, <strong>source:</strong> Register)</code></dd>
	<dd><code><strong>setCapabilityAddress</strong>(<strong>destination:</strong> Register, <strong>source:</strong> Register, <strong>address:</strong> Register)</code></dd>
	<dd><code><strong>getCapabilityDistance</strong>(<strong>destination:</strong> Register, <strong>cs1:</strong> Register, <strong>cs2:</strong> Register)</code></dd>
	<dd><code><strong>seal</strong>(<strong>destination:</strong> Register, <strong>source:</strong> Register, <strong>seal:</strong> Register)</code></dd>
	<dd><code><strong>sealEntry</strong>(<strong>destination:</strong> Register, <strong>source:</strong> Register)</code></dd>
	<dd><code><strong>permit</strong>([Permission], <strong>destination:</strong> Register, <strong>source:</strong> Register, <strong>using:</strong> Register)</code></dd>
	<dd><code><strong>clear</strong>([Register])</code></dd>
	<dd><code><strong>branch</strong>(<strong>to:</strong> Label, Register, BranchRelation, Register)</code></dd>
	<dd><code><strong>jump</strong>(<strong>to:</strong> Target, <strong>link:</strong> Register)</code></dd>
	<dd><code><strong>invoke</strong>(<strong>target:</strong> Register, <strong>data:</strong> Register)</code></dd>
</dl>

<h2 id="RV">Grammar for RV (CHERI-RISC-V)</h2>
A language that maps directly to CHERI-RISC-V assembly statements, i.e., labels, instructions, and directives.

**Inherited from S:**
N/A
<dl>
	<dt><code>RV.Program</code></dt>
	<dd><code>([Statement])</code></dd>
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
	<dt><code>RV.Statement</code></dt>
	<dd><code><strong>instruction</strong>(Instruction)</code></dd>
	<dd><code><strong>padding</strong>(<strong>byteAlignment:</strong> Int)</code></dd>
	<dd><code><strong>data</strong>(<strong>value:</strong> Int, <strong>datumByteSize:</strong> Int, <strong>count:</strong> Int)</code></dd>
	<dd><code><strong>bssSection</strong></code></dd>
	<dd><code><strong>labelled</strong>(Label, Statement)</code></dd>
</dl>
<dl>
	<dt><code>RV.Label</code></dt>
	<dd><code>String</code></dd>
</dl>
<dl>
	<dt><code>RV.Instruction</code></dt>
	<dd><code><strong>copyWord</strong>(<strong>destination:</strong> Register, <strong>source:</strong> Register)</code></dd>
	<dd><code><strong>copyCapability</strong>(<strong>destination:</strong> Register, <strong>source:</strong> Register)</code></dd>
	<dd><code><strong>computeWithRegister</strong>(<strong>operation:</strong> BinaryOperator, <strong>rd:</strong> Register, <strong>rs1:</strong> Register, <strong>rs2:</strong> Register)</code></dd>
	<dd><code><strong>computeWithImmediate</strong>(<strong>operation:</strong> BinaryOperator, <strong>rd:</strong> Register, <strong>rs1:</strong> Register, <strong>imm:</strong> Int)</code></dd>
	<dd><code><strong>loadByte</strong>(<strong>destination:</strong> Register, <strong>address:</strong> Register, <strong>offset:</strong> Int)</code></dd>
	<dd><code><strong>loadSignedWord</strong>(<strong>destination:</strong> Register, <strong>address:</strong> Register, <strong>offset:</strong> Int)</code></dd>
	<dd><code><strong>loadCapability</strong>(<strong>destination:</strong> Register, <strong>address:</strong> Register, <strong>offset:</strong> Int)</code></dd>
	<dd><code><strong>storeByte</strong>(<strong>source:</strong> Register, <strong>address:</strong> Register, <strong>offset:</strong> Int)</code></dd>
	<dd><code><strong>storeSignedWord</strong>(<strong>source:</strong> Register, <strong>address:</strong> Register, <strong>offset:</strong> Int)</code></dd>
	<dd><code><strong>storeCapability</strong>(<strong>source:</strong> Register, <strong>address:</strong> Register, <strong>offset:</strong> Int)</code></dd>
	<dd><code><strong>deriveCapabilityFromLabel</strong>(<strong>destination:</strong> Register, <strong>label:</strong> Label)</code></dd>
	<dd><code><strong>deriveCapabilityFromPCC</strong>(<strong>destination:</strong> Register, <strong>upperBits:</strong> UInt)</code></dd>
	<dd><code><strong>offsetCapability</strong>(<strong>destination:</strong> Register, <strong>source:</strong> Register, <strong>offset:</strong> Register)</code></dd>
	<dd><code><strong>offsetCapabilityWithImmediate</strong>(<strong>destination:</strong> Register, <strong>source:</strong> Register, <strong>offset:</strong> Int)</code></dd>
	<dd><code><strong>getCapabilityLength</strong>(<strong>destination:</strong> Register, <strong>source:</strong> Register)</code></dd>
	<dd><code><strong>setCapabilityBounds</strong>(<strong>destination:</strong> Register, <strong>base:</strong> Register, <strong>length:</strong> Register)</code></dd>
	<dd><code><strong>setCapabilityBoundsWithImmediate</strong>(<strong>destination:</strong> Register, <strong>base:</strong> Register, <strong>length:</strong> Int)</code></dd>
	<dd><code><strong>getCapabilityAddress</strong>(<strong>destination:</strong> Register, <strong>source:</strong> Register)</code></dd>
	<dd><code><strong>setCapabilityAddress</strong>(<strong>destination:</strong> Register, <strong>source:</strong> Register, <strong>address:</strong> Register)</code></dd>
	<dd><code><strong>getCapabilityDistance</strong>(<strong>destination:</strong> Register, <strong>cs1:</strong> Register, <strong>cs2:</strong> Register)</code></dd>
	<dd><code><strong>seal</strong>(<strong>destination:</strong> Register, <strong>source:</strong> Register, <strong>seal:</strong> Register)</code></dd>
	<dd><code><strong>sealEntry</strong>(<strong>destination:</strong> Register, <strong>source:</strong> Register)</code></dd>
	<dd><code><strong>permit</strong>(<strong>destination:</strong> Register, <strong>source:</strong> Register, <strong>mask:</strong> Register)</code></dd>
	<dd><code><strong>clear</strong>(<strong>quarter:</strong> Int, <strong>mask:</strong> UInt8)</code></dd>
	<dd><code><strong>branch</strong>(<strong>rs1:</strong> Register, <strong>relation:</strong> BranchRelation, <strong>rs2:</strong> Register, <strong>target:</strong> Label)</code></dd>
	<dd><code><strong>jump</strong>(<strong>target:</strong> Label, <strong>link:</strong> Register)</code></dd>
	<dd><code><strong>jumpWithRegister</strong>(<strong>target:</strong> Register, <strong>link:</strong> Register)</code></dd>
	<dd><code><strong>invoke</strong>(<strong>target:</strong> Register, <strong>data:</strong> Register)</code></dd>
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
	<dt><code>RV.BinaryOperator</code></dt>
	<dd><code><strong>add</strong></code></dd>
	<dd><code><strong>sub</strong></code></dd>
	<dd><code><strong>mul</strong></code></dd>
	<dd><code><strong>and</strong></code></dd>
	<dd><code><strong>or</strong></code></dd>
	<dd><code><strong>xor</strong></code></dd>
	<dd><code><strong>sll</strong></code></dd>
	<dd><code><strong>srl</strong></code></dd>
	<dd><code><strong>sra</strong></code></dd>
</dl>

<h2 id="S">Grammar for S (CHERI-RISC-V Assembly)</h2>
The ground language as provided to Clang for assembly and linking.

<dl>
	<dt><code>S.Program</code></dt>
	<dd><code>(<strong>assembly:</strong> String)</code></dd>
</dl>
