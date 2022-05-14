(
	let(
		(one, 1)
		(
			plusOne,
			let(
				(ob.tseal, seal)
				(ob.oseal, seal)
				(ob.cl.Closure.type, let((ob.typeobj, record((seal, ob.oseal))), in: sealed(ob.typeobj, with: ob.tseal)))
				(ob.ob.cl.Closure.Type.createObject.m, sealed(function(l.anon), with: ob.tseal))
				(ob.cl.Closure.invoke.m, sealed(function(l.anon$1), with: ob.oseal)),
				in: record((receiver, evaluate(ob.ob.cl.Closure.Type.createObject.m, ob.cl.Closure.type one)) (method, ob.cl.Closure.invoke.m))
			)
		),
		in: evaluate(field(method, of: plusOne), field(receiver, of: plusOne) 2)
	),
	functions: (
		l.anon,
		takes: (ob.self, cap(record(((seal, cap(seal(sealed: false)))), sealed: true)), sealed: true)
		(one, s32, sealed: false),
		returns: cap(record(((one, s32)), sealed: true)),
		in: let((ob.seal, field(seal, of: ob.self)), in: value(sealed(record((one, one)), with: ob.seal)))
	)
	(
		l.anon$1,
		takes: (ob.self, cap(record(((one, s32)), sealed: true)), sealed: true) (term, s32, sealed: false),
		returns: s32,
		in: let((one, field(one, of: ob.self)), in: value(binary(one, add, term)))
	)
)