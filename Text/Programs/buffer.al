(
	locals: abstract(buffer, cap) abstract(number, s32) abstract(three, s32),
	in: do(
		pushScope
		compute(abstract(three), 1, add, 2)
		createBuffer(bytes: 20, capability: abstract(buffer), scoped: true)
		getElement(s32, of: abstract(buffer), offset: 0, to: abstract(number))
		set(register(a0), to: number)
		popScope
		return(to: register(ra, cap))
	)
)