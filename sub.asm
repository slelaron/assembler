	global          _start

_start:
	sub	rsp, 4 * 128 * 8
	mov	rcx, 128
	lea	rdi, [rsp + 3 * 128 * 8]
	call	read_long
	mov	rsi, rdi
	lea	rdi, [rsp + 2 * 128 * 8]
	call	read_long
	call	sub_long_long
	
	push	rbx
	mov	rbx, rsi
	mov	rsi, rdi
	mov	rdi, rbx
	pop	rbx
	
	cmp	rdx, 0
	je	.nothing
	call	print_sign
.nothing:
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
	
	or	rax, rax
.loop:
	add	[rdi], r8
	mov	r8, 0
	adc	r8, 0
	lea	rdi, [rdi + 8]
	dec	rcx
	jnz	.loop
	
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
sub_long_long:
	push	rax
	push	rcx	
	push	rbx
	push	rdi
	push	rsi
	push	r8
	
	call	compare
	;call	printf
	xor	rdx, rdx
	xor	rbx, rbx
	cmp	rax, 1
	jne	.loop
	mov	rbx, rsi
	mov	rsi, rdi
	mov	rdi, rbx
	mov	rdx, 1
	xor	rbx, rbx
.loop:
	mov	rax, [rsi]
	mov	r8, rbx
	xor	rbx, rbx
	sub	rax, r8
	jnb	.fix
	mov	rbx, 1
.fix:	
	sub	rax, [rdi]
	jnb	.fix1
	mov	rbx, 1	
.fix1:
	mov	[rsi], rax
	lea	rsi, [rsi + 8]
	lea	rdi, [rdi + 8]
	dec	rcx
	jnz	.loop	
	
	pop	r8
	pop	rsi
	pop	rdi
	pop	rbx
	pop	rcx
	pop	rax
	cmp	rdx, 1
	jne	.do_nothing
	push	rbx
	mov	rbx, rsi
	mov	rsi, rdi
	mov	rdi, rbx
	pop	rbx
.do_nothing:
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
	
print_sign:
	push	rax
	push	rbx
	push	rdi
	push	rsi
	push	rdx
	push	rcx
	push	r8
	
	xor	r8, r8
	
	sub	rsp, 1
	mov	rbx, '-'
	mov	[rsp], rbx
	mov	rsi, rsp
	mov	rax, 1
	mov	rdi, 1
	mov	rdx, 1
	syscall
	
	add	rsp, 1
	
	pop	r8
	pop	rcx
	pop	rdx
	pop	rsi
	pop	rdi
	pop	rbx
	pop	rax
	
	ret
	
	
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
;rdi - first number
;rsi - second number
;rcx - length
;rax - result
compare:
	push	rdi
	push	rsi
	push	rdx
	push	rbx
	push	rcx
	
	lea             rdi, [rdi + 8 * rcx - 8]
	lea             rsi, [rsi + 8 * rcx - 8]
	
.loop:
	mov	rbx, [rsi]
	cmp	rbx, [rdi]
	jb	return_first
	jg	return_second
	lea	rdi, [rdi - 8]
	lea	rsi, [rsi - 8]
	dec	rcx
	jnz	.loop
	
	pop	rcx
	pop	rbx
	pop	rdx
	pop	rsi
	pop	rdi
	ret
return_first:
	mov	rax, 1
	pop	rcx
	pop	rbx
	pop	rdx
	pop	rsi
	pop	rdi
	ret
	
return_second:
	mov	rax, 0
	pop	rcx
	pop	rbx
	pop	rdx
	pop	rsi
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
