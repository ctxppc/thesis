
# Intermediate Languages Supported by Glyco
**Glyco** is a nanopass compiler, so-called because it consists of numerous intermediate languages and small passes.

The pipeline, from high-level to low-level is:
[`EX`](#EX) →
[`PA`](#PA) →
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
	<dt><code>[<var>N</var>]</code> for some nonterminal <var>N</var></dt>
	<dd>Zero or more productions of <var>N</var>, each separated by whitespace (spaces, tabs, newlines, paragraph terminators, etc.).</dd>
	<dt><code>Bool</code></dt>
	<dd><code>true</code></dd>
	<dd><code>"true"</code></dd>
	<dd><code>false</code></dd>
	<dd><code>"false"</code></dd>
	<dt><code>Int</code></dt>
	<dd>One or more characters between 0 and 9, inclusive, optionally prefixed by <kbd>-</kbd>. The value must be representable in the C <code>int</code> type of the compiling machine.</dd>
	<dt><code>String</code></dt>
	<dd>A letter (Unicode General Category L* and M*) or underscore <kbd>_</kbd>, followed by any number of alphanumeric characters (Unicode General Categories L*, M*, and N*) or underscores <kbd>_</kbd>.</dd>
	<dd>Zero or more characters enclosed in double-quotes <kbd>"</kbd>, with any occurrences of the double-quote character <kbd>"</kbd> in the string content replaced with two instances of the same, i.e., <kbd>""</kbd>.</dd>
</dl>


<h2 id="EX">Grammar for EX (Expressions)</h2>
A language that introduces structural value expressions, thereby abstracting over simple computation effects.

**Inherited from PA:**
<code>BranchRelation</code>, 
<code>DataType</code>, 
<code>Label</code>, 
<code>Location</code>, 
<code>Parameter</code>

<dl>
<dt><code>EX.Expression</code></dt>
<dd><code><strong>constant</strong>(Int)</code></dd>
<dd><code><strong>location</strong>(Location)</code></dd>
<dd><code><strong>binary</strong>(Expression, BinaryOperator, Expression)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Expression, <strong>else:</strong> Expression)</code></dd>
</dl>
<dl>
<dt><code>EX.Predicate</code></dt>
<dd><code><strong>constant</strong>(Bool)</code></dd>
<dd><code><strong>relation</strong>(Expression, BranchRelation, Expression)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Predicate, <strong>else:</strong> Predicate)</code></dd>
</dl>
<dl>
<dt><code>EX.Procedure</code></dt>
<dd><code>(Label, [Parameter], Statement)</code></dd>
</dl>
<dl>
<dt><code>EX.Program</code></dt>
<dd><code>(Statement, <strong>procedures:</strong> [Procedure])</code></dd>
</dl>
<dl>
<dt><code>EX.Statement</code></dt>
<dd><code><strong>set</strong>(Location, <strong>to:</strong> Expression)</code></dd>
<dd><code><strong>do</strong>([Statement])</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Statement, <strong>else:</strong> Statement)</code></dd>
<dd><code><strong>call</strong>(Label, [Expression])</code></dd>
<dd><code><strong>return</strong>(Expression)</code></dd>
</dl>


<h2 id="PA">Grammar for PA (Parameters)</h2>
A language that introduces procedure parameters using the PA calling convention.

**Inherited from AL:**
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>DataType</code>, 
<code>Label</code>, 
<code>Location</code>

<dl>
<dt><code>PA.Effect</code></dt>
<dd><code><strong>do</strong>([Effect])</code></dd>
<dd><code><strong>set</strong>(Location, <strong>to:</strong> Source)</code></dd>
<dd><code><strong>compute</strong>(Source, BinaryOperator, Source, <strong>to:</strong> Location)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Effect, <strong>else:</strong> Effect)</code></dd>
<dd><code><strong>call</strong>(Label, [Source])</code></dd>
<dd><code><strong>return</strong>(Source)</code></dd>
</dl>
<dl>
<dt><code>PA.Parameter</code></dt>
<dd><code>(Location, DataType)</code></dd>
</dl>
<dl>
<dt><code>PA.Predicate</code></dt>
<dd><code><strong>constant</strong>(Bool)</code></dd>
<dd><code><strong>relation</strong>(Source, BranchRelation, Source)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Predicate, <strong>else:</strong> Predicate)</code></dd>
</dl>
<dl>
<dt><code>PA.Procedure</code></dt>
<dd><code>(Label, [Parameter], Effect)</code></dd>
</dl>
<dl>
<dt><code>PA.Program</code></dt>
<dd><code>(Effect, <strong>procedures:</strong> [Procedure])</code></dd>
</dl>
<dl>
<dt><code>PA.Source</code></dt>
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
<dd><code><strong>set</strong>(Location, <strong>to:</strong> Source)</code></dd>
<dd><code><strong>compute</strong>(Source, BinaryOperator, Source, <strong>to:</strong> Location)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Effect, <strong>else:</strong> Effect)</code></dd>
<dd><code><strong>call</strong>(Label)</code></dd>
<dd><code><strong>return</strong>(Source)</code></dd>
</dl>
<dl>
<dt><code>CD.Predicate</code></dt>
<dd><code><strong>constant</strong>(Bool)</code></dd>
<dd><code><strong>relation</strong>(Source, BranchRelation, Source)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Predicate, <strong>else:</strong> Predicate)</code></dd>
</dl>
<dl>
<dt><code>CD.Procedure</code></dt>
<dd><code>(Label, Effect)</code></dd>
</dl>
<dl>
<dt><code>CD.Program</code></dt>
<dd><code>(Effect, <strong>procedures:</strong> [Procedure])</code></dd>
</dl>


