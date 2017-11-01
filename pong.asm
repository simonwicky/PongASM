.equ	BALL, 		0x1000		;ball state (position and velocity)
.equ	PADDLES,	0x1010		;paddles position
.equ	SCORES,		0x1018		;game scores
.equ	LEDS,		0x2000		;LED addesses
.equ	BUTTONS,	0x2030		;Button addresses



main:	addi	t0, zero, 0x5
		addi 	t1, zero, 0x2
		stw		t0, BALL(zero)
		stw		t1, BALL+4(zero)
		addi	t0, zero, 0x1
		addi 	t1, zero, 0x1
		stw		t0, BALL+8(zero)
		stw		t1, BALL+12(zero)

loop:	call 	clear_leds
		call	hit_test
		call	set_pixel
		call	move_ball
		br		loop
		


; BEGIN:clear_leds
	clear_leds:

		stw zero, LEDS (zero)
		stw zero, LEDS + 4 (zero)
		stw zero, LEDS + 8 (zero)
		ret
; END:clear_leds



; BEGIN:set_pixel

	set_pixel:
		addi t0, zero, 0x0004			;t0 = 4
		addi t1, zero, 0x0008			;t1 = 8

		addi t2, zero, 0x0001			;t2 = 1 it will be the pixel want to change in the word


		blt a0, t0, firstWord			;if coordx < 4 --> firstWord of LEDS
		blt a0, t1, secondWord			;if coordx < 8 --> secondWord of LEDS
		br thirdWord

		

	thirdWord:
		sub t3, a0, t1					;t3 = a0 - t1 (a0 - 8)
		slli t3, t3, 0x0003				;t3 = t3 * 8
		add t3, t3, a1					;t3 = t3 + coordy
		sll t2, t2, t3					;t2 = t2 << t3
		ldw t4, LEDS (t1)				;t4 = actual state of LEDS word we're going to change
		or t2, t2, t4					;t2 = t4 or t2
		stw t2, LEDS (t1)				;sto t2 in LEDS + 8
		ret

	firstWord:
		add t3, a0, zero				;t3 = a0
		slli t3, t3, 0x0003				;t3 = t3 * 8
		add t3, t3, a1					;t3 = t3 + coordy
		sll t2, t2, t3					;t2 = t2 << t3

		ldw t4, LEDS (zero)				;t4 = actual state of LEDS word we're going to change
		or t2, t2, t4					;t2 = t2 or t4
		stw t2, LEDS (zero)				;sto t2 in LEDS + 0
		ret

	secondWord:
		sub t3, a0, t0					;t3 = a0 - t1 (a0 - 4)
		slli t3, t3, 0x0003				;t3 = t3 * 8
		add t3, t3, a1					;t3 = t3 + coordy
		sll t2, t2, t3					;t2 = t2 << t3
		ldw t4, LEDS (zero)				;t4 = actual state of LEDS word we're going to change
		or t2, t2, t4					;t2 = t2 or t4s
		stw t2, LEDS (t0)				;sto t2 in LEDS + 4
		ret

; END:set_pixel



; BEGIN:hit_test
	
	hit_test:
		addi 	t0, zero ,0x2 				;t0 = 2
		ldw		t1, BALL (zero)				;t1 = BALL X
		ldw		t2, BALL+4(zero)			;t2 = BALL Y
		ldw		t3, BALL+8(zero)			;t3 = BALL VX
		ldw		t4, BALL+12(zero)			;t4 = BALL VY

	y_test:
		beq		t2, zero, up				;if t2 = zero => up
		addi	t5, zero, 0x7				;t5 = 7
		beq		t2, t5, bottom				;if t2 = 7 => bottom


	up:
		add		t4, t4, t0;					;t4 = t4 + 2
		br 		x_test

	bottom:
		sub		t4, t4, t0;					;t4 = t4 - 2
		br 		x_test

	x_test:
		beq		t1, zero, left				;if t2 = zero => left
		addi	t5, zero, 0xB				;t5 = 11
		beq		t1, t5, right				;if t2 = 11 => right

	left:
		add		t3, t3, t0;					;t3 = t3 + 2
		br 		change_v

	right:
		sub		t3, t3, t0;					;t3 = t3 - 2
		br 		change_v


	change_v:
		stw		t3, BALL+8(zero)			;t3 = BALL VX
		stw		t4, BALL+12(zero)			;t4 = BALL VY	
		ret




; END:hit_test

; BEGIN:move_ball

	move_ball:
		ldw 	t0, BALL(zero)					;t0 = BALL X
		ldw 	t1, BALL + 4 (zero) 			;t1 = BALL y
		ldw 	t2, BALL + 8 (zero)				;t2 = BALL Vx
		ldw 	t3, BALL + 12 (zero)			;t3 = BALL vy


		add 	t4, t0, t2						;t4 = t0 + t2 (new BALL x)
		add 	t5, t1, t3						;t5 = t1 + t3 (new BALL y)

		stw		t4, BALL (zero)					;store the new BALL x 
		stw		t5, BALL + 4 (zero)				;store the new BALL y


; END:move_ball



