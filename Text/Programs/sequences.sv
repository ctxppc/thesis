(
	do(
		pushScope()
		createRecord(
			(
				(pi, cap(vector(of: s32(), sealed: false)))
				(fib, cap(vector(of: s32(), sealed: false)))
			),
			capability: abstract(sequences), scoped: true
		)
		createVector(s32(), count: 5, capability: abstract(pi), scoped: true)
		setField(pi, of: abstract(sequences), to: abstract(pi))
		createVector(s32(), count: 7, capability: abstract(fib), scoped: true)
		setField(fib, of: abstract(sequences), to: abstract(fib))
		setElement(of: abstract(fib), index: constant(0), to: constant(1))
		setElement(of: abstract(fib), index: constant(1), to: constant(1))
		setElement(of: abstract(fib), index: constant(2), to: constant(2))
		setElement(of: abstract(fib), index: constant(3), to: constant(3))
		setElement(of: abstract(fib), index: constant(4), to: constant(5))
		getElement(of: abstract(pi), index: constant(2), to: register(a0, s32()))
		popScope()
		return(to: register(ra, cap(code())))
	),
	procedures:
)