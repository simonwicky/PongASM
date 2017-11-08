.equ	BALL, 		0x1000		;ball state (position and velocity)
.equ	PADDLES,	0x1010		;paddles position
.equ	SCORES,		0x1018		;game scores
.equ	LEDS,		0x2000		;LED addesses
.equ	BUTTONS,	0x2030		;Button addresses



main:	addi	t0, zero, 0x3
		stw		t0, PADDLES(zero)
		stw		t0, PADDLES+4(zero)
		addi	sp, zero, LEDS

loop:	call 	clear_leds
		call	draw_paddles
		call	move_paddles
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
		addi 	t0, zero, 0x0004			;t0 = 4
		addi 	t1, zero, 0x0008			;t1 = 8

		addi 	t2, zero, 0x0001			;t2 = 1 it will be the pixel want to change in the word


		blt 	a0, t0, firstWord			;if coordx < 4 --> firstWord of LEDS
		blt 	a0, t1, secondWord			;if coordx < 8 --> secondWord of LEDS
		br 		thirdWord

		

	thirdWord:
		sub 	t3, a0, t1					;t3 = a0 - t1 (a0 - 8)
		slli 	t3, t3, 0x0003				;t3 = t3 * 8
		add 	t3, t3, a1					;t3 = t3 + coordy
		sll 	t2, t2, t3					;t2 = t2 << t3
		ldw 	t4, LEDS (t1)				;t4 = actual state of LEDS word we're going to change
		or 		t2, t2, t4					;t2 = t4 or t2
		stw 	t2, LEDS (t1)				;sto t2 in LEDS + 8
		ret

	firstWord:
		add 	t3, a0, zero				;t3 = a0
		slli 	t3, t3, 0x0003				;t3 = t3 * 8
		add 	t3, t3, a1					;t3 = t3 + coordy
		sll 	t2, t2, t3					;t2 = t2 << t3

		ldw 	t4, LEDS (zero)				;t4 = actual state of LEDS word we're going to change
		or 		t2, t2, t4					;t2 = t2 or t4
		stw 	t2, LEDS (zero)				;sto t2 in LEDS + 0
		ret

	secondWord:
		sub 	t3, a0, t0					;t3 = a0 - t1 (a0 - 4)
		slli 	t3, t3, 0x0003				;t3 = t3 * 8
		add 	t3, t3, a1					;t3 = t3 + coordy
		sll 	t2, t2, t3					;t2 = t2 << t3
		ldw 	t4, LEDS (zero)				;t4 = actual state of LEDS word we're going to change
		or 		t2, t2, t4					;t2 = t2 or t4s
		stw 	t2, LEDS (t0)				;sto t2 in LEDS + 4
		ret

; END:set_pixel



; BEGIN:hit_test
	stack_s_temp:
		addi 	sp, sp, -20					;make 5 places in Stack
		stw 	s0, 16(sp)					;push s0
		stw 	s1, 12(sp)					;push s1
		stw 	s2, 8(sp)					;push s2
		stw 	s3, 4(sp)					;push s3
		stw 	s4	0(sp)					;push s4
	
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
		br		x_paddle


	up:
		add		t4, t4, t0;					;t4 = t4 + 2
		br 		x_paddle

	bottom:
		sub		t4, t4, t0;					;t4 = t4 - 2
		br 		x_paddle

	x_paddle:
		add 	s1, t1, t3					;next position x of the ball
		beq		s1, zero, x_left_paddle		;if s1 = 0 branch x_left_paddle
		addi	t5, zero, 0xB				;t5 = 11
		beq 	s1, t5, x_right_paddle		;if s1 = 11 branch x_right_paddle
		br 		x_test


	x_left_paddle:
		addi 	s1, t2, t4 					;s1 = next coord y of the ball
		ldw 	s0, PADDLES(zero)			;s0 = y coord left_paddle
		addi 	s2, s0, -1					;uppper pixel of the left paddle
		beq		s1, s2, up_pix_left
		addi	s2, s0, 1					;s0 = lower pixel of the left paddle
		beq 	s1, s2, low_pix_right
		bne 	s1, s0, x_test
		addi 	t3, t3, 2					;t3 += 2
		br 		x_test

	up_pix_left:
		addi 	t3, t3, 2					;t3 += 2
		addi	t5, zero, 1					;t5 = 1
		bne 	t4, t5, x_test				;if the ball goes up -> nothing
		addi 	t4, t4, -2					;t4 = -1
		br 		x_test

	low_pix_left:
		addi 	t3, t3, 2					;t3 += 2
		addi	t5, zero, -1				;t5 = -1
		bne 	t4, t5, x_test				;if the ball goes down -> nothing
		addi 	t4, t4, 2					;t4 = +1
		br 		x_test




	x_right_paddle:
		addi 	s1, t2, t4 					;s1 = next coord y of the ball
		ldw 	s0, PADDLES+4(zero)			;s0 = y coord right_paddle
		addi 	s2, s0, -1					;uppper pixel of the right paddle
		beq		s1, s2, up_pix_right
		addi	s2, s0, 1					;s0 = lower pixel of the right paddle
		beq 	s1, s2, low_pix_right
		bne 	s1, s0, x_test
		addi 	t3, t3, -2					;t3 -= 2
		br 		x_test

	up_pix_right:
		addi 	t3, t3, -2					;t3 -= 2
		addi	t5, zero, 1					;t5 = 1
		bne 	t4, t5, x_test				;if the ball goes up -> nothing
		addi 	t4, t4, -2					;t4 = -1
		br 		x_test

	low_pix_right:
		addi 	t3, t3, -2					;t3 -= 2
		addi	t5, zero, -1				;t5 = -1
		bne 	t4, t5, x_test				;if the ball goes down -> nothing
		addi 	t4, t4, 2					;t4 = +1
		br 		x_test




	x_test:
		beq		t1, zero, left				;if t1 = zero => left
		addi	t5, zero, 0xB				;t5 = 11
		beq		t1, t5, right				;if t1 = 11 => right
		add		v0, zero, zero				; v0 = 0
		br		change_v

	left:
		addi	v0, zero, 2;				;v0 = 2
		br 		change_v

	right:
		addi	v0, zero, 1;				;v0 =  1
		br 		change_v


	change_v:
		stw		t3, BALL+8(zero)			;t3 = BALL VX
		stw		t4, BALL+12(zero)			;t4 = BALL VY	

	pop_s_temp:
		ldw 	s4, 0(sp)					;pop s4
		ldw 	s3, 4(sp)					;pop s3
		ldw 	s2, 8(sp)					;pop s2
		ldw 	s1, 12(sp)					;pop s1
		ldw 	s0, 16(sp)					;pop s0
		addi 	sp, sp, 20					;free space in Stack

		ret




