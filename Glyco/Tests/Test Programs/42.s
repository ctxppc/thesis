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
				
f:				cincoffsetimm ct0, csp, -8
				sc.cap cfp, 0(ct0)
				cmove cfp, ct0
				cincoffsetimm csp, csp, -8
				addi a0, zero, 42
				cincoffsetimm csp, cfp, 8
				lc.cap cfp, 0(cfp)
				ret.cap
rv.main:		cincoffsetimm ct0, csp, -8
				sc.cap cfp, 0(ct0)
				cmove cfp, ct0
				cincoffsetimm csp, csp, -8
				call f
				j cd.ret
cd.ret:			cincoffsetimm csp, cfp, 8
				lc.cap cfp, 0(cfp)
				ret.cap
				
				.align 6
				.global tohost
tohost:			.dword 0