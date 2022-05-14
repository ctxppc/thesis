(
	do(
		set(ls.one, to: 1)
		createSeal(in: ls.tseal)
		createSeal(in: ls.oseal)
		createRecord(((seal, cap(seal(sealed: false)))), capability: ls.rec, scoped: false)
		set(ls.field.seal, to: ls.oseal)
		setField(seal, of: ls.rec, to: ls.field.seal)
		set(ls.typeobj, to: ls.rec)
		set(ls.cap, to: ls.typeobj)
		set(ls.seal, to: ls.tseal)
		seal(into: ls.cl.Closure.type, source: ls.cap, seal: ls.seal)
		set(ls.cap$1, to: procedure(l.anon))
		set(ls.seal$1, to: ls.tseal)
		seal(into: ls.ob.cl.Closure.Type.createObject.m, source: ls.cap$1, seal: ls.seal$1)
		set(ls.cap$2, to: procedure(l.anon$1))
		set(ls.seal$2, to: ls.oseal)
		seal(into: ls.cl.Closure.invoke.m, source: ls.cap$2, seal: ls.seal$2)
		createRecord(
			(
				(receiver, cap(record(((one, s32)), sealed: true)))
				(
					method,
					cap(
						procedure(
							takes: (ls.self, cap(record(((one, s32)), sealed: true)), sealed: true)
							(ls.term, s32, sealed: false),
							returns: s32
						)
					)
				)
			),
			capability: ls.rec$1,
			scoped: false
		)
		set(ls.arg, to: ls.cl.Closure.type)
		set(ls.arg$1, to: ls.one)
		set(ls.f, to: ls.ob.cl.Closure.Type.createObject.m)
		call(ls.f, ls.arg ls.arg$1, result: ls.field.receiver)
		set(ls.field.method, to: ls.cl.Closure.invoke.m)
		setField(receiver, of: ls.rec$1, to: ls.field.receiver)
		setField(method, of: ls.rec$1, to: ls.field.method)
		set(ls.plusOne, to: ls.rec$1)
		set(ls.rec$2, to: ls.plusOne)
		getField(receiver, of: ls.rec$2, to: ls.arg$2)
		set(ls.arg$3, to: 2)
		set(ls.rec$3, to: ls.plusOne)
		getField(method, of: ls.rec$3, to: ls.f$1)
		call(ls.f$1, ls.arg$2 ls.arg$3, result: df.result)
		return(df.result)
	),
	procedures: (
		l.anon,
		takes: (ls.self, cap(record(((seal, cap(seal(sealed: false)))), sealed: true)), sealed: true)
		(ls.one, s32, sealed: false),
		returns: cap(record(((one, s32)), sealed: true)),
		in: do(
			set(ls.rec, to: ls.self)
			getField(seal, of: ls.rec, to: ls.seal)
			createRecord(((one, s32)), capability: ls.rec$1, scoped: false)
			set(ls.field.one, to: ls.one)
			setField(one, of: ls.rec$1, to: ls.field.one)
			set(ls.cap, to: ls.rec$1)
			set(ls.seal$1, to: ls.seal)
			seal(into: df.result$1, source: ls.cap, seal: ls.seal$1)
			return(df.result$1)
		)
	)
	(
		l.anon$1,
		takes: (ls.self, cap(record(((one, s32)), sealed: true)), sealed: true) (ls.term, s32, sealed: false),
		returns: s32,
		in: do(
			set(ls.rec, to: ls.self)
			getField(one, of: ls.rec, to: ls.one)
			set(ls.lhs, to: ls.one)
			set(ls.rhs, to: ls.term)
			compute(df.result$2, ls.lhs, add, ls.rhs)
			return(df.result$2)
		)
	)
)