; END:hit_test

; BEGIN:move_ball

	move_ball:
		ldw 	t0, BALL(zero)					;t0 = BALL X
		ldw 	t1, BALL + 4 (zero) 			;t1 = BALL y
		ldw 	t2, BALL + 8 (zero)				;t2 = BALL Vx
		ldw 	t3, BALL + 12 (zero)			;t3 = BALL vy


		add 	t0, t0, t2						;t0 = t0 + t2 (new BALL x)
		add 	t1, t1, t3						;t1 = t1 + t3 (new BALL y)

		stw		t0, BALL (zero)					;store the new BALL x 
		stw		t1, BALL + 4 (zero)				;store the new BALL y
		ret


; END:move_ball



; BEGIN:move_paddles
	move_paddles:
		ldw		t0, BUTTONS+4(zero)					;t0 = edgecapture
		ldw		t1, PADDLES (zero)					;t1 = left_paddle
		ldw		t2, PADDLES+4 (zero)				;t2 = right_paddle

		addi	t3, zero, 0x0001 					;t3 = 1
		and 	t4, t0, t3							;t4 = button(0)
		srli	t0, t0, 0x0001						;t0 = t0 >> 1
		and 	t5, t0, t3							;t5 = button(1)
		srli	t0, t0, 0x0001						;t0 = t0 >> 1
		and 	t6, t0, t3							;t6 = button(2)
		srli	t0, t0, 0x0001						;t0 = t0 >> 1
		and 	t7, t0, t3							;t7 = button(3)
		addi	t0, zero, 0x006						;t0 = 6

	l_up:
		beq 	t4, zero, l_down					;if button(0) = 0 => l_down
		bge 	t3, t1, l_down						;if left_paddle <= 1 => l_down
		sub		t1, t1, t3							;t1 = t1 - 1

	l_down:
		beq		t5, zero, r_up						;if button(1) = 0 => r_up
		bge 	t1, t0, r_up						;if left_paddle >= 6 => r_up
		add		t1, t1, t3							;t1 = t1 + 1


	r_up:
		beq		t6, zero, r_down					;if button(2) = 0 => r_down
		bge 	t3, t2, r_down						;if right <= 1 => r_down
		sub		t2, t2, t3							;t2 = t2 - 1

	r_down:
		beq		t7, zero, paddle_change				;if button(3) = 0 => paddle_change
		bge 	t2, t0, paddle_change				;if right_paddle >= 6 => paddle_change
		add		t2, t2, t3							;t2 = t2 + 1


	paddle_change:
		stw		t1, PADDLES (zero)					;sto left_paddle
		stw		t2, PADDLES+4 (zero)				;sto right_paddle
		stw		zero, BUTTONS+4(zero)				;edgecapture = 0
		ret

; END:move_paddles



; BEGIN:draw_paddles

	draw_paddles:

		addi	sp, sp, -12							;make free space in Stack 
		stw		a0, 8(sp)							;push a0
		stw		a1, 4(sp)							;push a1
		stw 	ra, 0(sp) 							;push return address

	draw_left:
		ldw		t0, PADDLES (zero)					;left_paddle_coord
		add 	a0, zero, zero						;a0 = xcoord
		addi 	a1, t0, -1							;a1 = y coord up pixel
		call 	set_pixel							;draw 
		addi 	a1, a1, 1							;a1 = center pixel y coord
		call 	set_pixel							;draw
		addi	a1, a1, 1							;a1 = bottom pixel coord y
		call 	set_pixel

	draw_right:
		ldw 	t1, PADDLES +4 (zero)				;right_paddle_coord
		addi 	a0, zero, 11						;idem here
		addi 	a1, t1, -1
		call 	set_pixel
		addi 	a1, a1, 1
		call 	set_pixel
		addi	a1, a1, 1
		call 	set_pixel

		ldw 	ra, 0(sp) 							;pop return address
		ldw 	a1, 4(sp)							;pop a1
		ldw 	a0, 8(sp)							;pop a0
		addi 	sp, sp, 12

		ret
		

			


; END:draw_paddles


; BEGIN:display_score

; END:display_score