				.text
				
				.global _start
_start:			li t0, 1
				cspecialrw ct1, pcc, c0
				csetflags ct1, ct1, t0
				cincoffsetimm ct1, ct1, 16
				jr.cap ct1
				cllc ct0, _trap_vector
				cspecialrw c0, mtcc, ct0
				cllc ct0, rv.begin
				cspecialrw c0, mepcc, ct0
				mret
				
				.align 4
_trap_vector:	li gp, 3
				j _exit
				
_exit:			auipcc ct5, 0x1
				cllc ct0, tohost
				cincoffset ct0, ct0, gp
				csc ct5, 0(ct0)
				j _exit
				
rv.begin:		ccall rv.runtime
				li gp, 1
				j _exit
				
				.align 4
rv.runtime:		cllc ct0, mm.heap
				cllc ct1, mm.heap.end
				csub t1, ct1, ct0
				csetbounds ct0, ct0, t1
				addi t1, zero, 7
				candperm ct0, ct0, t1
				cllc ct1, mm.heap.cap
				csc ct0, 0(ct1)
				cllc csp, mm.stack.low
				cllc ct0, mm.stack.high
				csub t1, ct0, csp
				csetbounds csp, csp, t1
				cgetaddr t0, ct0
				csetaddr csp, csp, t0
				addi t0, zero, 7
				candperm csp, csp, t0
				cllc ct0, mm.alloc
				cllc ct1, mm.alloc.end
				csub t1, ct1, ct0
				csetbounds ct0, ct0, t1
				addi t1, zero, 5
				candperm ct0, ct0, t1
				csealentry ct0, ct0
				cllc ct1, mm.alloc.cap
				csc ct0, 0(ct1)
				cllc ct6, rv.main
				cllc ct0, mm.user.end
				csub t0, ct0, ct6
				csetbounds ct6, ct6, t0
				addi t0, zero, 11
				candperm ct6, ct6, t0
				cmove cfp, cnull
				cjalr cnull, ct6
				.align 4
mm.alloc:		cllc ct1, mm.heap.cap
				clc ct1, 0(ct1)
				csetbounds ct0, ct1, t0
				cgetlen t2, ct0
				cincoffset ct1, ct1, t2
				cllc ct2, mm.heap.cap
				csc ct1, 0(ct2)
				clear 0, 192
				cjalr cnull, cra
mm.heap.cap:	.octa 0
mm.alloc.end:	.align 4
mm.user:
mm.alloc.cap:	.octa 0
mm.scall.cap:	.octa 0
				.align 4
rv.main:		csc cfp, -8(csp)
				cincoffsetimm cfp, csp, -8
				cincoffsetimm csp, csp, -16
				csc cra, -8(cfp)
				addi a0, zero, 1
				addi a1, zero, 1
				cjal cra, fib
cd.ret:			clc cra, -8(cfp)
				cincoffsetimm csp, cfp, 8
				clc cfp, 0(cfp)
				cjalr cnull, cra
fib:			csc cfp, -8(csp)
				cincoffsetimm cfp, csp, -8
				cincoffsetimm csp, csp, -16
cd.then$10:		csc cra, -8(cfp)
				addi a0, zero, 2
				addi a1, zero, 29
				cincoffsetimm ca2, csp, -120
				csetboundsimm ca2, ca2, 120
				cgetaddr t0, ca2
				csetaddr csp, csp, t0
				cjal cra, recFib
cd.then$21:		clc cra, -8(cfp)
				cincoffsetimm csp, cfp, 8
				clc cfp, 0(cfp)
				cjalr cnull, cra
recFib:			csc cfp, -8(csp)
				cincoffsetimm cfp, csp, -8
				cincoffsetimm csp, csp, -24
				csc cs1, -8(cfp)
cd.then$31:		csc cra, -16(cfp)
				mv a4, a0
				mv a6, a1
				cmove ca5, ca2
				mv s1, a4
				mv a0, a6
cd.pred:		nop
				bgt s1, a0, cd.then$32
cd.else:		mv s1, a4
				addi a0, zero, 2
				sub a1, s1, a0
				mv s1, a4
				addi a0, zero, 1
				sub a2, s1, a0
				mv s1, a4
				addi a0, zero, 1
				add a3, s1, a0
				cmove ca0, ca5
				mv s1, a1
				slli s1, s1, 2
				cincoffset ca1, ca0, s1
				lw.cap a1, 0(ca1)
				cmove ca0, ca5
				mv s1, a2
				slli s1, s1, 2
				cincoffset cs1, ca0, s1
				lw.cap s1, 0(cs1)
				add a0, a1, s1
				cmove ca1, ca5
				mv s1, a4
				slli s1, s1, 2
				cincoffset ct0, ca1, s1
				sw.cap a0, 0(ct0)
				mv a0, a3
				mv a1, a6
				cmove ca2, ca5
				cjal cra, recFib
cd.ret$2:		clc cs1, -8(cfp)
cd.then$52:		clc cra, -16(cfp)
				cincoffsetimm csp, cfp, 8
				clc cfp, 0(cfp)
				cjalr cnull, cra
cd.then$32:		cmove ca0, ca5
				mv s1, a6
				slli s1, s1, 2
				cincoffset ca0, ca0, s1
				lw.cap a0, 0(ca0)
				clc cs1, -8(cfp)
cd.then$42:		clc cra, -16(cfp)
				cincoffsetimm csp, cfp, 8
				clc cfp, 0(cfp)
				cjalr cnull, cra
mm.user.end:	.align 4
				.bss
mm.heap:		.fill 1048576, 1, 0
mm.heap.end:	.align 4
mm.stack.low:	.fill 1048576, 1, 0
mm.stack.high:	.align 4
				
				.data
				.align 6
				.global tohost
tohost:			.dword 0