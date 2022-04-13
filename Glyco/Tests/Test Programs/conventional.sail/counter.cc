(
	do(
		createSeal(in: ls.seal)
		createRecord(((seal, cap(seal(sealed: false)))), capability: ls.typeobj, scoped: true)
		set(ls.rec, to: location(ls.typeobj))
		set(ls.val, to: location(ls.seal))
		setField(seal, of: ls.rec, to: location(ls.val))
		set(ls.cap, to: location(ls.typeobj))
		set(ls.seal$1, to: location(ls.seal))
		seal(into: ls.Counter.type, source: ls.cap, seal: ls.seal$1)
		set(ls.cap$1, to: procedure(l.anon))
		set(ls.seal$2, to: location(ls.seal))
		seal(into: ls.ob.Counter.Type.createObject.m, source: ls.cap$1, seal: ls.seal$2)
		set(ls.cap$2, to: procedure(l.anon$1))
		set(ls.seal$3, to: location(ls.seal))
		seal(into: ls.Counter.increase.m, source: ls.cap$2, seal: ls.seal$3)
		set(ls.cap$3, to: procedure(l.anon$2))
		set(ls.seal$4, to: location(ls.seal))
		seal(into: ls.Counter.getCount.m, source: ls.cap$3, seal: ls.seal$4)
		set(ls.arg, to: location(ls.Counter.type))
		set(ls.arg$1, to: constant(32))
		set(ls.f, to: location(ls.ob.Counter.Type.createObject.m))
		call(location(ls.f), location(ls.arg) location(ls.arg$1), result: ls.counter)
		set(ls.arg$2, to: location(ls.counter))
		set(ls.f$1, to: location(ls.Counter.increase.m))
		call(location(ls.f$1), location(ls.arg$2), result: ls.ignored$2)
		set(ls.arg$3, to: location(ls.counter))
		set(ls.f$2, to: location(ls.Counter.increase.m))
		call(location(ls.f$2), location(ls.arg$3), result: ls.ignored$2)
		set(ls.arg$4, to: location(ls.counter))
		set(ls.f$3, to: location(ls.Counter.increase.m))
		call(location(ls.f$3), location(ls.arg$4), result: ls.ignored$2)
		set(ls.arg$5, to: location(ls.counter))
		set(ls.f$4, to: location(ls.Counter.getCount.m))
		call(location(ls.f$4), location(ls.arg$5), result: df.result)
		return(location(df.result))
	),
	procedures: (
		l.anon,
		takes: (ls.self, cap(record(((seal, cap(seal(sealed: false)))), sealed: true)), sealed: true)
		(ls.initialValue, s32(), sealed: false),
		returns: cap(record(((value, s32())), sealed: true)),
		in: do(
			createRecord(((value, s32())), capability: ls.newobj, scoped: true)
			set(ls.rec, to: location(ls.self))
			getField(seal, of: ls.rec, to: ls.seal)
			set(ls.rec$1, to: location(ls.self))
			set(ls.val, to: location(ls.initialValue))
			setField(value, of: ls.rec$1, to: location(ls.val))
			set(ls.cap, to: location(ls.newobj))
			set(ls.seal$1, to: location(ls.seal))
			seal(into: df.result$1, source: ls.cap, seal: ls.seal$1)
			return(location(df.result$1))
		)
	)
	(
		l.anon$1,
		takes: (ls.self, cap(record(((value, s32())), sealed: true)), sealed: true),
		returns: s32(),
		in: do(
			set(ls.rec, to: location(ls.self))
			getField(value, of: ls.rec, to: ls.newCount)
			set(ls.rec$1, to: location(ls.self))
			set(ls.val, to: location(ls.newCount))
			setField(value, of: ls.rec$1, to: location(ls.val))
			set(df.result$2, to: location(ls.newCount))
			return(location(df.result$2))
		)
	)
	(
		l.anon$2,
		takes: (ls.self, cap(record(((value, s32())), sealed: true)), sealed: true),
		returns: s32(),
		in: do(set(ls.rec, to: location(ls.self)) getField(value, of: ls.rec, to: df.result$3) return(location(df.result$3)))
	)
)