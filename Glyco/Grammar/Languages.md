
# Intermediate Languages Supported by Glyco

## Pipeline (High-Level to Low-Level)
From high-level to low-level:
<code>EX</code>
→ <code>AL</code>
→ <code>PA</code>
→ <code>CD</code>
→ <code>PR</code>
→ <code>BB</code>
→ <code>FO</code>
→ <code>FL</code>
→ <code>RV</code>
→ <code>S</code>

## Grammar for AL (Abstract Locations)

### Inherited from PA
<code>DataType</code>, 
<code>Label</code>

### New or redefined
<dl>
<dt><code>AL.Effect</code></dt>
<dd><code><strong>sequence</strong>([Effect])</code></dd>
<dd><code><strong>copy</strong>(<strong>destination:</strong> Location, <strong>source:</strong> Source)</code></dd>
<dd><code><strong>compute</strong>(<strong>destination:</strong> Location, Source, BinaryOperator, Source)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Effect, <strong>else:</strong> Effect)</code></dd>
<dd><code><strong>invoke</strong>(Label, [Source])</code></dd>
<dd><code><strong>return</strong>(Source)</code></dd>
</dl>
<dl>
<dt><code>AL.Predicate</code></dt>
<dd><code><strong>constant</strong>(Bool)</code></dd>
<dd><code><strong>relation</strong>(Source, BranchRelation, Source)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Predicate, <strong>else:</strong> Predicate)</code></dd>
</dl>
<dl>
<dt><code>AL.Procedure</code></dt>
<dd><code>(Label, [Parameter], Effect)</code></dd>
</dl>
<dl>
<dt><code>AL.Procedure.Parameter</code></dt>
<dd><code>(Location, DataType)</code></dd>
</dl>
<dl>
<dt><code>AL.Program</code></dt>
<dd><code>(Effect, <strong>procedures:</strong> [Procedure])</code></dd>
</dl>
<dl>
<dt><code>AL.Source</code></dt>
<dd><code><strong>immediate</strong>(Int)</code></dd>
<dd><code><strong>location</strong>(Location)</code></dd>
</dl>

## Grammar for BB (Basic Blocks)

### Inherited from FO
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>DataType</code>, 
<code>Frame</code>, 
<code>Label</code>, 
<code>Location</code>, 
<code>Register</code>, 
<code>Source</code>

### New or redefined
<dl>
<dt><code>BB.Block</code></dt>
<dd><code><strong>intermediate</strong>(<strong>label:</strong> Label, <strong>effects:</strong> [Effect], <strong>successor:</strong> Label)</code></dd>
<dd><code><strong>branch</strong>(<strong>label:</strong> Label, <strong>effects:</strong> [Effect], <strong>lhs:</strong> Source, <strong>relation:</strong> BranchRelation, <strong>rhs:</strong> Source, <strong>affirmative:</strong> Label, <strong>negative:</strong> Label)</code></dd>
<dd><code><strong>final</strong>(<strong>label:</strong> Label, <strong>effects:</strong> [Effect], <strong>result:</strong> Source)</code></dd>
</dl>
<dl>
<dt><code>BB.Effect</code></dt>
<dd><code><strong>copy</strong>(<strong>destination:</strong> Location, <strong>source:</strong> Source)</code></dd>
<dd><code><strong>compute</strong>(<strong>destination:</strong> Location, Source, BinaryOperator, Source)</code></dd>
</dl>
<dl>
<dt><code>BB.Program</code></dt>
<dd><code>(<strong>blocks:</strong> [BB.Block])</code></dd>
</dl>

## Grammar for CD (Conditionals)

### Inherited from PR
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>DataType</code>, 
<code>Frame</code>, 
<code>Label</code>, 
<code>Location</code>, 
<code>Register</code>, 
<code>Source</code>

### New or redefined
<dl>
<dt><code>CD.Effect</code></dt>
<dd><code><strong>sequence</strong>([Effect])</code></dd>
<dd><code><strong>copy</strong>(<strong>destination:</strong> Location, <strong>source:</strong> Source)</code></dd>
<dd><code><strong>compute</strong>(<strong>destination:</strong> Location, Source, BinaryOperator, Source)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Effect, <strong>else:</strong> Effect)</code></dd>
<dd><code><strong>invoke</strong>(Label)</code></dd>
<dd><code><strong>return</strong>(Source)</code></dd>
</dl>
<dl>
<dt><code>CD.Predicate</code></dt>
<dd><code><strong>constant</strong>(Bool)</code></dd>
<dd><code><strong>relation</strong>(<strong>lhs:</strong> Source, <strong>relation:</strong> BranchRelation, <strong>rhs:</strong> Source)</code></dd>
<dd><code><strong>conditional</strong>(<strong>condition:</strong> Predicate, <strong>affirmative:</strong> Predicate, <strong>negative:</strong> Predicate)</code></dd>
</dl>
<dl>
<dt><code>CD.Procedure</code></dt>
<dd><code>(Label, Effect)</code></dd>
</dl>
<dl>
<dt><code>CD.Program</code></dt>
<dd><code>(Effect, <strong>procedures:</strong> [Procedure])</code></dd>
</dl>

