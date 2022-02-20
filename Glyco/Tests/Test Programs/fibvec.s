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
				
fib:			csc cfp, -8(csp)
				cincoffsetimm cfp, csp, -8
				cincoffsetimm csp, csp, -16
				mv s1, a0
				mv s1, a1
				addi s1, zero, 2
				addi a0, zero, 29
				cincoffsetimm ca1, csp, -120
				csetboundsimm ca1, ca1, 120
				cgetaddr t0, ca1
				csetaddr csp, csp, t0
				mv a0, s1
				mv a1, a0
				cmove ca2, ca1
				ccall recFib
				j cd.ret
cd.ret:			mv s1, a0
				mv a0, s1
				cincoffsetimm csp, cfp, 8
				clc cfp, 0(cfp)
				cret
recFib:			csc cfp, -8(csp)
				cincoffsetimm cfp, csp, -8
				cincoffsetimm csp, csp, -16
				mv a4, a0
				mv a6, a1
				cmove ca5, ca2
				mv s1, a4
				mv s1, a6
				j cd.pred
cd.pred:		j cd.else
cd.then:		cmove ca0, ca5
				mv s1, a6
				slli s1, s1, 4
				cincoffset cs1, ca0, s1
				lw.cap s1, 0(cs1)
				mv a0, s1
				cincoffsetimm csp, cfp, 8
				clc cfp, 0(cfp)
				cret
cd.else:		j cd.then$1
cd.then$1:		slli s1, a0, 4
				cincoffset ct0, ca1, s1
				sw.cap s1, 0(ct0)
				mv s1, a3
				mv a0, a6
				cmove ca1, ca5
				mv a0, s1
				mv a1, a0
				cmove ca2, ca1
				ccall recFib
				j cd.ret$1
cd.ret$1:		mv s1, a0
				mv a0, s1
				cincoffsetimm csp, cfp, 8
				clc cfp, 0(cfp)
				cret
rv.main:		csc cfp, -8(csp)
				cincoffsetimm cfp, csp, -8
				cincoffsetimm csp, csp, -16
				addi a0, zero, 1
				addi a1, zero, 1
				ccall fib
				j cd.ret$2
cd.ret$2:		cincoffsetimm csp, cfp, 8
				clc cfp, 0(cfp)
				cret
				
				.align 6
				.global tohost
tohost:			.dword 0