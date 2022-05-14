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
				cllc ct0, mm.savedRA
				csc cra, 0(ct0)
				cllc ct0, mm.cseal_cap
				clc ct0, 0(ct0)
				cjalr ct0, ct0
				cllc cra, mm.ret
				cseal cra, cra, ct6
				auipcc cfp, 0
				addi t0, zero, 257
				candperm cfp, cfp, t0
				cseal cfp, cfp, ct6
				.4byte 4276195035 # cclear 0, 125
				.4byte 4276588379 # cclear 1, 254
				.4byte 4276850651 # cclear 2, 255
				.4byte 4277112795 # cclear 3, 255
				cjalr cnull, ct2
mm.ret:			cllc ct0, mm.savedRA
				clc cra, 0(ct0)
				cjalr cnull, cra
				.balign 16
mm.savedRA:		.octa 0
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
rv.main:		addi t0, zero, 160
				cllc ct1, mm.alloc_cap
				clc ct1, 0(ct1)
				cjalr ct1, ct1
				csc cfp, 0(ct0)
				cmove cfp, ct0
				csc cra, 144(cfp)
				addi a3, zero, 1
				cllc ct0, mm.cseal_cap
				clc ct0, 0(ct0)
				cjalr ct0, ct0
				cmove ca0, ct6
				cllc ct0, mm.cseal_cap
				clc ct0, 0(ct0)
				cjalr ct0, ct0
				cmove ca2, ct6
				addi t0, zero, 16
				cllc ct1, mm.alloc_cap
				clc ct1, 0(ct1)
				cjalr ct1, ct1
				cmove cs1, ct0
				cmove cra, ca2
				csc cra, 0(cs1)
				cmove cra, ca0
				cseal cs1, cs1, cra
				cllc cra, l.anon
				cseal ca1, cra, ca0
				cllc cra, l.anon$1
				cseal ct4, cra, ca2
				csc ct4, 112(cfp)
				addi t0, zero, 32
				cllc ct1, mm.alloc_cap
				clc ct1, 0(ct1)
				cjalr ct1, ct1
				cmove ct4, ct0
				csc ct4, 128(cfp)
				csc cs1, 96(cfp)
				mv a0, a3
				csc ca1, 80(cfp)
				addi t4, zero, 0
				csw t4, 64(cfp)
				.4byte 4276322779 # cclear 0, 227
				.4byte 4276587867 # cclear 1, 250
				.4byte 4276850651 # cclear 2, 255
				.4byte 4277112795 # cclear 3, 255
				clc ct4, 80(cfp)
				clc ct5, 96(cfp)
				cllc ct0, mm.cseal_cap
				clc ct0, 0(ct0)
				cjalr ct0, ct0
				cllc cra, mm.ret$1
				cseal cra, cra, ct6
				cseal cfp, cfp, ct6
				.4byte 4276125787 # cclear 0, 32
				.4byte 4277010523 # cclear 3, 128
				cinvoke ct4, ct5
mm.ret$1:		cmove cfp, ct6
cd.ret:			nop
				clw t4, 64(cfp)
				addi t5, zero, 0
				bne t4, t5, cd.then
cd.else:		addi t4, zero, 1
				csw t4, 64(cfp)
cd.endif:		clc cra, 112(cfp)
				clc ct4, 128(cfp)
				csc ca0, 0(ct4)
				clc ct4, 128(cfp)
				csc cra, 16(ct4)
				clc cs1, 128(cfp)
				cmove cra, cs1
				clc ct4, 0(cra)
				csc ct4, 48(cfp)
				addi a0, zero, 2
				clc ct4, 16(cs1)
				csc ct4, 32(cfp)
				addi t4, zero, 0
				csw t4, 16(cfp)
				.4byte 4276322779 # cclear 0, 227
				.4byte 4276587867 # cclear 1, 250
				.4byte 4276850651 # cclear 2, 255
				.4byte 4277112795 # cclear 3, 255
				clc ct4, 32(cfp)
				clc ct5, 48(cfp)
				cllc ct0, mm.cseal_cap
				clc ct0, 0(ct0)
				cjalr ct0, ct0
				cllc cra, mm.ret$2
				cseal cra, cra, ct6
				cseal cfp, cfp, ct6
				.4byte 4276125787 # cclear 0, 32
				.4byte 4277010523 # cclear 3, 128
				cinvoke ct4, ct5
mm.ret$2:		cmove cfp, ct6
cd.ret$1:		nop
				clw t4, 16(cfp)
				addi t5, zero, 0
				bne t4, t5, cd.then$1
cd.else$1:		addi t4, zero, 1
				csw t4, 16(cfp)
cd.endif$1:		clc cra, 144(cfp)
				.4byte 4276322523 # cclear 0, 225
				.4byte 4276587867 # cclear 1, 250
				.4byte 4276850651 # cclear 2, 255
				.4byte 4277112795 # cclear 3, 255
				clc cfp, 0(cfp)
				cinvoke cra, cfp
cd.then$1:		cmove cra, cnull
				addi t4, zero, 0
				slli s1, t4, 2
				cincoffset cnull, cra, s1
				clw zero, 0(cnull)
				cjal cnull, cd.endif$1
cd.then:		cmove cra, cnull
				addi t4, zero, 0
				slli s1, t4, 2
				cincoffset cnull, cra, s1
				clw zero, 0(cnull)
				cjal cnull, cd.endif
l.anon:			addi t0, zero, 16
				cllc ct1, mm.alloc_cap
				clc ct1, 0(ct1)
				cjalr ct1, ct1
				csc cfp, 0(ct0)
				cmove cfp, ct0
				clc ca1, 0(ct6)
				addi t0, zero, 4
				cllc ct1, mm.alloc_cap
				clc ct1, 0(ct1)
				cjalr ct1, ct1
				cmove cs1, ct0
				csw a0, 0(cs1)
				cseal ca0, cs1, ca1
				.4byte 4276322523 # cclear 0, 225
				.4byte 4276587867 # cclear 1, 250
				.4byte 4276850651 # cclear 2, 255
				.4byte 4277112795 # cclear 3, 255
				clc cfp, 0(cfp)
				cinvoke cra, cfp
l.anon$1:		addi t0, zero, 16
				cllc ct1, mm.alloc_cap
				clc ct1, 0(ct1)
				cjalr ct1, ct1
				csc cfp, 0(ct0)
				cmove cfp, ct0
				clw s1, 0(ct6)
				add a0, s1, a0
				.4byte 4276322523 # cclear 0, 225
				.4byte 4276587867 # cclear 1, 250
				.4byte 4276850651 # cclear 2, 255
				.4byte 4277112795 # cclear 3, 255
				clc cfp, 0(cfp)
				cinvoke cra, cfp
				.balign 16
mm.alloc_cap:	.octa 0
mm.cseal_cap:	.octa 0
mm.user_end:	.balign 4
				.bss
				.balign 16
mm.heap:		.fill 1048576, 1, 0
mm.heap_end:	.balign 4
				
				.data
				.align 6
				.global tohost
tohost:			.dword 0