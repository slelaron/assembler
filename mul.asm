	global          _start

_start:
	sub	rsp, 5 * 128 * 8
	mov	rcx, 128
	lea	rdi, [rsp + 128 * 8]
	call	set_zero
	mov	r12, rdi
	mov	rdi, rsp
	call	set_zero
	mov	r13, rdi
	lea	rdi, [rsp + 4 * 128 * 8]
	call	set_zero
	lea	rdi, [rsp + 3 * 128 * 8]
	call	read_long
	mov	rsi, rdi
	lea	rdi, [rsp + 2 * 128 * 8]
	call	read_long
	call	mul_long_long
	
	push	rbx
	mov	rbx, rsi
	mov	rsi, rdi
	mov	rdi, rbx
	pop	rbx
	
	call	write_long
	
	call	exit
	
;rdi - long number
;r8 - short number
;rcx - length
mul_short:
	push	rdi
	push	rax
	push	rcx
	push	rdx
	push	rbx
	
	xor	rbx, rbx
	or	rax, rax
.loop:	
	mov	rax, [rdi]
	mul	r8
	add	rax, rbx
	adc	rdx, 0
	mov	rbx, rdx
	mov	[rdi], rax
	add	rdi, 8
	
	dec	rcx
	jnz	.loop
	
	pop	rbx
	pop	rdx
	pop	rcx
	pop	rax
	pop	rdi
	ret

;rdi - long number
;r8 - short number
;rcx - length	
add_short:
	push	rdi
	push	rax
	push	rcx
	push	rdx
	push	r8
	
	or	rax, rax
.loop:
	add	[rdi], r8
	mov	r8, 0
	adc	r8, 0
	lea	rdi, [rdi + 8]
	dec	rcx
	jnz	.loop
	
	pop	r8
	pop	rdx
	pop	rcx
	pop	rax
	pop	rdi
	ret	
	
;rdi - long number
;r8 - short number
;rcx - length
;rdx - result
div_short:
	push	rdi
	push	rax
	push	rcx
	push	rbx
	
	mov	rbx, r8
	
	lea	rcx, [rcx * 2]
	
	or	rax, rax
	xor	rdx, rdx
	
	lea             rdi, [rdi + 8 * rcx - 8]
.loop:
	
	mov	rax, [rdi]
	div	rbx
	mov	[rdi], rax
	sub	rdi, 8
	
	dec	rcx
	jnz	.loop
	
	pop	rbx
	pop	rcx
	pop	rax
	pop	rdi
	ret
	
;rdi - first number
;rsi - second number
;rcx - length
;rsi - result
;rdx - sign
add_long_long:
	push	rax
	push	rcx	
	push	rbx
	push	rdi
	push	rsi
	push	rdx
	
	xor	rbx, rbx
	or	rax, rax
.loop:
	mov	rax, [rdi]
	adc	[rsi], rax
	
	lea	rsi, [rsi + 8]
	lea	rdi, [rdi + 8]
	dec	rcx
	jnz	.loop
	
	pop	rdx
	pop	rsi
	pop	rdi
	pop	rbx
	pop	rcx
	pop	rax
	ret

;rdi - first number
;rsi - second number
;rcx - length
;r12, r13 - buffer
;rsi - result
mul_long_long:
	push	rdi
	push	rsi
	push	r12
	push	r13
	push	rcx
	push	r8
	push	r14
	push	r15
	push	rdx
	push	rbx
	
	mov	rdx, rcx
	
	mov	r14, rsi
	mov	r15, r13
	call	swap
	
	mov	r14, rdi
	mov	r15, r12
	call	copy

	
.loop:
	mov	r15, rdi
	mov	r14, r12
	call	copy
	
	
	mov	r8, [r13]
	call	mul_short
	
	call	add_long_long
	
	lea	r13, [r13 + 8]
	
	add	rsi, 8
	dec	rdx
	jnz	.loop
	
	pop	rbx
	pop	rdx
	pop	r15
	pop	r14
	pop	r8
	pop	rcx
	pop	r13
	pop	r12
	pop	rsi
	pop	rdi
	ret
	
	
set_zero:
	push	rax
	push	rdi
	push	rcx
	
	xor	rax, rax
	
	rep stosq
	
	pop	rcx
	pop	rdi
	pop	rax
	
	ret
	
;r14 - number
;r15 - place to copy
;rcx - length	
copy:
	push	r15
	push	r14
	push	rcx
	push	rbx

	
.loop:
	mov	rbx, [r14]
	mov	[r15], rbx
	lea	r14, [r14 + 8]
	lea	r15, [r15 + 8]
	dec	rcx
	jnz	.loop
	
	pop	rbx
	pop	rcx
	pop	r14
	pop	r15
	ret

