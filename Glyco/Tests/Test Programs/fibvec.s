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
				
				.align 4
rv.init:		cllc ca0, mm.heap
				cllc ca1, mm.heap.end
				csub a2, ca1, ca0
				csetbounds ca0, ca0, a2
				addi a4, zero, 7
				candperm ca0, ca0, a4
				cllc ca3, mm.heap.cap
				sc.cap ca0, 0(ca3)
				cllc ca0, mm.alloc
				cllc ca1, mm.alloc.end
				csub a2, ca1, ca0
				csetbounds ca0, ca0, a2
				addi a4, zero, 5
				candperm ca0, ca0, a4
				csealentry ca0, ca0
				cllc ca3, mm.alloc.cap
				sc.cap ca0, 0(ca3)
				ret.cap
				.align 4
mm.alloc:		cllc ca1, mm.heap.cap
				lc.cap ca2, 0(ca1)
				csetbounds ca0, ca2, a0
				cgetlen a3, ca0
				cincoffset ca2, ca2, a3
				sc.cap ca2, 0(ca1)
				ret.cap
mm.heap.cap:	.quad 0
mm.alloc.end:	.dword 0
mm.user:
mm.alloc.cap:	.quad 0
				.align 4
rv.main:		cincoffsetimm ct0, csp, -8
				sc.cap cfp, 0(ct0)
				cmove cfp, ct0
				cincoffsetimm csp, csp, -8
				addi a0, zero, 1
				addi a1, zero, 1
				ccall fib
cd.ret:			cincoffsetimm csp, cfp, 8
				lc.cap cfp, 0(cfp)
				ret.cap
fib:			cincoffsetimm ct0, csp, -8
				sc.cap cfp, 0(ct0)
				cmove cfp, ct0
				cincoffsetimm csp, csp, -8
				mv s1, a0
				mv s1, a1
				addi s1, zero, 2
				addi a1, zero, 29
				cincoffsetimm ca2, csp, -120
				csetboundsimm ca2, ca2, 120
				cgetaddr t0, ca2
				csetaddr csp, csp, t0
				mv a0, s1
cd.then:		add zero, zero, zero
cd.then$1:		add zero, zero, zero
				ccall recFib
cd.ret$1:		mv s1, a0
				mv a0, s1
				cincoffsetimm csp, cfp, 8
				lc.cap cfp, 0(cfp)
				ret.cap
recFib:			cincoffsetimm ct0, csp, -8
				sc.cap cfp, 0(ct0)
				cmove cfp, ct0
				cincoffsetimm csp, csp, -8
				mv a4, a0
				mv a6, a1
				cmove ca5, ca2
				mv s1, a4
				mv a0, a6
cd.pred:		add zero, zero, zero
				bgt s1, a0, cd.then$2
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
				slli s1, s1, 4
				cincoffset ca1, ca0, s1
				lw.cap a1, 0(ca1)
				cmove ca0, ca5
				mv s1, a2
				slli s1, s1, 4
				cincoffset cs1, ca0, s1
				lw.cap s1, 0(cs1)
				add s1, a1, s1
				cmove ca1, ca5
				mv a0, a4
cd.then$3:		slli s1, a0, 4
				cincoffset ct0, ca1, s1
				sw.cap s1, 0(ct0)
				mv s1, a3
				mv a1, a6
				cmove ca2, ca5
				mv a0, s1
cd.then$4:		add zero, zero, zero
cd.then$5:		add zero, zero, zero
				ccall recFib
cd.ret$2:		mv s1, a0
				mv a0, s1
				cincoffsetimm csp, cfp, 8
				lc.cap cfp, 0(cfp)
				ret.cap
cd.then$2:		cmove ca0, ca5
				mv s1, a6
				slli s1, s1, 4
				cincoffset cs1, ca0, s1
				lw.cap s1, 0(cs1)
				mv a0, s1
				cincoffsetimm csp, cfp, 8
				lc.cap cfp, 0(cfp)
				ret.cap
mm.user.end:	.dword 0
mm.heap:		.fill 1048576, 1, 0
mm.heap.end:	.dword 0
				
rv.end:			.align 6
				.global tohost
tohost:			.dword 0