<h2 id="PR">Grammar for PR</h2>
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
<dd><code><strong>final</strong>(Label, [Effect], <strong>result:</strong> Source)</code></dd>
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
<dd><code><strong>final</strong>(Label, [Effect], <strong>result:</strong> Source)</code></dd>
</dl>
<dl>
<dt><code>BB.Effect</code></dt>
<dd><code><strong>copy</strong>(<strong>from:</strong> Source, <strong>to:</strong> Location)</code></dd>
<dd><code><strong>compute</strong>(Source, BinaryOperator, Source, <strong>to:</strong> Location)</code></dd>
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
<dd><code><strong>copy</strong>(<strong>from:</strong> Source, <strong>to:</strong> Location)</code></dd>
<dd><code><strong>compute</strong>(Source, BinaryOperator, Source, <strong>to:</strong> Location)</code></dd>
<dd><code><strong>branch</strong>(<strong>to:</strong> Label, Source, BranchRelation, Source)</code></dd>
<dd><code><strong>jump</strong>(<strong>to:</strong> Label)</code></dd>
<dd><code><strong>call</strong>(Label)</code></dd>
<dd><code><strong>return</strong></code></dd>
<dd><code><strong>labelled</strong>(Label, Effect)</code></dd>
</dl>
<dl>
<dt><code>FO.HaltEffect</code></dt>
<dd><code>(<strong>result:</strong> Source)</code></dd>
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
<dt><code>FL.Frame.Location</code></dt>
<dd><code>(<strong>offset:</strong> Int)</code></dd>
</dl>
<dl>
<dt><code>FL.Instruction</code></dt>
<dd><code><strong>copy</strong>(DataType, <strong>destination:</strong> Register, <strong>source:</strong> Register)</code></dd>
<dd><code><strong>compute</strong>(<strong>destination:</strong> Register, <strong>value:</strong> BinaryExpression)</code></dd>
<dd><code><strong>load</strong>(DataType, <strong>destination:</strong> Register, <strong>source:</strong> Frame.Location)</code></dd>
<dd><code><strong>store</strong>(DataType, <strong>destination:</strong> Frame.Location, <strong>source:</strong> Register)</code></dd>
<dd><code><strong>branch</strong>(<strong>to:</strong> Label, Register, BranchRelation, Register)</code></dd>
<dd><code><strong>jump</strong>(<strong>to:</strong> Label)</code></dd>
<dd><code><strong>call</strong>(Label)</code></dd>
<dd><code><strong>return</strong></code></dd>
<dd><code><strong>labelled</strong>(Label, Instruction)</code></dd>
</dl>
<dl>
<dt><code>FL.Location</code></dt>
<dd><code><strong>register</strong>(Register)</code></dd>
<dd><code><strong>frameCell</strong>(Frame.Location)</code></dd>
</dl>
<dl>
<dt><code>FL.Program</code></dt>
<dd><code>([Instruction])</code></dd>
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
<dd><code><strong>subtract</strong></code></dd>
<dd><code><strong>and</strong></code></dd>
<dd><code><strong>or</strong></code></dd>
<dd><code><strong>xor</strong></code></dd>
<dd><code><strong>leftShift</strong></code></dd>
<dd><code><strong>zeroExtendingRightShift</strong></code></dd>
<dd><code><strong>msbExtendingRightShift</strong></code></dd>
</dl>
<dl>
<dt><code>RV.BranchRelation</code></dt>
<dd><code><strong>equal</strong></code></dd>
<dd><code><strong>unequal</strong></code></dd>
<dd><code><strong>less</strong></code></dd>
<dd><code><strong>lessOrEqual</strong></code></dd>
<dd><code><strong>greater</strong></code></dd>
<dd><code><strong>greaterOrEqual</strong></code></dd>
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
<dd><code><strong>offsetCapability</strong>(<strong>destination:</strong> Register, <strong>source:</strong> Register, <strong>offset:</strong> Int)</code></dd>
<dd><code><strong>branch</strong>(<strong>rs1:</strong> Register, <strong>relation:</strong> BranchRelation, <strong>rs2:</strong> Register, <strong>target:</strong> Label)</code></dd>
<dd><code><strong>jump</strong>(<strong>target:</strong> Label)</code></dd>
<dd><code><strong>call</strong>(<strong>target:</strong> Label)</code></dd>
<dd><code><strong>return</strong></code></dd>
<dd><code><strong>labelled</strong>(Label, Instruction)</code></dd>
</dl>
<dl>
<dt><code>RV.Label</code></dt>
<dd><code>(<strong>rawValue:</strong> String)</code></dd>
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


<h2 id="S">Grammar for S (CHERI-RISC-V Assembly)</h2>
The ground language as provided to Clang for assembly and linking.


<dl>
<dt><code>S.Program</code></dt>
<dd><code>(<strong>assembly:</strong> String)</code></dd>
</dl>