;r14 - first number
;r15 - second number
;rcx - length	
swap:
	push	r15
	push	r14
	push	rcx
	push	rbx
	push	rax

	
.loop:
	mov	rbx, [r14]
	mov	rax, [r15]
	mov	[r14], rax
	mov	[r15], rbx
	lea	r14, [r14 + 8]
	lea	r15, [r15 + 8]
	dec	rcx
	jnz	.loop
	
	pop	rax
	pop	rbx
	pop	rcx
	pop	r14
	pop	r15
	ret
	
;rdi - address
;rcx - length
read_long:
	push	rdi
	push	r8
	push	rax
	push	rbx
	
	call	set_zero
	
.loop:	
	
	call	read_char
	
	cmp	rax, 0x0a
	je	end_of_read	
	cmp	rax, '0'
	jb	invalid_char
	cmp	rax, '9'
	jg	invalid_char
	sub	rax, '0'
	mov	r8, 10
	
	call	mul_short
	mov	r8, rax
	
	call	add_short
	
	jmp	.loop
	
end_of_read:
	pop	rbx
	pop	rax
	pop	r8
	pop	rdi
	ret
	
invalid_char:
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, msg
	mov	rdx, msg_size
	syscall
	
	call	exit
	
read_char:
	push	rsi
	push	rdi
	push	rcx
	push	rdx
	
	xor	rax, rax
	xor	rdi, rdi
	sub	rsp, 1
	mov	rsi, rsp
	add	rsp, 1
	mov	rdx, 1
	
	syscall
	
	cmp	rax, 1
	jne	error
	
	xor	rax, rax
	mov	al, [rsi]
	
	pop	rdx
	pop	rcx
	pop	rdi
	pop	rsi
	ret
;rdi - address
;rcx - length
;rax - result
is_zero:
	push	rdi
	push	rcx
	push	rbx
	
	xor	rax, rax
	
	lea	rcx, [rcx * 2]
	
.loop:
	mov	rbx, [rdi]
	cmp	rbx, 0
	jne	.wrong
	lea	rdi, [rdi + 8]
	dec	rcx
	jnz	.loop
	
	pop	rbx
	pop	rcx
	pop	rdi
	ret	
.wrong:
	mov	rax, 1
	pop	rbx
	pop	rcx
	pop	rdi
	
	ret	

;rdi - address
;rcx - length	
write_long:
	push	rax
	push	rdx
	push	rdi
	push	rsi
	push	rbx
	push	rcx
	push	r10
	
	;jmp	.ending
	
	mov	r10, rsp
	

.loop:
	mov	r8, 10
	call	div_short
	sub	rsp, 1
	add	rdx, '0'
	mov	[rsp], dl
	
	call	is_zero
	cmp	rax, 1
	je	.loop
	
.write_char:
	xor	r8, r8
	mov	rsi, rsp
	mov	rax, 1
	mov	rdi, 1
	mov	rdx, 1
	syscall
	
	add	rsp, 1
	
	cmp	r10, rsp
	jne	.write_char
	
	sub	rsp, 1
	mov	rbx, 0x0a
	mov	[rsp], rbx
	mov	rsi, rsp
	mov	rax, 1
	mov	rdi, 1
	mov	rdx, 1
	syscall
	
	add	rsp, 1
.ending:	
	pop	r10
	pop	rcx
	pop	rbx
	pop	rsi
	pop	rdi
	pop	rdx
	pop	rax
	
	ret
	
;rax -- what	
printf:
	push	rax
	push	rdx
	push	rdi
	push	rsi
	push	rbx
	push	rcx
	push	r10
	
	mov	r10, rsp
	xor	rdx, rdx

.loop:
	mov	rbx, 10
	div	rbx
	add	rdx, '0'
	sub	rsp, 1
	mov	[rsp], dl
	xor	rdx, rdx
	
	cmp	rax, 0
	jne	.loop
	
.write:
	xor	r8, r8
	mov	rsi, rsp
	mov	rax, 1
	mov	rdi, 1
	mov	rdx, 1
	syscall
	
	add	rsp, 1
	
	cmp	r10, rsp
	jne	.write
	
	sub	rsp, 1
	mov	rbx, 0x0a
	mov	[rsp], rbx
	mov	rsi, rsp
	mov	rax, 1
	mov	rdi, 1
	mov	rdx, 1
	syscall
	
	add	rsp, 1
	
	pop	r10
	pop	rcx
	pop	rbx
	pop	rsi
	pop	rdi
	pop	rdx
	pop	rax
	
	ret
	

error:
	call	exit
	
exit:
	mov	rax, 60
	xor	rdi, rdi
	syscall
	
	section rodata

msg:	db	"Invalid char", 0x0a
msg_size:	equ	$ - msg
