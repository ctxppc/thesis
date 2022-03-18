(
	locals: abstract(cc.retcap, cap) abstract(res, s32),
	in: do(
		pushScope()
		set(abstract(cc.retcap), to: register(ra, cap))
		clearAll(except: )
		call(f, parameters: )
		set(abstract(res), to: register(a0, s32))
		set(register(a0), to: abstract(res))
		set(register(ra), to: abstract(cc.retcap))
		clearAll(except: a0 ra)
		popScope()
		return(to: register(ra, cap))
	),
	procedures: (
		f,
		locals: abstract(cc.retcap, cap),
		in: do(
			pushScope()
			set(abstract(cc.retcap), to: register(ra, cap))
			set(register(a0), to: constant(42))
			set(register(ra), to: abstract(cc.retcap))
			clearAll(except: a0 ra)
			popScope()
			return(to: register(ra, cap))
		)
	)
)