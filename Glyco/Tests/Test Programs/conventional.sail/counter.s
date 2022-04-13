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
				auipcc ct0, 0
				addi t1, zero, 129
				candperm ct0, ct0, t1
				addi t1, t1, 1
				slli t1, t1, 19
				csetaddr ct0, ct0, t1
				cllc ct1, mm.cseal_seal_cap
				csc ct0, 0(ct1)
				cllc ct0, mm.alloc
				cllc ct1, mm.alloc_end
				csub t1, ct1, ct0
				csetbounds ct0, ct0, t1
				addi t1, zero, 63
				candperm ct0, ct0, t1
				csealentry ct0, ct0
				cllc ct1, mm.alloc_cap
				csc ct0, 0(ct1)
				cllc ct0, mm.cseal
				cllc ct1, mm.cseal_end
				csub t1, ct1, ct0
				csetbounds ct0, ct0, t1
				addi t1, zero, 63
				candperm ct0, ct0, t1
				csealentry ct0, ct0
				cllc ct1, mm.cseal_cap
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
mm.cseal:		cllc ct1, mm.cseal_seal_cap
				clc ct6, 0(ct1)
				cincoffsetimm ct6, ct6, 1
				csc ct6, 0(ct1)
				csetboundsimm ct6, ct6, 1
				.4byte 4276158555 # cclear 0, 64
				cjalr cnull, ct0
				.balign 16
mm.cseal_seal_cap:	.octa 0
mm.cseal_end:	.balign 4
				.balign 4
rv.main:		csc cfp, -16(csp)
				cincoffsetimm cfp, csp, -16
				cincoffsetimm csp, csp, -80
				csc cra, -64(cfp)
				cllc ct0, mm.cseal_cap
				clc ct0, 0(ct0)
				cjalr ct0, ct0
				cmove ca3, ct6
				cincoffsetimm ca1, csp, -16
				csetboundsimm ca1, ca1, 16
				cgetaddr t0, ca1
				csetaddr csp, csp, t0
				cmove cra, ca1
				cmove ca0, ca3
				csc ca0, 0(cra)
				cmove cra, ca3
				cseal ca1, ca1, cra
				cllc cra, l.anon
				cmove ca0, ca3
				cseal ca2, cra, ca0
				cllc cra, l.anon$1
				cmove ca0, ca3
				cseal ct4, cra, ca0
				csc ct4, -48(cfp)
				cllc ca0, l.anon$2
				cmove cra, ca3
				cseal ct4, ca0, cra
				csc ct4, -32(cfp)
cd.then:		addi a0, zero, 32
				cmove cra, ca2
				cllc cra, cd.ret
				cinvoke cra, ca1
cd.ret:			csc ca0, -16(cfp)
				clc cra, -16(cfp)
				clc ca0, -48(cfp)
				cllc cra, cd.ret$1
				cinvoke ca0, cra
cd.ret$1:		clc cra, -16(cfp)
				clc ca0, -48(cfp)
				cllc cra, cd.ret$2
				cinvoke ca0, cra
cd.ret$2:		clc ca0, -16(cfp)
				clc cra, -48(cfp)
				cllc cra, cd.ret$3
				cinvoke cra, ca0
cd.ret$3:		clc ca0, -16(cfp)
				clc cra, -32(cfp)
				cllc cra, cd.ret$4
				cinvoke cra, ca0
cd.ret$4:		clc cra, -64(cfp)
				cincoffsetimm csp, cfp, 16
				clc cfp, 0(cfp)
				cjalr cnull, cra
l.anon:			csc cfp, -16(csp)
				cincoffsetimm cfp, csp, -16
				cincoffsetimm csp, csp, -16
				cmove ca3, cs1
				cmove ca6, cs2
				cmove ca7, cs3
cd.then$6:		cmove ca4, cs10
				cmove ca5, cs11
				cmove ca2, cra
				clc cs1, 0(ct6)
				cincoffsetimm ca1, csp, -16
				csetboundsimm ca1, ca1, 16
				cgetaddr t0, ca1
				csetaddr csp, csp, t0
				cmove cra, ca1
				csw a0, 0(cra)
				cseal ca0, ca1, cs1
				cmove cs1, ca3
				cmove cs2, ca6
				cmove cs3, ca7
cd.then$12:		cmove cs10, ca4
				cmove cs11, ca5
				cmove cra, ca2
				cincoffsetimm csp, cfp, 16
				clc cfp, 0(cfp)
				cjalr cnull, cra
l.anon$1:		csc cfp, -16(csp)
				cincoffsetimm cfp, csp, -16
				cincoffsetimm csp, csp, -16
cd.then$13:		cmove ca4, cs2
				cmove ca5, cs3
				cmove ca6, cs4
				cmove ca7, cs5
cd.then$17:		cmove ca2, cs10
				cmove ca3, cs11
				cmove ca1, cra
				cmove cra, ct6
				clw a0, 0(cra)
				mv ra, a0
				csw ra, 0(ct6)
cd.then$18:		cmove cs2, ca4
				cmove cs3, ca5
				cmove cs4, ca6
				cmove cs5, ca7
cd.then$22:		cmove cs10, ca2
				cmove cs11, ca3
				cmove cra, ca1
				cincoffsetimm csp, cfp, 16
				clc cfp, 0(cfp)
				cjalr cnull, cra
l.anon$2:		csc cfp, -16(csp)
				cincoffsetimm cfp, csp, -16
				cincoffsetimm csp, csp, -16
cd.then$23:		cmove ca3, cs2
				cmove ca4, cs3
				cmove ca5, cs4
				cmove ca6, cs5
				cmove ca7, cs6
cd.then$26:		cmove ca1, cs10
				cmove ca2, cs11
cd.then$27:		clw a0, 0(ct6)
cd.then$28:		cmove cs2, ca3
				cmove cs3, ca4
				cmove cs4, ca5
				cmove cs5, ca6
				cmove cs6, ca7
cd.then$31:		cmove cs10, ca1
				cmove cs11, ca2
cd.then$32:		cincoffsetimm csp, cfp, 16
				clc cfp, 0(cfp)
				cjalr cnull, cra
				.balign 16
mm.alloc_cap:	.octa 0
mm.cseal_cap:	.octa 0
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