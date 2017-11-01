.equ	BALL, 		0x1000		;ball state (position and velocity)
.equ	PADDLES,	0x1010		;paddles position
.equ	SCORES,		0x1018		;game scores
.equ	LEDS,		0x2000		;LED addesses
.equ	BUTTONS,	0x2030		;Button addresses



main:  addi a0, zero, 0x0008
    addi a1, zero, 0x0003
    call set_pixel
    addi a0, zero, 0x0009
    addi a1, zero, 0x0004
    call set_pixel
    addi a0, zero, 0x0005
    addi a1, zero, 0x0006
    call set_pixel
    call clear_leds
    break


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



; BEGIN:hit_Test





