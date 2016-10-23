	.section	.text
	.globl	_start
	.globl	bfmain
_start:
	pushq	%rbx
	pushq	%r12
	xorl	%r12d, %r12d
	call	bfmain
	popq	%r12
	popq	%rbx
	movl	$60, %eax
	xorl	%edi, %edi
	syscall
bfgetchar:
	xorl	%eax, %eax
	movl	%eax, %edi
	movl	$1, %edx
	movq	%rbx, %rsi
	syscall
	ret
bfputchar:
	movl	$1, %eax
	movl	%eax, %edi
	movl	%eax, %edx
	movq	%rbx, %rsi
	syscall
	ret
