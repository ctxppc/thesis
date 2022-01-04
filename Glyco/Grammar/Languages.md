
# Summary

## Language `AL`
### `AL.ConflictGraph`

### `AL.Effect`
* <code><strong>sequence</strong>([Effect])</code>
* <code><strong>copy</strong>(<strong>destination:</strong> Location, <strong>source:</strong> Source)</code>
* <code><strong>compute</strong>(<strong>destination:</strong> Location, Source, BinaryOperator, Source)</code>
* <code><strong>if</strong>(Predicate, <strong>then:</strong> Effect, <strong>else:</strong> Effect)</code>
* <code><strong>invoke</strong>(Label, [Source])</code>
* <code><strong>return</strong>(Source)</code>

### `AL.LivenessSet`

### `AL.Predicate`
* <code><strong>constant</strong>(Bool)</code>
* <code><strong>relation</strong>(Source, BranchRelation, Source)</code>
* <code><strong>if</strong>(Predicate, <strong>then:</strong> Predicate, <strong>else:</strong> Predicate)</code>

### `AL.Procedure`

### `AL.Procedure.Parameter`

### `AL.Program`
* <code><strong>Program</strong>(AL.Effect, <strong>procedures:</strong> [AL.Procedure])</code>

### `AL.Source`
* <code><strong>immediate</strong>(Int)</code>
* <code><strong>location</strong>(Location)</code>

-------
## Language `BB`
### `BB.Block`
* <code><strong>intermediate</strong>(<strong>label:</strong> Label, <strong>effects:</strong> [Effect], <strong>successor:</strong> Label)</code>
* <code><strong>branch</strong>(<strong>label:</strong> Label, <strong>effects:</strong> [Effect], <strong>lhs:</strong> Source, <strong>relation:</strong> BranchRelation, <strong>rhs:</strong> Source, <strong>affirmative:</strong> Label, <strong>negative:</strong> Label)</code>
* <code><strong>final</strong>(<strong>label:</strong> Label, <strong>effects:</strong> [Effect], <strong>result:</strong> Source)</code>

### `BB.Effect`
* <code><strong>copy</strong>(<strong>destination:</strong> Location, <strong>source:</strong> Source)</code>
* <code><strong>compute</strong>(<strong>destination:</strong> Location, Source, BinaryOperator, Source)</code>

### `BB.Program`
* <code><strong>Program</strong>(<strong>blocks:</strong> [BB.Block])</code>

-------
## Language `CD`
### `CD.Effect`
* <code><strong>sequence</strong>([Effect])</code>
* <code><strong>copy</strong>(<strong>destination:</strong> Location, <strong>source:</strong> Source)</code>
* <code><strong>compute</strong>(<strong>destination:</strong> Location, Source, BinaryOperator, Source)</code>
* <code><strong>if</strong>(Predicate, <strong>then:</strong> Effect, <strong>else:</strong> Effect)</code>
* <code><strong>invoke</strong>(Label)</code>
* <code><strong>return</strong>(Source)</code>

### `CD.Predicate`
* <code><strong>constant</strong>(Bool)</code>
* <code><strong>relation</strong>(<strong>lhs:</strong> Source, <strong>relation:</strong> BranchRelation, <strong>rhs:</strong> Source)</code>
* <code><strong>conditional</strong>(<strong>condition:</strong> Predicate, <strong>affirmative:</strong> Predicate, <strong>negative:</strong> Predicate)</code>

### `CD.Procedure`

### `CD.Program`

-------
## Language `EX`
### `EX.Expression`
* <code><strong>constant</strong>(Int)</code>
* <code><strong>location</strong>(Location)</code>
* <code><strong>binary</strong>(Expression, BinaryOperator, Expression)</code>
* <code><strong>if</strong>(Predicate, <strong>then:</strong> Expression, <strong>else:</strong> Expression)</code>

### `EX.Procedure`

### `EX.Program`

### `EX.Statement`
* <code><strong>assign</strong>(Location, <strong>to:</strong> Expression)</code>
* <code><strong>sequence</strong>([Statement])</code>
* <code><strong>if</strong>(Predicate, <strong>then:</strong> Statement, <strong>else:</strong> Statement)</code>
* <code><strong>invoke</strong>(Label, [Expression])</code>
* <code><strong>return</strong>(Expression)</code>

-------
## Language `FL`
### `FL.BinaryExpression`
* <code><strong>registerRegister</strong>(Register, BinaryOperator, Register)</code>
* <code><strong>registerImmediate</strong>(Register, BinaryOperator, Int)</code>

### `FL.Frame.Location`
* <code><strong>location</strong>(<strong>offset:</strong> Int)</code>

