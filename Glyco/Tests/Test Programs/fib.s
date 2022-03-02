				.text
				
				.global _start
_start:			la t0, _trap_vector
				csrw mtvec, t0
				la t0, rv.begin
				csrw mepc, t0
				mret
				
				.align 4
_trap_vector:	li gp, 3
				j _exit
				
_exit:			auipc t5, 0x1
				sw gp, tohost, t5
				j _exit
				
rv.begin:		la ra, rv.main
				jalr ra, ra
				li gp, 1
				j _exit
				
rv.main:		cincoffsetimm ct0, csp, -8
				sc.cap cfp, 0(ct0)
				cmove cfp, ct0
				cincoffsetimm csp, csp, -8
				addi a0, zero, 0
				addi a1, zero, 1
				addi a2, zero, 30
				call fib
cd.ret:			cincoffsetimm csp, cfp, 8
				lc.cap cfp, 0(cfp)
				ret.cap
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
				call fib
cd.ret$1:		mv s1, a0
				mv a0, s1
				cincoffsetimm csp, cfp, 8
				lc.cap cfp, 0(cfp)
				ret.cap
cd.then$2:		mv s1, a1
				mv a0, s1
				cincoffsetimm csp, cfp, 8
				lc.cap cfp, 0(cfp)
				ret.cap
				
rv.end:			.align 6
				.global tohost
tohost:			.dword 0