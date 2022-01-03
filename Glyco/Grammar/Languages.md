
# Summary

## Language `AL`
### `AL.ConflictGraph`

### `AL.Effect`
* `sequence(: [Effect], )`
* `copy(destination: Location, source: Source, )`
* `compute(destination: Location, 1: Source, 2: BinaryOperator, 3: Source, )`
* `if(0: Predicate, then: Effect, else: Effect, )`
* `invoke(0: Label, 1: [Source], )`
* `return(: Source, )`

### `AL.LivenessSet`

### `AL.Predicate`
* `constant(: Bool, )`
* `relation(0: Source, 1: BranchRelation, 2: Source, )`
* `if(0: Predicate, then: Predicate, else: Predicate, )`

### `AL.Procedure`

### `AL.Procedure.Parameter`

### `AL.Program`

### `AL.Source`
* `immediate(: Int, )`
* `location(: Location, )`


-------
## Language `BB`
### `BB.Block`
* `intermediate(label: Label, effects: [Effect], successor: Label, )`
* `branch(label: Label, effects: [Effect], lhs: Source, relation: BranchRelation, rhs: Source, affirmative: Label, negative: Label, )`
* `final(label: Label, effects: [Effect], result: Source, )`

### `BB.Effect`
* `copy(destination: Location, source: Source, )`
* `compute(destination: Location, 1: Source, 2: BinaryOperator, 3: Source, )`

### `BB.Program`
* `(blocks: [BB.Block], )`


-------
## Language `CD`
### `CD.Effect`
* `sequence(: [Effect], )`
* `copy(destination: Location, source: Source, )`
* `compute(destination: Location, 1: Source, 2: BinaryOperator, 3: Source, )`
* `if(0: Predicate, then: Effect, else: Effect, )`
* `invoke(: Label, )`
* `return(: Source, )`

### `CD.Predicate`
* `constant(: Bool, )`
* `relation(lhs: Source, relation: BranchRelation, rhs: Source, )`
* `conditional(condition: Predicate, affirmative: Predicate, negative: Predicate, )`

### `CD.Procedure`

### `CD.Program`


-------
## Language `EX`
### `EX.Expression`
* `constant(: Int, )`
* `location(: Location, )`
* `binary(0: Expression, 1: BinaryOperator, 2: Expression, )`
* `if(0: Predicate, then: Expression, else: Expression, )`

### `EX.Procedure`

### `EX.Program`

### `EX.Statement`
* `assign(0: Location, to: Expression, )`
* `sequence(: [Statement], )`
* `if(0: Predicate, then: Statement, else: Statement, )`
* `invoke(0: Label, 1: [Expression], )`
* `return(: Expression, )`


-------
## Language `FL`
### `FL.BinaryExpression`
* `registerRegister(0: Register, 1: BinaryOperator, 2: Register, )`
* `registerImmediate(0: Register, 1: BinaryOperator, 2: Int, )`

### `FL.Frame.Location`
* `location(: Int, )`

### `FL.Instruction`
* `copy(0: DataType, destination: Register, source: Register, )`
* `compute(destination: Register, value: BinaryExpression, )`
* `load(0: DataType, destination: Register, source: Frame.Location, )`
* `store(0: DataType, destination: Frame.Location, source: Register, )`
* `branch(to: Label, 1: Register, 2: BranchRelation, 3: Register, )`
* `jump(: Label, )`
* `call(: Label, )`
* `return()`
* `labelled(0: Label, 1: Instruction, )`

### `FL.Location`
* `register(: Register, )`
* `frameCell(: Frame.Location, )`

### `FL.Program`
* `(instructions: [Instruction], )`

### `FL.Register`
* `zero()`
* `ra()`
* `sp()`
* `gp()`
* `tp()`
* `t1()`
* `t2()`
* `fp()`
* `s1()`
* `a0()`
* `a1()`
* `a2()`
* `a3()`
* `a4()`
* `a5()`
* `a6()`
* `a7()`
* `s2()`
* `s3()`
* `s4()`
* `s5()`
* `s6()`
* `s7()`
* `s8()`
* `s9()`
* `s10()`
* `s11()`
* `t3()`
* `t4()`
* `t5()`
* `t6()`