### `FL.Instruction`
* <code><strong>copy</strong>(DataType, <strong>destination:</strong> Register, <strong>source:</strong> Register)</code>
* <code><strong>compute</strong>(<strong>destination:</strong> Register, <strong>value:</strong> BinaryExpression)</code>
* <code><strong>load</strong>(DataType, <strong>destination:</strong> Register, <strong>source:</strong> Frame.Location)</code>
* <code><strong>store</strong>(DataType, <strong>destination:</strong> Frame.Location, <strong>source:</strong> Register)</code>
* <code><strong>branch</strong>(<strong>to:</strong> Label, Register, BranchRelation, Register)</code>
* <code><strong>jump</strong>(<strong>to:</strong> Label)</code>
* <code><strong>call</strong>(Label)</code>
* <code><strong>return</strong></code>
* <code><strong>labelled</strong>(Label, Instruction)</code>

### `FL.Location`
* <code><strong>register</strong>(Register)</code>
* <code><strong>frameCell</strong>(Frame.Location)</code>

### `FL.Program`
* <code><strong>Program</strong>(<strong>instructions:</strong> [Instruction])</code>

### `FL.Register`
* <code><strong>zero</strong></code>
* <code><strong>ra</strong></code>
* <code><strong>sp</strong></code>
* <code><strong>gp</strong></code>
* <code><strong>tp</strong></code>
* <code><strong>t1</strong></code>
* <code><strong>t2</strong></code>
* <code><strong>fp</strong></code>
* <code><strong>s1</strong></code>
* <code><strong>a0</strong></code>
* <code><strong>a1</strong></code>
* <code><strong>a2</strong></code>
* <code><strong>a3</strong></code>
* <code><strong>a4</strong></code>
* <code><strong>a5</strong></code>
* <code><strong>a6</strong></code>
* <code><strong>a7</strong></code>
* <code><strong>s2</strong></code>
* <code><strong>s3</strong></code>
* <code><strong>s4</strong></code>
* <code><strong>s5</strong></code>
* <code><strong>s6</strong></code>
* <code><strong>s7</strong></code>
* <code><strong>s8</strong></code>
* <code><strong>s9</strong></code>
* <code><strong>s10</strong></code>
* <code><strong>s11</strong></code>
* <code><strong>t3</strong></code>
* <code><strong>t4</strong></code>
* <code><strong>t5</strong></code>
* <code><strong>t6</strong></code>

-------
## Language `FO`
### `FO.Effect`
* <code><strong>copy</strong>(<strong>destination:</strong> Location, <strong>source:</strong> Source)</code>
* <code><strong>compute</strong>(<strong>destination:</strong> Location, Source, BinaryOperator, Source)</code>
* <code><strong>branch</strong>(<strong>to:</strong> Label, Source, BranchRelation, Source)</code>
* <code><strong>jump</strong>(<strong>to:</strong> Label)</code>
* <code><strong>call</strong>(Label)</code>
* <code><strong>return</strong></code>
* <code><strong>labelled</strong>(Label, Effect)</code>

### `FO.HaltEffect`

### `FO.Location`
* <code><strong>register</strong>(Register)</code>
* <code><strong>frameCell</strong>(Frame.Location)</code>

### `FO.Program`
* <code><strong>Program</strong>(<strong>effects:</strong> [Effect])</code>

### `FO.Register`
* <code><strong>zero</strong></code>
* <code><strong>ra</strong></code>
* <code><strong>sp</strong></code>
* <code><strong>gp</strong></code>
* <code><strong>tp</strong></code>
* <code><strong>fp</strong></code>
* <code><strong>s1</strong></code>
* <code><strong>a0</strong></code>
* <code><strong>a1</strong></code>
* <code><strong>a2</strong></code>
* <code><strong>a3</strong></code>
* <code><strong>a4</strong></code>
* <code><strong>a5</strong></code>
* <code><strong>a6</strong></code>
* <code><strong>a7</strong></code>
* <code><strong>s2</strong></code>
* <code><strong>s3</strong></code>
* <code><strong>s4</strong></code>
* <code><strong>s5</strong></code>
* <code><strong>s6</strong></code>
* <code><strong>s7</strong></code>
* <code><strong>s8</strong></code>
* <code><strong>s9</strong></code>
* <code><strong>s10</strong></code>
* <code><strong>s11</strong></code>
* <code><strong>t4</strong></code>
* <code><strong>t5</strong></code>
* <code><strong>t6</strong></code>

### `FO.Source`
* <code><strong>location</strong>(Location)</code>
* <code><strong>immediate</strong>(Int)</code>

-------
## Language `PA`
### `PA.Effect`
* <code><strong>sequence</strong>([Effect])</code>
* <code><strong>copy</strong>(<strong>destination:</strong> Location, <strong>source:</strong> Source)</code>
* <code><strong>compute</strong>(<strong>destination:</strong> Location, Source, BinaryOperator, Source)</code>
* <code><strong>if</strong>(Predicate, <strong>then:</strong> Effect, <strong>else:</strong> Effect)</code>
* <code><strong>invoke</strong>(Label, [Source])</code>
* <code><strong>return</strong>(Source)</code>

### `PA.Procedure`

### `PA.Procedure.Parameter`
* <code><strong>parameter</strong>(<strong>type:</strong> DataType)</code>

