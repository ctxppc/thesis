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
				auipcc ct0, 0
				csetaddr ct0, ct0, zero
				csetboundsimm ct0, ct0, 1
				addi t1, zero, 129
				candperm ct0, ct0, t1
				cllc ct1, mm.seal.cap
				csc ct0, 0(ct1)
				cllc ct0, mm.alloc
				cllc ct1, mm.alloc.end
				csub t1, ct1, ct0
				csetbounds ct0, ct0, t1
				addi t1, zero, 63
				candperm ct0, ct0, t1
				csealentry ct0, ct0
				cllc ct1, mm.alloc.cap
				csc ct0, 0(ct1)
				cllc ct0, mm.scall
				cllc ct1, mm.scall.end
				csub t1, ct1, ct0
				csetbounds ct0, ct0, t1
				addi t1, zero, 23
				candperm ct0, ct0, t1
				csealentry ct0, ct0
				cllc ct1, mm.scall.cap
				csc ct0, 0(ct1)
				cllc ct6, rv.main
				cllc ct0, mm.user.end
				csub t0, ct0, ct6
				csetbounds ct6, ct6, t0
				addi t0, zero, 319
				candperm ct6, ct6, t0
				cmove cfp, ct6
				.4byte 4276326107 # cclear 0, 253
				.4byte 4276588379 # cclear 1, 254
				.4byte 4276850651 # cclear 2, 255
				.4byte 4276981723 # cclear 3, 127
				cllc ct0, mm.scall.cap
				clc ct0, 0(ct0)
				cjalr ct0, ct0
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
mm.scall:		cllc ct0, mm.seal.cap
				clc ct0, 0(ct0)
				cseal cra, cra, ct0
				cseal cfp, cfp, ct0
				.4byte 4276125787 # cclear 0, 32
				cjalr cnull, ct6
				.balign 16
mm.seal.cap:	.octa 0
mm.scall.end:	.balign 4
				.balign 4
rv.main:		addi t0, zero, 32
				cllc ct1, mm.alloc.cap
				clc ct1, 0(ct1)
				cjalr ct1, ct1
				csc cfp, 0(ct0)
				cmove cfp, ct0
				csc cra, -16(cfp)
				.4byte 4276322779 # cclear 0, 227
				.4byte 4276588379 # cclear 1, 254
				.4byte 4276850651 # cclear 2, 255
				.4byte 4277112795 # cclear 3, 255
				cllc ct6, f
				cllc cra, mm.scall.cap
				clc cra, 0(cra)
				cjalr cra, cra
				cmove cfp, ct6
cd.ret:			clc cra, -16(cfp)
				.4byte 4276322523 # cclear 0, 225
				.4byte 4276587867 # cclear 1, 250
				.4byte 4276850651 # cclear 2, 255
				.4byte 4277112795 # cclear 3, 255
				clc cfp, 0(cfp)
				cinvoke cra, cfp
f:				addi t0, zero, 16
				cllc ct1, mm.alloc.cap
				clc ct1, 0(ct1)
				cjalr ct1, ct1
				csc cfp, 0(ct0)
				cmove cfp, ct0
				addi a0, zero, 42
				.4byte 4276322523 # cclear 0, 225
				.4byte 4276587867 # cclear 1, 250
				.4byte 4276850651 # cclear 2, 255
				.4byte 4277112795 # cclear 3, 255
				clc cfp, 0(cfp)
				cinvoke cra, cfp
				.balign 16
mm.alloc.cap:	.octa 0
mm.scall.cap:	.octa 0
mm.user.end:	.balign 4
				.bss
mm.heap:		.fill 1048576, 1, 0
mm.heap.end:	.balign 4
				
				.data
				.align 6
				.global tohost
tohost:			.dword 0