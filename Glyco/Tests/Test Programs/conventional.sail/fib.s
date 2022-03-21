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
				cincoffset ct5, ct5, t0
				csw gp, 0(ct5)
				j _exit
				
rv.begin:		ccall rv.runtime
				li gp, 1
				j _exit
				
				.balign 4
rv.runtime:		cllc ct0, mm.heap
				cllc ct1, mm.heap.end
				csub t1, ct1, ct0
				csetbounds ct0, ct0, t1
				addi t1, zero, 61
				candperm ct0, ct0, t1
				cllc ct1, mm.heap.cap
				csc ct0, 0(ct1)
				cllc csp, mm.stack.low
				cllc ct0, mm.stack.high
				csub t1, ct0, csp
				csetbounds csp, csp, t1
				cgetaddr t0, ct0
				csetaddr csp, csp, t0
				addi t0, zero, 124
				candperm csp, csp, t0
				cllc ct0, mm.alloc
				cllc ct1, mm.alloc.end
				csub t1, ct1, ct0
				csetbounds ct0, ct0, t1
				addi t1, zero, 63
				candperm ct0, ct0, t1
				csealentry ct0, ct0
				cllc ct1, mm.alloc.cap
				csc ct0, 0(ct1)
				cllc ct6, rv.main
				cllc ct0, mm.user.end
				csub t0, ct0, ct6
				csetbounds ct6, ct6, t0
				addi t0, zero, 319
				candperm ct6, ct6, t0
				cmove cfp, cnull
				cjalr cnull, ct6
				.balign 4
mm.alloc:		cllc ct2, mm.heap.cap
				clc ct2, 0(ct2)
				csetbounds ct0, ct2, t0
				cgetlen t3, ct0
				cincoffset ct2, ct2, t3
				cllc ct3, mm.heap.cap
				csc ct2, 0(ct3)
				.4byte 4276224091 # cclear 0, 128
				.4byte 4276881499 # cclear 3, 16
				cjalr cnull, ct1
				.balign 16
mm.heap.cap:	.octa 0
mm.alloc.end:	.balign 4
				.balign 4
rv.main:		csc cfp, -16(csp)
				cincoffsetimm cfp, csp, -16
				cincoffsetimm csp, csp, -32
				csc cra, -16(cfp)
				addi a0, zero, 0
				addi a1, zero, 1
				addi a2, zero, 30
				cjal cra, fib
cd.ret:			clc cra, -16(cfp)
				cincoffsetimm csp, cfp, 16
				clc cfp, 0(cfp)
				cjalr cnull, cra
fib:			csc cfp, -16(csp)
				cincoffsetimm cfp, csp, -16
				cincoffsetimm csp, csp, -48
				csc cs1, -16(cfp)
cd.then$9:		csc cra, -32(cfp)
				mv a3, a0
				mv ra, a2
				addi s1, zero, 0
cd.pred:		nop
				ble ra, s1, cd.then$10
cd.else:		mv a0, a1
				add a1, a3, a1
				addi ra, zero, 1
				sub a2, a2, ra
				cjal cra, fib
cd.ret$1:		clc cs1, -16(cfp)
cd.then$30:		clc cra, -32(cfp)
				cincoffsetimm csp, cfp, 16
				clc cfp, 0(cfp)
				cjalr cnull, cra
cd.then$10:		mv a0, a1
				clc cs1, -16(cfp)
cd.then$20:		clc cra, -32(cfp)
				cincoffsetimm csp, cfp, 16
				clc cfp, 0(cfp)
				cjalr cnull, cra
				.balign 16
mm.alloc.cap:	.octa 0
mm.scall.cap:	.octa 0
mm.user.end:	.balign 4
				.bss
mm.heap:		.fill 1048576, 1, 0
mm.heap.end:	.balign 4
mm.stack.low:	.fill 1048576, 1, 0
mm.stack.high:	.balign 4
				
				.data
				.align 6
				.global tohost
tohost:			.dword 0