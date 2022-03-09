				.text
				
				.global _start
_start:			cllc ct0, _trap_vector
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
				
rv.begin:		ccall rv.init
				ccall rv.main
				li gp, 1
				j _exit
				
rv.init:		cllc ct0, mm.heap
				cllc ct1, mm.heap.end
				csub t1, ct1, ct0
				csetbounds ct0, ct0, t1
				addi t1, zero, 7
				candperm ct0, ct0, t1
				cllc ct1, mm.heap.cap
				sc.cap ct0, 0(ct1)
				cllc ct0, mm.alloc
				cllc ct1, mm.alloc.end
				csub t1, ct1, ct0
				csetbounds ct0, ct0, t1
				addi t1, zero, 5
				candperm ct0, ct0, t1
				csealentry ct0, ct0
				cllc ct1, mm.alloc.cap
				sc.cap ct0, 0(ct1)
				cjalr c0, cra
mm.alloc:		cllc ct1, mm.heap.cap
				lc.cap ct1, 0(ct1)
				csetbounds ct0, ct1, t0
				cgetlen t2, ct0
				cincoffset ct1, ct1, t2
				cllc ct2, mm.heap.cap
				sc.cap ct1, 0(ct2)
				cjalr c0, cra
mm.heap.cap:	.quad 0
mm.alloc.end:	.dword 0
rv.main:		cincoffsetimm ct0, csp, -8
				sc.cap cfp, 0(ct0)
				cmove cfp, ct0
				cincoffsetimm csp, csp, -8
				addi a0, zero, 0
				addi a1, zero, 1
				addi a2, zero, 30
				cjal cra, fib
cd.ret:			cincoffsetimm csp, cfp, 8
				lc.cap cfp, 0(cfp)
				cjalr c0, cra
fib:			cincoffsetimm ct0, csp, -8
				sc.cap cfp, 0(ct0)
				cmove cfp, ct0
				cincoffsetimm csp, csp, -8
				mv a3, a0
cd.then:		add zero, zero, zero
cd.then$1:		mv s1, a2
				addi a0, zero, 0
cd.pred:		add zero, zero, zero
				ble s1, a0, cd.then$2
cd.else:		mv a4, a1
				mv a0, a3
				mv s1, a1
				add a1, a0, s1
				mv s1, a2
				addi a0, zero, 1
				sub s1, s1, a0
				mv a0, a4
cd.then$3:		mv a2, s1
				cjal cra, fib
cd.ret$1:		mv s1, a0
				mv a0, s1
				cincoffsetimm csp, cfp, 8
				lc.cap cfp, 0(cfp)
				cjalr c0, cra
cd.then$2:		mv s1, a1
				mv a0, s1
				cincoffsetimm csp, cfp, 8
				lc.cap cfp, 0(cfp)
				cjalr c0, cra
mm.user:
mm.alloc.cap:	.quad 0
mm.user.end:	.dword 0
mm.heap:		.fill 1048576, 1, 0
mm.heap.end:	.dword 0
				
rv.end:			.align 6
				.global tohost
tohost:			.dword 0