				.text
				
				.globl _start
_start:			la t0, _trap_vector
				csrw mtvec, t0
				la t0, _main
				csrw mepc, t0
				mret
				
				.align 4
_trap_vector:	li gp, 3
				j _exit
				
_exit:			auipc t5, 0x1
				sw gp, tohost, t5
				j _exit
				
_main:			la ra, main
				jalr ra, ra
				li gp, 1
				j _exit
				
fib:			clc fp, -8(csp)
				cincoffsetimm cfp, csp, -8
				cincoffsetimm csp, csp, -32
				cmove cs6, cs1
				cmove cs9, cs2
				cmove cs10, cs3
				cmove cs11, cs4
				cmove ct4, cs5
				cmove ct5, cs6
				cmove ct6, cs7
				clc s8, -8(ct0)
				clc s9, -16(ct0)
				cmove cs7, cs10
				cmove cs8, cs11
				mv s2, a0
				mv s1, a1
				mv s4, a2
				mv s3, s4
				addi s3, zero, 0
				j cd.pred
cd.pred:		j cd.then
cd.then:		j cd.then$1
cd.then$1:		mv a0, s1
				cmove cs1, cs6
				cmove cs2, cs9
				cmove cs3, cs10
				cmove cs4, cs11
				cmove cs5, ct4
				cmove cs6, ct5
				cmove cs7, ct6
				clc s8, -8(cfp)
				clc s9, -16(cfp)
				cmove cs10, cs7
				cmove cs11, cs8
				cincoffsetimm csp, cfp, 8
				clc fp, 0(cfp)
				ret
cd.else:		j cd.then$2
cd.then$2:		j cd.then$3
cd.then$3:		add s3, s2, s1
				mv s1, s4
				addi s2, zero, 1
				sub s1, s1, s2
				mv a0, s5
				mv a1, s3
				mv a2, s1
				ccall fib
				j cd.ret
cd.ret:			mv s1, a0
				mv a0, s1
				cmove cs1, cs6
				cmove cs2, cs9
				cmove cs3, cs10
				cmove cs4, cs11
				cmove cs5, ct4
				cmove cs6, ct5
				cmove cs7, ct6
				clc s8, -8(cfp)
				clc s9, -16(cfp)
				cmove cs10, cs7
				cmove cs11, cs8
				cincoffsetimm csp, cfp, 8
				clc fp, 0(cfp)
				ret
main:			clc fp, -8(csp)
				cincoffsetimm cfp, csp, -8
				cincoffsetimm csp, csp, -16
				addi a0, zero, 0
				addi a1, zero, 1
				addi a2, zero, 30
				ccall fib
				j cd.ret$1
cd.ret$1:		cincoffsetimm csp, cfp, 8
				clc fp, 0(cfp)
				ret
				
				.align 6
				.global tohost
tohost:			.dword 0