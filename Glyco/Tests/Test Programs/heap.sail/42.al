(
	locals: abstract(cc.empty, cap)
	abstract(cc.retcap, cap)
	abstract(cc.returned, s32)
	abstract(res, s32)
	abstract(sv.offset, s32),
	in: do(
		pushScope
		set(abstract(cc.retcap), to: register(ra, cap))
		set(abstract(cc.returned), to: 0)
		clearAll(except: )
		call(capability(to: f), parameters: )
		if(
			relation(cc.returned, ne, 0),
			then: do(
				createBuffer(bytes: 0, capability: abstract(cc.empty), scoped: true)
				compute(abstract(sv.offset), 0, sll, 2)
				getElement(s32, of: abstract(cc.empty), offset: sv.offset, to: register(zero))
			),
			else: set(abstract(cc.returned), to: 1)
		)
		set(abstract(res), to: register(a0, s32))
		set(register(a0), to: res)
		set(register(ra), to: cc.retcap)
		clearAll(except: a0 ra)
		popScope
		return(to: register(ra, cap))
	),
	procedures: (
		f,
		locals: abstract(cc.retcap, cap),
		in: do(
			pushScope
			set(abstract(cc.retcap), to: register(ra, cap))
			set(register(a0), to: 42)
			set(register(ra), to: cc.retcap)
			clearAll(except: a0 ra)
			popScope
			return(to: register(ra, cap))
		)
	)
)