## Grammar for EX (Expressions)

### Inherited from AL
<code>DataType</code>, 
<code>Label</code>, 
<code>Location</code>, 
<code>Predicate</code>

### New or redefined
<dl>
<dt><code>EX.Expression</code></dt>
<dd><code><strong>constant</strong>(Int)</code></dd>
<dd><code><strong>location</strong>(Location)</code></dd>
<dd><code><strong>binary</strong>(Expression, BinaryOperator, Expression)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Expression, <strong>else:</strong> Expression)</code></dd>
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
<dd><code><strong>assign</strong>(Location, <strong>to:</strong> Expression)</code></dd>
<dd><code><strong>sequence</strong>([Statement])</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Statement, <strong>else:</strong> Statement)</code></dd>
<dd><code><strong>invoke</strong>(Label, [Expression])</code></dd>
<dd><code><strong>return</strong>(Expression)</code></dd>
</dl>

## Grammar for FL (Frame Locations)

### Inherited from RV
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>DataType</code>, 
<code>Label</code>

### New or redefined
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

## Grammar for FO (Frame Operands)

### Inherited from FL
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>DataType</code>, 
<code>Label</code>

### New or redefined
<dl>
<dt><code>FO.Effect</code></dt>
<dd><code><strong>copy</strong>(<strong>destination:</strong> Location, <strong>source:</strong> Source)</code></dd>
<dd><code><strong>compute</strong>(<strong>destination:</strong> Location, Source, BinaryOperator, Source)</code></dd>
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

## Grammar for PA (Parameters)

### Inherited from CD
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>DataType</code>, 
<code>Frame</code>, 
<code>Label</code>, 
<code>Location</code>, 
<code>Predicate</code>, 
<code>Register</code>, 
<code>Source</code>

### New or redefined
<dl>
<dt><code>PA.Effect</code></dt>
<dd><code><strong>sequence</strong>([Effect])</code></dd>
<dd><code><strong>copy</strong>(<strong>destination:</strong> Location, <strong>source:</strong> Source)</code></dd>
<dd><code><strong>compute</strong>(<strong>destination:</strong> Location, Source, BinaryOperator, Source)</code></dd>
<dd><code><strong>if</strong>(Predicate, <strong>then:</strong> Effect, <strong>else:</strong> Effect)</code></dd>
<dd><code><strong>invoke</strong>(Label, [Source])</code></dd>
<dd><code><strong>return</strong>(Source)</code></dd>
</dl>
<dl>
<dt><code>PA.Procedure</code></dt>
<dd><code>(Label, [Parameter], Effect)</code></dd>
</dl>
<dl>
<dt><code>PA.Procedure.Parameter</code></dt>
<dd><code>(<strong>type:</strong> DataType)</code></dd>
</dl>
<dl>
<dt><code>PA.Program</code></dt>
<dd><code>(Effect, <strong>procedures:</strong> [Procedure])</code></dd>
</dl>

## Grammar for PR

### Inherited from BB
<code>BinaryOperator</code>, 
<code>BranchRelation</code>, 
<code>DataType</code>, 
<code>Effect</code>, 
<code>Frame</code>, 
<code>Label</code>, 
<code>Location</code>, 
<code>Register</code>, 
<code>Source</code>

### New or redefined
<dl>
<dt><code>PR.Block</code></dt>
<dd><code><strong>intermediate</strong>(<strong>label:</strong> Label, <strong>effects:</strong> [Effect], <strong>successor:</strong> Label)</code></dd>
<dd><code><strong>branch</strong>(<strong>label:</strong> Label, <strong>effects:</strong> [Effect], <strong>predicate:</strong> Predicate, <strong>affirmative:</strong> Label, <strong>negative:</strong> Label)</code></dd>
<dd><code><strong>final</strong>(<strong>label:</strong> Label, <strong>effects:</strong> [Effect], <strong>result:</strong> Source)</code></dd>
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

## Grammar for RV (CHERI-RISC-V)

### Inherited from S
N/A

### New or redefined
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

## Grammar for S (CHERI-RISC-V Assembly)

### Inherited from nothing
N/A

### New or redefined
<dl>
<dt><code>S.Program</code></dt>
<dd><code>(<strong>assembly:</strong> String)</code></dd>
</dl>