-------
## Language `FO`
### `FO.Effect`
* `copy(destination: Location, source: Source, )`
* `compute(destination: Location, 1: Source, 2: BinaryOperator, 3: Source, )`
* `branch(to: Label, 1: Source, 2: BranchRelation, 3: Source, )`
* `jump(: Label, )`
* `call(: Label, )`
* `return()`
* `labelled(0: Label, 1: Effect, )`

### `FO.HaltEffect`

### `FO.Location`
* `register(: Register, )`
* `frameCell(: Frame.Location, )`

### `FO.Program`
* `(effects: [Effect], )`

### `FO.Register`
* `zero()`
* `ra()`
* `sp()`
* `gp()`
* `tp()`
* `fp()`
* `s1()`
* `a0()`
* `a1()`
* `a2()`
* `a3()`
* `a4()`
* `a5()`
* `a6()`
* `a7()`
* `s2()`
* `s3()`
* `s4()`
* `s5()`
* `s6()`
* `s7()`
* `s8()`
* `s9()`
* `s10()`
* `s11()`
* `t4()`
* `t5()`
* `t6()`

### `FO.Source`
* `location(: Location, )`
* `immediate(: Int, )`


-------
## Language `PA`
### `PA.Effect`
* `sequence(: [Effect], )`
* `copy(destination: Location, source: Source, )`
* `compute(destination: Location, 1: Source, 2: BinaryOperator, 3: Source, )`
* `if(0: Predicate, then: Effect, else: Effect, )`
* `invoke(0: Label, 1: [Source], )`
* `return(: Source, )`

### `PA.Procedure`

### `PA.Procedure.Parameter`
* `parameter(: DataType, )`

### `PA.Program`


-------
## Language `PR`
### `PR.Block`
* `intermediate(label: Label, effects: [Effect], successor: Label, )`
* `branch(label: Label, effects: [Effect], predicate: Predicate, affirmative: Label, negative: Label, )`
* `final(label: Label, effects: [Effect], result: Source, )`

### `PR.Predicate`
* `constant(: Bool, )`
* `not(: Predicate, )`
* `relation(0: Source, 1: BranchRelation, 2: Source, )`

### `PR.Program`


-------
## Language `RV`
### `RV.BinaryOperator`
* `add()`
* `subtract()`
* `and()`
* `or()`
* `xor()`
* `leftShift()`
* `zeroExtendingRightShift()`
* `msbExtendingRightShift()`

### `RV.BranchRelation`
* `equal()`
* `unequal()`
* `less()`
* `lessOrEqual()`
* `greater()`
* `greaterOrEqual()`

### `RV.DataType`
* `word()`
* `capability()`

### `RV.Instruction`
* `copy(0: DataType, destination: Register, source: Register, )`
* `registerRegister(operation: BinaryOperator, rd: Register, rs1: Register, rs2: Register, )`
* `registerImmediate(operation: BinaryOperator, rd: Register, rs1: Register, imm: Int, )`
* `loadWord(destination: Register, address: Register, )`
* `loadCapability(destination: Register, address: Register, offset: Int, )`
* `storeWord(source: Register, address: Register, )`
* `storeCapability(source: Register, address: Register, offset: Int, )`
* `offsetCapability(destination: Register, source: Register, offset: Int, )`
* `branch(rs1: Register, relation: BranchRelation, rs2: Register, target: Label, )`
* `jump(: Label, )`
* `call(: Label, )`
* `return()`
* `labelled(0: Label, 1: Instruction, )`

### `RV.Label`
* `(rawValue: String, )`

### `RV.Program`
* `(instructions: [Instruction], )`

### `RV.Register`
* `zero()`
* `ra()`
* `sp()`
* `gp()`
* `tp()`
* `t0()`
* `t1()`
* `t2()`
* `fp()`
* `s1()`
* `a0()`
* `a1()`
* `a2()`
* `a3()`
* `a4()`
* `a5()`
* `a6()`
* `a7()`
* `s2()`
* `s3()`
* `s4()`
* `s5()`
* `s6()`
* `s7()`
* `s8()`
* `s9()`
* `s10()`
* `s11()`
* `t3()`
* `t4()`
* `t5()`
* `t6()`


-------
## Language `S`
### `S.Program`


-------