### `PA.Program`

-------
## Language `PR`
### `PR.Block`
* <code><strong>intermediate</strong>(<strong>label:</strong> Label, <strong>effects:</strong> [Effect], <strong>successor:</strong> Label)</code>
* <code><strong>branch</strong>(<strong>label:</strong> Label, <strong>effects:</strong> [Effect], <strong>predicate:</strong> Predicate, <strong>affirmative:</strong> Label, <strong>negative:</strong> Label)</code>
* <code><strong>final</strong>(<strong>label:</strong> Label, <strong>effects:</strong> [Effect], <strong>result:</strong> Source)</code>

### `PR.Predicate`
* <code><strong>constant</strong>(Bool)</code>
* <code><strong>not</strong>(Predicate)</code>
* <code><strong>relation</strong>(Source, BranchRelation, Source)</code>

### `PR.Program`

-------
## Language `RV`
### `RV.BinaryOperator`
* <code><strong>add</strong></code>
* <code><strong>subtract</strong></code>
* <code><strong>and</strong></code>
* <code><strong>or</strong></code>
* <code><strong>xor</strong></code>
* <code><strong>leftShift</strong></code>
* <code><strong>zeroExtendingRightShift</strong></code>
* <code><strong>msbExtendingRightShift</strong></code>

### `RV.BranchRelation`
* <code><strong>equal</strong></code>
* <code><strong>unequal</strong></code>
* <code><strong>less</strong></code>
* <code><strong>lessOrEqual</strong></code>
* <code><strong>greater</strong></code>
* <code><strong>greaterOrEqual</strong></code>

### `RV.DataType`
* <code><strong>word</strong></code>
* <code><strong>capability</strong></code>

### `RV.Instruction`
* <code><strong>copy</strong>(DataType, <strong>destination:</strong> Register, <strong>source:</strong> Register)</code>
* <code><strong>registerRegister</strong>(<strong>operation:</strong> BinaryOperator, <strong>rd:</strong> Register, <strong>rs1:</strong> Register, <strong>rs2:</strong> Register)</code>
* <code><strong>registerImmediate</strong>(<strong>operation:</strong> BinaryOperator, <strong>rd:</strong> Register, <strong>rs1:</strong> Register, <strong>imm:</strong> Int)</code>
* <code><strong>loadWord</strong>(<strong>destination:</strong> Register, <strong>address:</strong> Register)</code>
* <code><strong>loadCapability</strong>(<strong>destination:</strong> Register, <strong>address:</strong> Register, <strong>offset:</strong> Int)</code>
* <code><strong>storeWord</strong>(<strong>source:</strong> Register, <strong>address:</strong> Register)</code>
* <code><strong>storeCapability</strong>(<strong>source:</strong> Register, <strong>address:</strong> Register, <strong>offset:</strong> Int)</code>
* <code><strong>offsetCapability</strong>(<strong>destination:</strong> Register, <strong>source:</strong> Register, <strong>offset:</strong> Int)</code>
* <code><strong>branch</strong>(<strong>rs1:</strong> Register, <strong>relation:</strong> BranchRelation, <strong>rs2:</strong> Register, <strong>target:</strong> Label)</code>
* <code><strong>jump</strong>(<strong>target:</strong> Label)</code>
* <code><strong>call</strong>(<strong>target:</strong> Label)</code>
* <code><strong>return</strong></code>
* <code><strong>labelled</strong>(Label, Instruction)</code>

### `RV.Label`
* <code><strong>Label</strong>(<strong>rawValue:</strong> String)</code>

### `RV.Program`
* <code><strong>Program</strong>(<strong>instructions:</strong> [Instruction])</code>

### `RV.Register`
* <code><strong>zero</strong></code>
* <code><strong>ra</strong></code>
* <code><strong>sp</strong></code>
* <code><strong>gp</strong></code>
* <code><strong>tp</strong></code>
* <code><strong>t0</strong></code>
* <code><strong>t1</strong></code>
* <code><strong>t2</strong></code>
* <code><strong>fp</strong></code>
* <code><strong>s1</strong></code>
* <code><strong>a0</strong></code>
* <code><strong>a1</strong></code>
* <code><strong>a2</strong></code>
* <code><strong>a3</strong></code>
* <code><strong>a4</strong></code>
* <code><strong>a5</strong></code>
* <code><strong>a6</strong></code>
* <code><strong>a7</strong></code>
* <code><strong>s2</strong></code>
* <code><strong>s3</strong></code>
* <code><strong>s4</strong></code>
* <code><strong>s5</strong></code>
* <code><strong>s6</strong></code>
* <code><strong>s7</strong></code>
* <code><strong>s8</strong></code>
* <code><strong>s9</strong></code>
* <code><strong>s10</strong></code>
* <code><strong>s11</strong></code>
* <code><strong>t3</strong></code>
* <code><strong>t4</strong></code>
* <code><strong>t5</strong></code>
* <code><strong>t6</strong></code>

-------
## Language `S`
### `S.Program`

-------
