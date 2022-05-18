(
	value(
		let(
			(ob.tseal, seal)
			(ob.oseal, seal)
			(ob.Counter.type, let((ob.typeobj, record((seal, ob.oseal))), in: sealed(ob.typeobj, with: ob.tseal)))
			(ob.ob.Counter.Type.createObject.m, sealed(function(l.anon), with: ob.tseal))
			(ob.Counter.increase.m, sealed(function(l.anon$1), with: ob.oseal))
			(ob.Counter.getCount.m, sealed(function(l.anon$2), with: ob.oseal)),
			in: let(
				(counter, evaluate(ob.ob.Counter.Type.createObject.m, ob.Counter.type 32))
				(ignored, evaluate(ob.Counter.increase.m, counter))
				(ignored, evaluate(ob.Counter.increase.m, counter))
				(ignored, evaluate(ob.Counter.increase.m, counter)),
				in: evaluate(ob.Counter.getCount.m, counter)
			)
		)
	),
	functions: (
		l.anon,
		takes: (ob.self, cap(record(((seal, cap(seal(sealed: false)))), sealed: true)), sealed: true) (initialValue, s32),
		returns: cap(record(((value, s32)), sealed: true)),
		in: let((ob.seal, field(seal, of: ob.self)), in: value(sealed(record((value, initialValue)), with: ob.seal)))
	)
	(
		l.anon$1,
		takes: (ob.self, cap(record(((value, s32)), sealed: true)), sealed: true),
		returns: s32,
		in: let(
			(newValue, binary(field(value, of: ob.self), add, 1)),
			in: do(setField(value, of: ob.self, to: newValue), then: value(newValue))
		)
	)
	(
		l.anon$2,
		takes: (ob.self, cap(record(((value, s32)), sealed: true)), sealed: true),
		returns: s32,
		in: value(field(value, of: ob.self))
	)
)