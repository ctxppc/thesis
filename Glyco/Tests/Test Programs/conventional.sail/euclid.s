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
				
_exit:			li t5, 1
				cllc ct0, tohost
				csw t5, 0(ct0)
				j _exit
				
rv.begin:		ccall rv.runtime
				li gp, 1
				j _exit
				
				.balign 4
rv.runtime:		cllc ct0, mm.heap
				cllc ct1, mm.heap_end
				csub t1, ct1, ct0
				csetbounds ct0, ct0, t1
				addi t1, zero, 317
				candperm ct0, ct0, t1
				cllc ct1, mm.heap_cap
				csc ct0, 0(ct1)
				cllc csp, mm.stack_low
				cllc ct0, mm.stack_high
				csub t1, ct0, csp
				csetbounds csp, csp, t1
				cgetaddr t0, ct0
				csetaddr csp, csp, t0
				addi t0, zero, 124
				candperm csp, csp, t0
				cllc ct0, mm.alloc
				cllc ct1, mm.alloc_end
				csub t1, ct1, ct0
				csetbounds ct0, ct0, t1
				addi t1, zero, 63
				candperm ct0, ct0, t1
				csealentry ct0, ct0
				cllc ct1, mm.alloc_cap
				csc ct0, 0(ct1)
				cllc ct6, rv.main
				cllc ct0, mm.user_end
				csub t0, ct0, ct6
				csetbounds ct6, ct6, t0
				addi t0, zero, 319
				candperm ct6, ct6, t0
				.4byte 4276355291 # cclear 1, 1
				cjalr cnull, ct6
				.balign 4
mm.alloc:		addi t2, zero, 15
				add t0, t0, t2
				xori t2, t2, -1
				and t0, t0, t2
				cllc ct2, mm.heap_cap
				clc ct2, 0(ct2)
				csetbounds ct0, ct2, t0
				cgetlen t3, ct0
				cincoffset ct2, ct2, t3
				cllc ct3, mm.heap_cap
				csc ct2, 0(ct3)
				.4byte 4276224091 # cclear 0, 128
				.4byte 4276881499 # cclear 3, 16
				cjalr cnull, ct1
				.balign 16
mm.heap_cap:	.octa 0
mm.alloc_end:	.balign 4
				.balign 4
rv.main:		csc cfp, -16(csp)
				cincoffsetimm cfp, csp, -16
				cincoffsetimm csp, csp, -32
				csc cra, -16(cfp)
				addi a0, zero, 20
				addi a1, zero, 50
				cjal cra, gcd
cd.ret:			clc cra, -16(cfp)
				cincoffsetimm csp, cfp, 16
				clc cfp, 0(cfp)
				cjalr cnull, cra
gcd:			csc cfp, -16(csp)
				cincoffsetimm cfp, csp, -16
				cincoffsetimm csp, csp, -48
				csc cs1, -16(cfp)
cd.then$9:		csc cra, -32(cfp)
				mv a2, a0
				mv ra, a2
				mv s1, a1
cd.pred:		nop
				beq ra, s1, cd.then$10
cd.else:		mv ra, a2
				mv s1, a1
cd.pred$1:		nop
				bgt ra, s1, cd.then$21
cd.else$1:		mv a0, a2
				sub a1, a1, a2
				cjal cra, gcd
cd.ret$2:		clc cs1, -16(cfp)
cd.then$41:		clc cra, -32(cfp)
				cincoffsetimm csp, cfp, 16
				clc cfp, 0(cfp)
				cjalr cnull, cra
cd.then$21:		mv ra, a1
				sub a0, a2, ra
				cjal cra, gcd
cd.ret$1:		clc cs1, -16(cfp)
cd.then$31:		clc cra, -32(cfp)
				cincoffsetimm csp, cfp, 16
				clc cfp, 0(cfp)
				cjalr cnull, cra
cd.then$10:		mv a0, a2
				clc cs1, -16(cfp)
cd.then$20:		clc cra, -32(cfp)
				cincoffsetimm csp, cfp, 16
				clc cfp, 0(cfp)
				cjalr cnull, cra
				.balign 16
mm.alloc_cap:	.octa 0
mm.scall_cap:	.octa 0
mm.user_end:	.balign 4
				.bss
				.balign 16
mm.heap:		.fill 1048576, 1, 0
mm.heap_end:	.balign 4
				.balign 16
mm.stack_low:	.fill 1048576, 1, 0
mm.stack_high:	.balign 4
				
				.data
				.align 6
				.global tohost
tohost:			.dword 0