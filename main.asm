;
; ECE 3613 Lab 7 Activity 1.asm
;
; Created: 3/20/2020 12:03:46 AM
; Author  : Leomar Duran <https://github.com/lduran2>
; Designer: Sung Choi
; Board   : ATmega324PB Xplained Pro - 2505
; For     : ECE 3612, Spring 2020
;
; Part  I: (only switch 0 closed) Compares the results of
; multiplication and logical left shifting.
;
; Part II: (only switch 1 closed) Compares the results of division and
; logical right shifting.
; (Note that the dividend 128 is unsigned, so logical shift is used
; instead of arithmetic.)
;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MACROS

.equ	N_PART1=16	;the value of the multiplier R16 for part I
.equ	N_PART2=128	;the value of the   dividend R16 for part II

; Branches parts depending on the bit set of @0.
; @params
;   @0 -- register to test
;   @1 -- the parent label of the parts
.macro	ON_PART
	cpi	@0,0b00000001	;if Part I
	breq	@1_PART1
	cpi	@0,0b00000010	;if Part II
	breq	@1_PART2
	rjmp START	;restart to attempt different input
.endmacro	;ON_PART


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BEGIN PROGRAM

;set up PORTA for output
	ldi	r16,0xFF	;to PORTA data direction register
	out	DDRA,r16	;all output
;close PORTB pull switches
	ldi	r16,0xFF	;to PORTB out
	out	PORTB,r16	;all closed
;set up PORTB for input
	ldi	r16,0x00	;to PORTB data direction register
	out	DDRB,r16	;all input

;everything is set up
START:
	in	r22,PINB	;read PORTB for input
	;0b00000001 for Part I
	;0b00000010 for Part II

	rcall	LOAD_R16	;load r16 = N
	ldi	R18,1	;counter
	rcall	LOAD_R20	;load r20
	out	PORTA,r20	;display r20 on LEDs
	rcall	DISPLAY_2SEC_OFF_1SEC	;display for 2 seconds,
		;then turn-off for 1 seconds
SHIFT_LOOP:
	rcall	SHIFT_R16	;shift r16
	cp	r16,r20	;if R16 = R20:
		breq	RESULT	;output the result
	inc	r18	;otherwise, increase the counter
	rjmp	SHIFT_LOOP	;and shift again
RESULT:
	out	PORTA,r18	;output r18 on LEDs
	rcall	DISPLAY_2SEC_OFF_1SEC	;display for 2 seconds and off

END:	rjmp END	;hold indefinitely


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SUBROUTINES

;loads r16 depending on which part
LOAD_R16:
	ON_PART	r22,LOAD_R16	;branch depending on part number
LOAD_R16_PART1:
	ldi	r16,N_PART1	; 16 for Part I
	ret
LOAD_R16_PART2:
	ldi	r16,N_PART2	;128 for Part II
	ret

;loads r20 depending on which part
LOAD_R20:
	ON_PART	r22,LOAD_R20	;branch depending on part number
LOAD_R20_PART1:
	ldi	r20,low(N_PART1*4)	;multiply r16* 4 for Part I
		;and load the lower byte into r20
	ret
LOAD_R20_PART2:
	ldi	r20,low(N_PART2/64)	;multiply r16/64 for Part II
		;and load the lower byte into r20
	ret

;shifts r16 with the direction depending on part number
SHIFT_R16:
	ON_PART	r22,SHIFT_R16	;branch depending on part number
SHIFT_R16_PART1:
	lsl	r16	;shift  left for Part I
	ret
SHIFT_R16_PART2:
	lsr	r16	;shift right for Part II
	ret

;delays for 2 seconds, then turns off all LEDs, and delays again for 1 second
;@returns
;  R27   := 0
;  PORTA := 0
DISPLAY_2SEC_OFF_1SEC:
	ldi	r27,2	;for 2 seconds
DISPLAY_DELAY:
	rcall	DELAY	;perform the delay for the remaining time
	dec	r27	;count down from 2 seconds
	brne	DISPLAY_DELAY	;delay again
	ldi	r27,0x00	;to PORTA
	out	PORTA,r27	;all LEDs off
	rcall	DELAY	;delay for 1 second
	ret

;delays by 1/2 [s]
;@returns
;  R24 := 0
;  R25 := 0
;  R26 := 0
DELAY: LDI r24,212	;212 for 1 second, 106 for 0.5 second
	L1: LDI R25, 100
	L2: LDI R26, 150
	L3: NOP
		NOP
		DEC R26
		BRNE L3
		DEC R25
		BRNE L2
		DEC R24
		BRNE L1

	RET
