(
	locals: abstract(cc.retcap, cap)
	abstract(df.result, s32)
	abstract(ls.Counter.getCount.m, cap)
	abstract(ls.Counter.increase.m, cap)
	abstract(ls.Counter.type, cap)
	abstract(ls.arg, cap)
	abstract(ls.arg$1, s32)
	abstract(ls.arg$2, cap)
	abstract(ls.arg$3, cap)
	abstract(ls.arg$4, cap)
	abstract(ls.arg$5, cap)
	abstract(ls.cap, cap)
	abstract(ls.cap$1, cap)
	abstract(ls.cap$2, cap)
	abstract(ls.cap$3, cap)
	abstract(ls.counter, cap)
	abstract(ls.f, cap)
	abstract(ls.f$1, cap)
	abstract(ls.f$2, cap)
	abstract(ls.f$3, cap)
	abstract(ls.f$4, cap)
	abstract(ls.ignored, s32)
	abstract(ls.ignored$1, s32)
	abstract(ls.ignored$2, s32)
	abstract(ls.ob.Counter.Type.createObject.m, cap)
	abstract(ls.rec$1, cap)
	abstract(ls.seal, cap)
	abstract(ls.seal$1, cap)
	abstract(ls.seal$2, cap)
	abstract(ls.seal$3, cap)
	abstract(ls.seal$4, cap)
	abstract(ls.typeobj, cap)
	abstract(ls.val$1, cap),
	in: do(
		pushScope
		set(abstract(cc.retcap), to: register(ra, cap))
		createSeal(in: abstract(ls.seal))
		createBuffer(bytes: 16, capability: abstract(ls.typeobj), scoped: true)
		set(abstract(ls.rec$1), to: ls.typeobj)
		set(abstract(ls.val$1), to: ls.seal)
		setElement(cap, of: abstract(ls.rec$1), offset: 0, to: ls.val$1)
		set(abstract(ls.cap), to: ls.typeobj)
		set(abstract(ls.seal$1), to: ls.seal)
		seal(into: abstract(ls.Counter.type), source: abstract(ls.cap), seal: abstract(ls.seal$1))
		set(abstract(ls.cap$1), to: capability(to: l.anon))
		set(abstract(ls.seal$2), to: ls.seal)
		seal(into: abstract(ls.ob.Counter.Type.createObject.m), source: abstract(ls.cap$1), seal: abstract(ls.seal$2))
		set(abstract(ls.cap$2), to: capability(to: l.anon$1))
		set(abstract(ls.seal$3), to: ls.seal)
		seal(into: abstract(ls.Counter.increase.m), source: abstract(ls.cap$2), seal: abstract(ls.seal$3))
		set(abstract(ls.cap$3), to: capability(to: l.anon$2))
		set(abstract(ls.seal$4), to: ls.seal)
		seal(into: abstract(ls.Counter.getCount.m), source: abstract(ls.cap$3), seal: abstract(ls.seal$4))
		set(abstract(ls.arg), to: ls.Counter.type)
		set(abstract(ls.arg$1), to: 32)
		set(abstract(ls.f), to: ls.ob.Counter.Type.createObject.m)
		set(register(a0), to: ls.arg$1)
		callSealed(ls.f, data: ls.arg, unsealedParameters: a0)
		set(abstract(ls.counter), to: register(a0, cap))
		set(abstract(ls.arg$2), to: ls.counter)
		set(abstract(ls.f$1), to: ls.Counter.increase.m)
		callSealed(ls.f$1, data: ls.arg$2, unsealedParameters: )
		set(abstract(ls.ignored), to: register(a0, s32))
		set(abstract(ls.arg$3), to: ls.counter)
		set(abstract(ls.f$2), to: ls.Counter.increase.m)
		callSealed(ls.f$2, data: ls.arg$3, unsealedParameters: )
		set(abstract(ls.ignored$1), to: register(a0, s32))
		set(abstract(ls.arg$4), to: ls.counter)
		set(abstract(ls.f$3), to: ls.Counter.increase.m)
		callSealed(ls.f$3, data: ls.arg$4, unsealedParameters: )
		set(abstract(ls.ignored$2), to: register(a0, s32))
		set(abstract(ls.arg$5), to: ls.counter)
		set(abstract(ls.f$4), to: ls.Counter.getCount.m)
		callSealed(ls.f$4, data: ls.arg$5, unsealedParameters: )
		set(abstract(df.result), to: register(a0, s32))
		set(register(a0), to: df.result)
		set(register(ra), to: cc.retcap)
		popScope
		return(to: register(ra, cap))
	),
	procedures: (
		l.anon,
		locals: abstract(cc.retcap, cap)
		abstract(cc.savedS1, cap)
		abstract(cc.savedS10, cap)
		abstract(cc.savedS11, cap)
		abstract(cc.savedS2, cap)
		abstract(cc.savedS3, cap)
		abstract(cc.savedS4, cap)
		abstract(cc.savedS5, cap)
		abstract(cc.savedS6, cap)
		abstract(cc.savedS7, cap)
		abstract(cc.savedS8, cap)
		abstract(cc.savedS9, cap)
		abstract(df.result$1, cap)
		abstract(ls.cap, cap)
		abstract(ls.initialValue, s32)
		abstract(ls.rec, cap)
		abstract(ls.rec$2, cap)
		abstract(ls.seal, cap)
		abstract(ls.seal$1, cap)
		abstract(ls.self, cap)
		abstract(ls.self$1, cap)
		abstract(ls.val$1, s32),
		in: do(
			pushScope
			set(abstract(cc.savedS1), to: register(s1, cap))
			set(abstract(cc.savedS2), to: register(s2, cap))
			set(abstract(cc.savedS3), to: register(s3, cap))
			set(abstract(cc.savedS4), to: register(s4, cap))
			set(abstract(cc.savedS5), to: register(s5, cap))
			set(abstract(cc.savedS6), to: register(s6, cap))
			set(abstract(cc.savedS7), to: register(s7, cap))
			set(abstract(cc.savedS8), to: register(s8, cap))
			set(abstract(cc.savedS9), to: register(s9, cap))
			set(abstract(cc.savedS10), to: register(s10, cap))
			set(abstract(cc.savedS11), to: register(s11, cap))
			set(abstract(cc.retcap), to: register(ra, cap))
			set(abstract(ls.self), to: register(invocationData, cap))
			set(abstract(ls.initialValue), to: register(a0, s32))
			set(abstract(ls.rec), to: ls.self)
			getElement(cap, of: abstract(ls.rec), offset: 0, to: abstract(ls.seal))
			createBuffer(bytes: 4, capability: abstract(ls.self$1), scoped: true)
			set(abstract(ls.rec$2), to: ls.self$1)
			set(abstract(ls.val$1), to: ls.initialValue)
			setElement(s32, of: abstract(ls.rec$2), offset: 0, to: ls.val$1)
			set(abstract(ls.cap), to: ls.self$1)
			set(abstract(ls.seal$1), to: ls.seal)
			seal(into: abstract(df.result$1), source: abstract(ls.cap), seal: abstract(ls.seal$1))
			set(register(a0), to: df.result$1)
			set(register(s1), to: cc.savedS1)
			set(register(s2), to: cc.savedS2)
			set(register(s3), to: cc.savedS3)
			set(register(s4), to: cc.savedS4)
			set(register(s5), to: cc.savedS5)
			set(register(s6), to: cc.savedS6)
			set(register(s7), to: cc.savedS7)
			set(register(s8), to: cc.savedS8)
			set(register(s9), to: cc.savedS9)
			set(register(s10), to: cc.savedS10)
			set(register(s11), to: cc.savedS11)
			set(register(ra), to: cc.retcap)
			popScope
			return(to: register(ra, cap))
		)
	)
	(
		l.anon$1,
		locals: abstract(cc.retcap, cap)
		abstract(cc.savedS1, cap)
		abstract(cc.savedS10, cap)
		abstract(cc.savedS11, cap)
		abstract(cc.savedS2, cap)
		abstract(cc.savedS3, cap)
		abstract(cc.savedS4, cap)
		abstract(cc.savedS5, cap)
		abstract(cc.savedS6, cap)
		abstract(cc.savedS7, cap)
		abstract(cc.savedS8, cap)
		abstract(cc.savedS9, cap)
		abstract(df.result$2, s32)
		abstract(ls.lhs, s32)
		abstract(ls.newValue, s32)
		abstract(ls.rec, cap)
		abstract(ls.rec$2, cap)
		abstract(ls.rhs, s32)
		abstract(ls.self, cap)
		abstract(ls.val$1, s32),
		in: do(
			pushScope
			set(abstract(cc.savedS1), to: register(s1, cap))
			set(abstract(cc.savedS2), to: register(s2, cap))
			set(abstract(cc.savedS3), to: register(s3, cap))
			set(abstract(cc.savedS4), to: register(s4, cap))
			set(abstract(cc.savedS5), to: register(s5, cap))
			set(abstract(cc.savedS6), to: register(s6, cap))
			set(abstract(cc.savedS7), to: register(s7, cap))
			set(abstract(cc.savedS8), to: register(s8, cap))
			set(abstract(cc.savedS9), to: register(s9, cap))
			set(abstract(cc.savedS10), to: register(s10, cap))
			set(abstract(cc.savedS11), to: register(s11, cap))
			set(abstract(cc.retcap), to: register(ra, cap))
			set(abstract(ls.self), to: register(invocationData, cap))
			set(abstract(ls.rec), to: ls.self)
			getElement(s32, of: abstract(ls.rec), offset: 0, to: abstract(ls.lhs))
			set(abstract(ls.rhs), to: 1)
			compute(abstract(ls.newValue), ls.lhs, add, ls.rhs)
			set(abstract(ls.rec$2), to: ls.self)
			set(abstract(ls.val$1), to: ls.newValue)
			setElement(s32, of: abstract(ls.rec$2), offset: 0, to: ls.val$1)
			set(abstract(df.result$2), to: ls.newValue)
			set(register(a0), to: df.result$2)
			set(register(s1), to: cc.savedS1)
			set(register(s2), to: cc.savedS2)
			set(register(s3), to: cc.savedS3)
			set(register(s4), to: cc.savedS4)
			set(register(s5), to: cc.savedS5)
			set(register(s6), to: cc.savedS6)
			set(register(s7), to: cc.savedS7)
			set(register(s8), to: cc.savedS8)
			set(register(s9), to: cc.savedS9)
			set(register(s10), to: cc.savedS10)
			set(register(s11), to: cc.savedS11)
			set(register(ra), to: cc.retcap)
			popScope
			return(to: register(ra, cap))
		)
	)
	(
		l.anon$2,
		locals: abstract(cc.retcap, cap)
		abstract(cc.savedS1, cap)
		abstract(cc.savedS10, cap)
		abstract(cc.savedS11, cap)
		abstract(cc.savedS2, cap)
		abstract(cc.savedS3, cap)
		abstract(cc.savedS4, cap)
		abstract(cc.savedS5, cap)
		abstract(cc.savedS6, cap)
		abstract(cc.savedS7, cap)
		abstract(cc.savedS8, cap)
		abstract(cc.savedS9, cap)
		abstract(df.result$3, s32)
		abstract(ls.rec, cap)
		abstract(ls.self, cap),
		in: do(
			pushScope
			set(abstract(cc.savedS1), to: register(s1, cap))
			set(abstract(cc.savedS2), to: register(s2, cap))
			set(abstract(cc.savedS3), to: register(s3, cap))
			set(abstract(cc.savedS4), to: register(s4, cap))
			set(abstract(cc.savedS5), to: register(s5, cap))
			set(abstract(cc.savedS6), to: register(s6, cap))
			set(abstract(cc.savedS7), to: register(s7, cap))
			set(abstract(cc.savedS8), to: register(s8, cap))
			set(abstract(cc.savedS9), to: register(s9, cap))
			set(abstract(cc.savedS10), to: register(s10, cap))
			set(abstract(cc.savedS11), to: register(s11, cap))
			set(abstract(cc.retcap), to: register(ra, cap))
			set(abstract(ls.self), to: register(invocationData, cap))
			set(abstract(ls.rec), to: ls.self)
			getElement(s32, of: abstract(ls.rec), offset: 0, to: abstract(df.result$3))
			set(register(a0), to: df.result$3)
			set(register(s1), to: cc.savedS1)
			set(register(s2), to: cc.savedS2)
			set(register(s3), to: cc.savedS3)
			set(register(s4), to: cc.savedS4)
			set(register(s5), to: cc.savedS5)
			set(register(s6), to: cc.savedS6)
			set(register(s7), to: cc.savedS7)
			set(register(s8), to: cc.savedS8)
			set(register(s9), to: cc.savedS9)
			set(register(s10), to: cc.savedS10)
			set(register(s11), to: cc.savedS11)
			set(register(ra), to: cc.retcap)
			popScope
			return(to: register(ra, cap))
		)
	)
)