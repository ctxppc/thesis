(
	locals: abstract(buffer, cap) abstract(number, s32) abstract(three, s32),
	in: do(
		pushScope()
		compute(abstract(three), constant(1), add, constant(2))
		createBuffer(bytes: 20, capability: abstract(buffer), scoped: true)
		getElement(s32, of: abstract(buffer), offset: constant(0), to: abstract(number))
		set(register(a0), to: abstract(number))
		popScope()
		return(to: register(ra, cap))
	),
	procedures: 
)