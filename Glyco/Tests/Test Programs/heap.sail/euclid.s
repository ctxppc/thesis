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
				csetaddr ct0, ct0, zero
				addi t1, zero, 129
				candperm ct0, ct0, t1
				cllc ct1, mm.seal_cap
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
				cllc ct0, mm.scall
				cllc ct1, mm.scall_end
				csub t1, ct1, ct0
				csetbounds ct0, ct0, t1
				addi t1, zero, 63
				candperm ct0, ct0, t1
				csealentry ct0, ct0
				cllc ct1, mm.scall_cap
				csc ct0, 0(ct1)
				cllc ct6, rv.main
				cllc ct0, mm.user_end
				csub t0, ct0, ct6
				csetbounds ct6, ct6, t0
				addi t0, zero, 319
				candperm ct6, ct6, t0
				cllc ct0, mm.savedRA
				csc cra, 0(ct0)
				cmove cfp, ct6
				addi t0, zero, 317
				candperm cfp, cfp, t0
				cllc cra, mm.ret
				.4byte 4276326107 # cclear 0, 253
				.4byte 4276588379 # cclear 1, 254
				.4byte 4276850651 # cclear 2, 255
				.4byte 4276981723 # cclear 3, 127
				cllc ct0, mm.scall_cap
				clc ct0, 0(ct0)
				cjalr ct0, ct0
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
mm.scall:		cllc ct0, mm.seal_cap
				clc ct1, 0(ct0)
				cseal cra, cra, ct1
				cseal cfp, cfp, ct1
				cincoffsetimm ct1, ct1, 1
				csc ct1, 0(ct0)
				.4byte 4276191323 # cclear 0, 96
				cjalr cnull, ct6
				.balign 16
mm.seal_cap:	.octa 0
mm.scall_end:	.balign 4
				.balign 4
rv.main:		addi t0, zero, 48
				cllc ct1, mm.alloc_cap
				clc ct1, 0(ct1)
				cjalr ct1, ct1
				csc cfp, 0(ct0)
				cmove cfp, ct0
				csc cra, 32(cfp)
				addi a0, zero, 20
				addi a1, zero, 50
				addi t4, zero, 0
				cincoffsetimm ct0, cfp, 16
				sw.cap t4, 0(ct0)
				.4byte 4276322779 # cclear 0, 227
				.4byte 4276586843 # cclear 1, 242
				.4byte 4276850651 # cclear 2, 255
				.4byte 4277112795 # cclear 3, 255
				cllc cra, mm.ret$1
				cllc ct6, gcd
				cllc ct0, mm.scall_cap
				clc ct0, 0(ct0)
				cjalr ct0, ct0
mm.ret$1:		cmove cfp, ct6
cd.ret:			nop
				cincoffsetimm ct0, cfp, 16
				lw.cap t4, 0(ct0)
				addi t5, zero, 0
				bne t4, t5, cd.then
cd.else:		addi t4, zero, 1
				cincoffsetimm ct0, cfp, 16
				sw.cap t4, 0(ct0)
cd.endif:		clc cra, 32(cfp)
				.4byte 4276322523 # cclear 0, 225
				.4byte 4276587867 # cclear 1, 250
				.4byte 4276850651 # cclear 2, 255
				.4byte 4277112795 # cclear 3, 255
				clc cfp, 0(cfp)
				cinvoke cra, cfp
cd.then:		cmove cra, cnull
				addi t4, zero, 0
				slli s1, t4, 2
				cincoffset cnull, cra, s1
				lw.cap zero, 0(cnull)
				cjal cnull, cd.endif
gcd:			addi t0, zero, 48
				cllc ct1, mm.alloc_cap
				clc ct1, 0(ct1)
				cjalr ct1, ct1
				csc cfp, 0(ct0)
				cmove cfp, ct0
				csc cra, 32(cfp)
				mv a2, a0
				mv ra, a2
				mv s1, a1
