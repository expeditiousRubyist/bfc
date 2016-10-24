	.section	.text
	.globl	_start
	.globl	bfmain
_start:
	mov	r5, #0
	bl	bfmain
	mov	r0, #0
	mov	r7, #1
	swi	#0
bfgetchar:
	mov	r0, #0
	mov	r1, r4
	mov	r2, #1
	mov	r7, #3
	swi	#0
	bx	lr
bfputchar:
	mov	r0, #1
	mov	r1, r4
	mov	r2, #1
	mov	r7, #4
	swi	#0
	bx	lr
