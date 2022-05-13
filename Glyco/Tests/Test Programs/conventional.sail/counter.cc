(
	do(
		createSeal(in: ls.tseal)
		createSeal(in: ls.oseal)
		createRecord(((seal, cap(seal(sealed: false)))), capability: ls.rec, scoped: true)
		set(ls.field.seal, to: ls.oseal)
		setField(seal, of: ls.rec, to: ls.field.seal)
		set(ls.typeobj, to: ls.rec)
		set(ls.cap, to: ls.typeobj)
		set(ls.seal, to: ls.tseal)
		seal(into: ls.Counter.type, source: ls.cap, seal: ls.seal)
		set(ls.cap$1, to: procedure(l.anon))
		set(ls.seal$1, to: ls.tseal)
		seal(into: ls.ob.Counter.Type.createObject.m, source: ls.cap$1, seal: ls.seal$1)
		set(ls.cap$2, to: procedure(l.anon$1))
		set(ls.seal$2, to: ls.oseal)
		seal(into: ls.Counter.increase.m, source: ls.cap$2, seal: ls.seal$2)
		set(ls.cap$3, to: procedure(l.anon$2))
		set(ls.seal$3, to: ls.oseal)
		seal(into: ls.Counter.getCount.m, source: ls.cap$3, seal: ls.seal$3)
		set(ls.arg, to: ls.Counter.type)
		set(ls.arg$1, to: 32)
		set(ls.f, to: ls.ob.Counter.Type.createObject.m)
		call(ls.f, ls.arg ls.arg$1, result: ls.counter)
		set(ls.arg$2, to: ls.counter)
		set(ls.f$1, to: ls.Counter.increase.m)
		call(ls.f$1, ls.arg$2, result: ls.ignored)
		set(ls.arg$3, to: ls.counter)
		set(ls.f$2, to: ls.Counter.increase.m)
		call(ls.f$2, ls.arg$3, result: ls.ignored$1)
		set(ls.arg$4, to: ls.counter)
		set(ls.f$3, to: ls.Counter.increase.m)
		call(ls.f$3, ls.arg$4, result: ls.ignored$2)
		set(ls.arg$5, to: ls.counter)
		set(ls.f$4, to: ls.Counter.getCount.m)
		call(ls.f$4, ls.arg$5, result: df.result)
		return(df.result)
	),
	procedures: (
		l.anon,
		takes: (ls.self, cap(record(((seal, cap(seal(sealed: false)))), sealed: true)), sealed: true)
		(ls.initialValue, s32, sealed: false),
		returns: cap(record(((value, s32)), sealed: true)),
		in: do(
			set(ls.rec, to: ls.self)
			getField(seal, of: ls.rec, to: ls.seal)
			createRecord(((value, s32)), capability: ls.rec$1, scoped: true)
			set(ls.field.value, to: ls.initialValue)
			setField(value, of: ls.rec$1, to: ls.field.value)
			set(ls.cap, to: ls.rec$1)
			set(ls.seal$1, to: ls.seal)
			seal(into: df.result$1, source: ls.cap, seal: ls.seal$1)
			return(df.result$1)
		)
	)
	(
		l.anon$1,
		takes: (ls.self, cap(record(((value, s32)), sealed: true)), sealed: true),
		returns: s32,
		in: do(
			set(ls.rec, to: ls.self)
			getField(value, of: ls.rec, to: ls.lhs)
			set(ls.rhs, to: 1)
			compute(ls.newValue, ls.lhs, add, ls.rhs)
			set(ls.rec$2, to: ls.self)
			set(ls.val$1, to: ls.newValue)
			setField(value, of: ls.rec$2, to: ls.val$1)
			set(df.result$2, to: ls.newValue)
			return(df.result$2)
		)
	)
	(
		l.anon$2,
		takes: (ls.self, cap(record(((value, s32)), sealed: true)), sealed: true),
		returns: s32,
		in: do(set(ls.rec, to: ls.self) getField(value, of: ls.rec, to: df.result$3) return(df.result$3))
	)
)