cd.pred:		nop
				beq ra, s1, cd.then$1
cd.else$1:		mv ra, a2
				mv s1, a1
cd.pred$1:		nop
				bgt ra, s1, cd.then$2
cd.else$2:		mv a0, a2
				sub a1, a1, a2
				addi t4, zero, 0
				cincoffsetimm ct0, cfp, 20
				sw.cap t4, 0(ct0)
				.4byte 4276322779 # cclear 0, 227
				.4byte 4276586843 # cclear 1, 242
				.4byte 4276850651 # cclear 2, 255
				.4byte 4277112795 # cclear 3, 255
				cllc cra, mm.ret$2
				cllc ct6, gcd
				cllc ct0, mm.scall_cap
				clc ct0, 0(ct0)
				cjalr ct0, ct0
mm.ret$2:		cmove cfp, ct6
cd.ret$2:		nop
				cincoffsetimm ct0, cfp, 20
				lw.cap t4, 0(ct0)
				addi t5, zero, 0
				bne t4, t5, cd.then$4
cd.else$4:		addi t4, zero, 1
				cincoffsetimm ct0, cfp, 20
				sw.cap t4, 0(ct0)
cd.endif$2:		clc cra, 32(cfp)
				.4byte 4276322523 # cclear 0, 225
				.4byte 4276587867 # cclear 1, 250
				.4byte 4276850651 # cclear 2, 255
				.4byte 4277112795 # cclear 3, 255
				clc cfp, 0(cfp)
				cinvoke cra, cfp
cd.then$4:		cmove cra, cnull
				addi t4, zero, 0
				slli s1, t4, 2
				cincoffset cnull, cra, s1
				lw.cap zero, 0(cnull)
				cjal cnull, cd.endif$2
cd.then$2:		mv ra, a1
				sub a0, a2, ra
				addi t4, zero, 0
				cincoffsetimm ct0, cfp, 16
				sw.cap t4, 0(ct0)
				.4byte 4276322779 # cclear 0, 227
				.4byte 4276586843 # cclear 1, 242
				.4byte 4276850651 # cclear 2, 255
				.4byte 4277112795 # cclear 3, 255
				cllc cra, mm.ret$3
				cllc ct6, gcd
				cllc ct0, mm.scall_cap
				clc ct0, 0(ct0)
				cjalr ct0, ct0
mm.ret$3:		cmove cfp, ct6
cd.ret$1:		nop
				cincoffsetimm ct0, cfp, 16
				lw.cap t4, 0(ct0)
				addi t5, zero, 0
				bne t4, t5, cd.then$3
cd.else$3:		addi t4, zero, 1
				cincoffsetimm ct0, cfp, 16
				sw.cap t4, 0(ct0)
cd.endif$1:		clc cra, 32(cfp)
				.4byte 4276322523 # cclear 0, 225
				.4byte 4276587867 # cclear 1, 250
				.4byte 4276850651 # cclear 2, 255
				.4byte 4277112795 # cclear 3, 255
				clc cfp, 0(cfp)
				cinvoke cra, cfp
cd.then$3:		cmove cra, cnull
				addi t4, zero, 0
				slli s1, t4, 2
				cincoffset cnull, cra, s1
				lw.cap zero, 0(cnull)
				cjal cnull, cd.endif$1
cd.then$1:		mv a0, a2
				clc cra, 32(cfp)
				.4byte 4276322523 # cclear 0, 225
				.4byte 4276587867 # cclear 1, 250
				.4byte 4276850651 # cclear 2, 255
				.4byte 4277112795 # cclear 3, 255
				clc cfp, 0(cfp)
				cinvoke cra, cfp
				.balign 16
mm.alloc_cap:	.octa 0
mm.scall_cap:	.octa 0
mm.user_end:	.balign 4
				.bss
				.balign 16
mm.heap:		.fill 1048576, 1, 0
mm.heap_end:	.balign 4
				
				.data
				.align 6
				.global tohost
tohost:			.dword 0