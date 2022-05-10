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
				addi t0, zero, 380
				candperm csp, csp, t0
				auipcc ct0, 0
				addi t1, zero, 129
				candperm ct0, ct0, t1
				csetaddr ct0, ct0, zero
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
				cllc ct2, rv.main
				cllc ct0, mm.user_end
				csub t0, ct0, ct2
				csetbounds ct2, ct2, t0
				addi t0, zero, 319
				candperm ct2, ct2, t0
				.4byte 4276355291 # cclear 1, 1
				cjalr cnull, ct2
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
				cmove ca1, ct6
				cllc ct0, mm.cseal_cap
				clc ct0, 0(ct0)
				cjalr ct0, ct0
				cmove ca3, ct6
				cincoffsetimm ca0, csp, -16
				csetboundsimm ca0, ca0, 16
				cgetaddr t0, ca0
				csetaddr csp, csp, t0
				cmove cra, ca3
				csc cra, 0(ca0)
				cmove cra, ca1
				cseal ca2, ca0, cra
				cllc cra, l.anon
				cseal ca1, cra, ca1
				cllc cra, l.anon$1
				cmove ca0, ca3
				cseal ct4, cra, ca0
				csc ct4, -48(cfp)
				cllc ca0, l.anon$2
				cmove cra, ca3
				cseal ct4, ca0, cra
				csc ct4, -32(cfp)
cd.then:		addi a0, zero, 32
cd.then$1:		nop
				cllc cra, cd.ret
				cinvoke ca1, ca2
cd.ret:			csc ca0, -16(cfp)
				clc ca0, -16(cfp)
				clc ca1, -48(cfp)
				cllc cra, cd.ret$1
				cinvoke ca1, ca0
cd.ret$1:		clc ca0, -16(cfp)
				clc ca1, -48(cfp)
				cllc cra, cd.ret$2
				cinvoke ca1, ca0
cd.ret$2:		clc ca1, -16(cfp)
				clc ca0, -48(cfp)
				cllc cra, cd.ret$3
				cinvoke ca0, ca1
cd.ret$3:		clc ca1, -16(cfp)
				clc ca0, -32(cfp)
				cllc cra, cd.ret$4
				cinvoke ca0, ca1
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
cd.then$7:		cmove ca4, cs10
				cmove ca5, cs11
				cmove ca2, cra
				clc ca1, 0(ct6)
				cincoffsetimm cra, csp, -16
				csetboundsimm cra, cra, 16
				cgetaddr t0, cra
				csetaddr csp, csp, t0
				cmove cs1, cra
				csw a0, 0(cs1)
				cseal ca0, cra, ca1
				cmove cs1, ca3
				cmove cs2, ca6
				cmove cs3, ca7
cd.then$13:		cmove cs10, ca4
				cmove cs11, ca5
				cmove cra, ca2
				cincoffsetimm csp, cfp, 16
				clc cfp, 0(cfp)
				cjalr cnull, cra
l.anon$1:		csc cfp, -16(csp)
				cincoffsetimm cfp, csp, -16
				cincoffsetimm csp, csp, -16
				cmove ca2, cs1
				cmove ca5, cs2
				cmove ca6, cs3
				cmove ca7, cs4
cd.then$18:		cmove ca3, cs10
				cmove ca4, cs11
				cmove ca1, cra
				cmove cra, ct6
				clw ra, 0(cra)
				addi s1, zero, 1
				add a0, ra, s1
				mv ra, a0
				csw ra, 0(ct6)
				cmove cs1, ca2
				cmove cs2, ca5
				cmove cs3, ca6
				cmove cs4, ca7
cd.then$23:		cmove cs10, ca3
				cmove cs11, ca4
				cmove cra, ca1
				cincoffsetimm csp, cfp, 16
				clc cfp, 0(cfp)
				cjalr cnull, cra
l.anon$2:		csc cfp, -16(csp)
				cincoffsetimm cfp, csp, -16
				cincoffsetimm csp, csp, -16
cd.then$24:		cmove ca3, cs2
				cmove ca4, cs3
				cmove ca5, cs4
				cmove ca6, cs5
				cmove ca7, cs6
cd.then$27:		cmove ca1, cs10
				cmove ca2, cs11
cd.then$28:		clw a0, 0(ct6)
cd.then$29:		cmove cs2, ca3
				cmove cs3, ca4
				cmove cs4, ca5
				cmove cs5, ca6
				cmove cs6, ca7
cd.then$32:		cmove cs10, ca1
				cmove cs11, ca2
cd.then$33:		cincoffsetimm csp, cfp, 16
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