(
	locals: abstract(cc.empty, cap)
	abstract(cc.retcap, cap)
	abstract(cc.returned, s32)
	abstract(res, s32)
	abstract(sv.offset, s32),
	in: do(
		pushScope()
		set(abstract(cc.retcap), to: register(ra, cap))
		set(abstract(cc.returned), to: constant(0))
		clearAll(except: )
		call(capability(to: f), parameters: )
		if(
			relation(abstract(cc.returned), ne, constant(0)),
			then: do(
				createBuffer(bytes: 0, capability: abstract(cc.empty), scoped: true)
				compute(abstract(sv.offset), constant(0), sll, constant(2))
				getElement(s32, of: abstract(cc.empty), offset: abstract(sv.offset), to: register(zero))
			),
			else: set(abstract(cc.returned), to: constant(1))
		)
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