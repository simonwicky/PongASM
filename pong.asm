.equ	BALL, 		0x1000		;ball state (position and velocity)
.equ	PADDLES,	0x1010		;paddles position
.equ	SCORES,		0x1018		;game scores
.equ	LEDS,		0x2000		;LED addesses
.equ	BUTTONS,	0x2030		;Button addresses


; BEGIN:clear_leds
	clear_leds:

		stw zero, LEDS (zero)
		stw zero, LEDS + 4 (zero)
		stw zero, LEDS + 8 (zero)
		ret
; END:clear_leds

; BEGIN:set_pixel

	set_pixel:
		addi $t0, zero, 0x0004			;$t0 = 4
		addi $t1, zero, 0x0008			;$t1 = 8

		addi $t2, zero, 0x0001			;$t2 = 1

		blt $a0, $t0, firstWord			;if coordx < 4 --> firstWord of LEDS
		blt $a0, $t1, secondWord		;if coordx < 8 --> secondWord of LEDS
		call thirdWord

		ret

	thirdWord:
		sub $t3, $a0, $t1				;$t3 = $a0 - $t1 ($a0 - 8)
		sll $t3, $t3, 0x0003			;$t3 = $t3 * 8
		add $t3, $t3, $a1				;$t3 = $t3 + coordy
		sllv $t2, $t2, $t3				;$t2 = $t2 << $t3
		stw $t3, LEDS ($t1)				;sto $t3 in LEDS + 8
		ret

	firstWord:
		add $t3, $a0, zero				;$t3 = $a0
		sll $t3, $t3, 0x0003			;$t3 = $t3 * 8
		add $t3, $t3, $a1				;$t3 = $t3 + coordy
		sllv $t2, $t2, $t3				;$t2 = $t2 << $t3
		stw $t3, LEDS (zero)			;sto $t3 in LEDS + 0
		ret

	secondWord:
		sub $t3, $a0, $t0				;$t3 = $a0 - $t1 ($a0 - 4)
		sll $t3, $t3, 0x0003			;$t3 = $t3 * 8
		add $t3, $t3, $a1				;$t3 = $t3 + coordy
		sllv $t2, $t2, $t3				;$t2 = $t2 << $t3
		stw $t3, LEDS ($t0)			;sto $t3 in LEDS + 4
		ret

; END:set_pixel

