(
	do(
		pushScope
		createRecord(
			(
				(pi, cap(vector(of: s32, sealed: false)))
				(fib, cap(vector(of: s32, sealed: false)))
			),
			capability: abstract(sequences), scoped: true
		)
		createVector(s32, count: 5, capability: abstract(pi), scoped: true)
		setField(pi, of: abstract(sequences), to: abstract(pi))
		createVector(s32, count: 7, capability: abstract(fib), scoped: true)
		setField(fib, of: abstract(sequences), to: abstract(fib))
		setElement(of: abstract(fib), index: 0, to: 1)
		setElement(of: abstract(fib), index: 1, to: 1)
		setElement(of: abstract(fib), index: 2, to: 2)
		setElement(of: abstract(fib), index: 3, to: 3)
		setElement(of: abstract(fib), index: 4, to: 5)
		getElement(of: abstract(pi), index: 2, to: register(a0, s32))
		popScope
		return(to: register(ra, cap(code)))
	),
	procedures:
)