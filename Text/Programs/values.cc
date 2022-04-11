(
	do(
		set(a, to: constant(1))
		set(b, to: location(a))
		compute(c, constant(1), add, constant(2))
		createRecord(
			((name, cap(vector(of: u8(), sealed: false))) (age, s32())),
			capability: d,
			scoped: true
		)
		getField(name, of: d, to: e)
		createVector(s32(), count: 100, capability: f, scoped: true)
		getElement(of: f, index: constant(50), to: g)
		return(location(g))
	),
	procedures: 
)