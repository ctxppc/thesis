(
	do(
		pushScope
		set(abstract(cc.retcap), to: register(ra, cap(code)))
		set(register(a0), to: 19)
		set(register(a1), to: 23)
		set(abstract(cc.returned), to: 0)
		clearAll(except: a0 a1)
		call(capability(to: sum), parameters: a0 a1)
		if(
			relation(cc.returned, ne, 0),
			then: do(
				createVector(s32, count: 0, capability: abstract(cc.empty), scoped: true)
				getElement(of: abstract(cc.empty), index: 0, to: register(zero))
			),
			else: set(abstract(cc.returned), to: 1)
		)
		set(abstract(the_sum), to: register(a0, s32))
		set(register(a0), to: the_sum)
		set(register(ra), to: cc.retcap)
		clearAll(except: a0 ra)
		popScope
		return(to: register(ra, cap(code)))
	),
	procedures: (
		sum,
		in: do(
			pushScope
			set(abstract(cc.retcap), to: register(ra, cap(code)))
			set(abstract(first), to: register(a0, s32))
			set(abstract(second), to: register(a1, s32))
			compute(abstract(the_result), first, add, second)
			set(register(a0), to: the_result)
			set(register(ra), to: cc.retcap)
			clearAll(except: a0 ra)
			popScope
			return(to: register(ra, cap(code)))
		)
	)
)