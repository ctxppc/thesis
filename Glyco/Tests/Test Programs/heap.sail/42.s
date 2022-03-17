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
				auipcc ct0, 0
				csetaddr ct0, ct0, zero
				csetboundsimm ct0, ct0, 1
				addi t1, zero, 7
				candperm ct0, ct0, t1
				cllc ct1, mm.seal.cap
				csc ct0, 0(ct1)
				cllc ct0, mm.alloc
				cllc ct1, mm.alloc.end
				csub t1, ct1, ct0
				csetbounds ct0, ct0, t1
				addi t1, zero, 5
				candperm ct0, ct0, t1
				csealentry ct0, ct0
				cllc ct1, mm.alloc.cap
				csc ct0, 0(ct1)
				cllc ct0, mm.scall
				cllc ct1, mm.scall.end
				csub t1, ct1, ct0
				csetbounds ct0, ct0, t1
				addi t1, zero, 5
				candperm ct0, ct0, t1
				csealentry ct0, ct0
				cllc ct1, mm.scall.cap
				csc ct0, 0(ct1)
				cllc ct6, rv.main
				cllc ct0, mm.user.end
				csub t0, ct0, ct6
				csetbounds ct6, ct6, t0
				addi t0, zero, 11
				candperm ct6, ct6, t0
				clear 0, 253
				clear 1, 255
				clear 2, 255
				clear 3, 127
				cllc ct0, mm.scall.cap
				clc ct0, 0(ct0)
				cjalr cra, ct0
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
				.align 4
mm.scall:		cllc ct1, mm.seal.cap
				clc ct1, 0(ct1)
				cseal cra, cra, ct1
				cseal cfp, cfp, ct1
				clear 0, 64
				cjalr cnull, ct6
mm.seal.cap:	.octa 0
mm.scall.end:	.align 4
mm.user:
mm.alloc.cap:	.octa 0
mm.scall.cap:	.octa 0
				.align 4
rv.main:		addi t0, zero, 16
				cllc ct1, mm.alloc.cap
				clc ct1, 0(ct1)
				cjalr cra, ct1
				csc cfp, 0(ct0)
				cmove cfp, ct0
				csc cra, -8(cfp)
				clear 0, 227
				clear 1, 254
				clear 2, 255
				clear 3, 255
				cllc ct6, f
				cllc ct0, mm.scall.cap
				clc ct0, 0(ct0)
				cjalr cra, ct0
				cmove cfp, ct6
cd.ret:			clc cra, -8(cfp)
				clear 0, 225
				clear 1, 250
				clear 2, 255
				clear 3, 255
				cmove cfp, ct6
				cinvoke cra, cfp
f:				addi t0, zero, 8
				cllc ct1, mm.alloc.cap
				clc ct1, 0(ct1)
				cjalr cra, ct1
				csc cfp, 0(ct0)
				cmove cfp, ct0
cd.then:		cmove ca4, cs2
				cmove ca5, cs3
				cmove ca6, cs4
				cmove ca7, cs5
cd.then$4:		cmove ca2, cs10
				cmove ca3, cs11
				cmove ca1, cra
				addi a0, zero, 42
cd.then$5:		cmove cs2, ca4
				cmove cs3, ca5
				cmove cs4, ca6
				cmove cs5, ca7
cd.then$9:		cmove cs10, ca2
				cmove cs11, ca3
				cmove cra, ca1
				clear 0, 225
				clear 1, 250
				clear 2, 255
				clear 3, 255
				cmove cfp, ct6
				cinvoke cra, cfp
mm.user.end:	.align 4
				.bss
mm.heap:		.fill 1048576, 1, 0
mm.heap.end:	.align 4
				
				.data
				.align 6
				.global tohost
tohost:			.dword 0