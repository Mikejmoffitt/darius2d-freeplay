; Free Play
	CPU 68000
	PADDING OFF
	ORG		$000000
	BINCLUDE	"prg.orig"

ROM_FREE = $78000
RAM_BASE = $100000
STACK_BASE = RAM_BASE + $FFFE
WRAM_BASE = RAM_BASE + $8000
START_LATCH_MEM = $10F000
CREDIT_COUNT = RAM_BASE + $009DEC

	ORG	$000000

; Set the region.
; 0 - World
; 1 - Japan
; 2 - USA (romstar)
	ORG	$07FFFE
	dc.w	$0000

; Say "Darius II" on the title, regardless of region.
	ORG	$0051F0
	nop

; Disable checksum
	ORG	$11C0
	bra	$121C

; Disable coin error
	ORG	$013A0C
	rts

; Credit string for the corner is here
	ORG	$0030E6
	dc.b	"      "

; Hide credit count in the corner
	ORG	$30F2
	rts

; Start buttons add credits instead of cion
	ORG	$013A94
	btst	#2, d0

	ORG	$013AB4
	btst	#3, d0

; Latch start buttons when detecting a "coin entry".
	ORG	$013AD4
	jmp	start_latch

; Have Press Start screen operate on latched buttons.
	ORG	$1858
	jmp	start_screen_use_latch

; Change "Insert Coin" text to "Press Start"
	ORG	$003E66
	dc.b	"PRESS START"

; Coin Inserts do not play sounds
	ORG	$013B78
	nop
	nop
	nop
	nop
	nop

; Seemingly unused printing function?
	ORG	$009B92
	bra.w	$009DB0

; Make the Continue screen always prompt for a button
	ORG	$009D96
	bra.w	$009DB0

; "Push 2P Button to Start"
	ORG	$00A1BE
	nop
	nop

; "Push 1P Button to Start"
	ORG	$009F92
	nop
	nop

	ORG	$009FA8
;	nop
;	nop

; Game over clears credits.
	ORG	$002784
	jsr	game_over_clear_credits

	ORG	ROM_FREE

; At the Game Over prompt, clear the credits.
game_over_clear_credits:
	move.w	#$0, CREDIT_COUNT
	jmp	$007730

; Stick buttons at START_LATCH_MEM, test 0(a0), and jump back to adding a coino.
start_latch:
	bne	.coin_not_pressed
	move.w	d0, START_LATCH_MEM

	tst.w	0(a0)
	bne	.nonzero
	clr.w	0(a0)
	rts

.nonzero:
	clr.w	0(a0)
	jmp	$013AE4

.coin_not_pressed:
	move.w	#$FFFF, 0(a0)
	rts

; Have the Press Start Screen read the button latch.
start_screen_use_latch:
	move.w	START_LATCH_MEM, d1
	btst	#2, d1 ; Check p2 start
	bne.s	.p2_start_pressed
	btst	#3, d1
	bne.s	.p1_start_pressed
	jmp	$001868

.p1_start_pressed:
	; Play the original coin sound on game start
	move.w	#$1B, d0
	jsr	$007730
	jmp	$0018B6

.p2_start_pressed:
	; Play the original coin sound on game start
	move.w	#$1B, d0
	jsr	$007730
	jmp	$001870
