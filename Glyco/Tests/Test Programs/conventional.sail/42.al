(
	locals: abstract(cc.retcap, cap) abstract(res, s32),
	in: do(
		pushScope
		set(abstract(cc.retcap), to: register(ra, cap))
		call(capability(to: f), parameters: )
		set(abstract(res), to: register(a0, s32))
		set(register(a0), to: res)
		set(register(ra), to: cc.retcap)
		popScope
		return(to: register(ra, cap))
	),
	procedures: (
		f,
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
		abstract(cc.savedS9, cap),
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
			set(register(a0), to: 42)
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