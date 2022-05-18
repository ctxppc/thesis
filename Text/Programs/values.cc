(
	do(
		set(a, to: 1)
		set(b, to: a)
		compute(c, 1, add, 2)
		createRecord(
			((name, cap(vector(of: u8, sealed: false))) (age, s32)),
			capability: d,
			scoped: false
		)
		getField(name, of: d, to: e)
		createVector(s32, count: 100, capability: f, scoped: false)
		getElement(of: f, index: 50, to: g)
		return(g)
	),
	procedures: 
)