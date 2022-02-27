				.text
				
				.globl _start
_start:			la t0, _trap_vector
				csrw mtvec, t0
				la t0, main
				csrw mepc, t0
				mret
				
				.align 4
_trap_vector:	li gp, 3
				j _exit
				
_exit:			auipc t5, 0x1
				sw gp, tohost, t5
				j _exit
				
main:			la ra, rv.main
				jalr ra, ra
				li gp, 1
				j _exit
				
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
				j cd.then
cd.then:		j cd.then$1
cd.then$1:		call recFib
				j cd.ret
cd.ret:			mv s1, a0
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
				j cd.pred
cd.pred:		bgt s1, a0, cd.then$2
				j cd.else
cd.then$2:		cmove ca0, ca5
				mv s1, a6
				slli s1, s1, 4
				cincoffset cs1, ca0, s1
				lw.cap s1, 0(cs1)
				mv a0, s1
				cincoffsetimm csp, cfp, 8
				lc.cap cfp, 0(cfp)
				ret.cap
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
				j cd.then$3
cd.then$3:		slli s1, a0, 4
				cincoffset ct0, ca1, s1
				sw.cap s1, 0(ct0)
				mv s1, a3
				mv a1, a6
				cmove ca2, ca5
				mv a0, s1
				j cd.then$4
cd.then$4:		j cd.then$5
cd.then$5:		call recFib
				j cd.ret$1
cd.ret$1:		mv s1, a0
				mv a0, s1
				cincoffsetimm csp, cfp, 8
				lc.cap cfp, 0(cfp)
				ret.cap
rv.main:		cincoffsetimm ct0, csp, -8
				sc.cap cfp, 0(ct0)
				cmove cfp, ct0
				cincoffsetimm csp, csp, -8
				addi a0, zero, 1
				addi a1, zero, 1
				call fib
				j cd.ret$2
cd.ret$2:		cincoffsetimm csp, cfp, 8
				lc.cap cfp, 0(cfp)
				ret.cap
				
				.align 6
				.global tohost
tohost:			.dword 0