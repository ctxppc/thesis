(
	(
		name: rv.main,
		do: set(cap, register(s1), to: register(ra)) set(s32, register(a0), to: 42),
		then: call(capability(to: abs), returnPoint: cd.ret)
	)
	(name: cd.ret, do: , then: return(to: register(s1)))
	(name: abs, do: , then: branch(register(a0), le, 0, then: cd.then, else: cd.else))
	(name: cd.then, do: , then: return(to: register(ra)))
	(
		name: cd.else,
		do: compute(register(a0), register(a0), mul, -1),
		then: return(to: register(ra))
	)
)