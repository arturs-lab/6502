	    processor	6502

CPLDl		equ $7ffc	; CPLD extra port low
CPLDh		equ $7ffd	; CPLD extra port high
LED		equ $7ffe	; LED address
OUTREG	equ $7fff	; CPLD special reg
RAMLO		equ $4000	; beginning of RAM
RAMB2		equ $8000	; beginning of second bank of RAM
RAMHI		equ $c000	; end of RAM + 1


sn76489s	subroutine

x1	equ $10	; delay between control pin changes
x2	equ $04	; delay between bytes
x3	equ 10	; long delay between frq changes

t1	equ $00
t2	equ $02
temp1	equ $04
temp	equ $05

	    org   $8000	    ;Start of ROM $8000

RESET
sn76489	
	ldx #$00
	txs		; set stack pointer
	lda #$0
	sta t1
	lda #$01
	sta t1+1
	lda #$ff
	sta CPLDh

	lda #$ff	; noise attenuation
	jsr setsn

	lda #$bf	; tone 3 attenuation
	jsr setsn

	lda #$df	; tone 2 attenuation
	jsr setsn

	lda #$90	; tone 1 attenuation
	jsr setsn

.2	lda t1+1	; put t1 in A
	and #$0f
	ora #$80	; tone 1 pitch byte 1
	jsr setsn

	lda t1
	sta temp
	lda t1+1
	ror temp
	ror temp
	ror temp
	ror temp
	jsr setsn

	lda #x3
	jsr dly1

	clc
	lda #$01
	adc t1+1
	sta t1+1
	lda t1
	adc #0
	sta t1
	cmp #$04
	bne .2
	lda #$00
	cmp t1+1
	bne .2
	sta t1
	lda #$01
	sta t1+1

	lda #$9f	; tone 1 attenuation
	jsr setsn

	rts

setsn	sta CPLDl
	lda #$fe
	sta CPLDh
	lda #$fc
	sta CPLDh
	lda #x1
.16	clc
	sbc #$01
	bne .16
	lda #$fe
	sta CPLDh
	lda #$ff
	sta CPLDh
	rts

delay subroutine
delay	pha
	lda #$ff	; standard delay length
	jmp .9
dly1	pha
.9	pha
	lda #$ff		; or of you call delay1, give delay length in reg A
	sta temp1
	sta temp
.7	dec temp
	bne .7
	dec temp1
	bne .7
	pla
	clc
	sbc #$01
	bne .9
	pla
	rts

;;************************************************************************
;;  Interrupt Vectors            (fixed ROM addr. $FFEA-$FFFF)
;;************************************************************************
        org   $FFEA       ; IRQ Vectors $FFEA - FFFF
        
        dc.w  $0098         ;IRQ2    $0098   $FFEA & $FFEB
        dc.w  $0095          ;CMI     $0095
        dc.w  $ffee          ;TRAP    $FFEE & $FFEF
        dc.w  $009b          ;SIO     $009B  $FFF0 & $FFF1   
        dc.w  $0092          ;TOI     $0092
        dc.w  $008f          ;OIC     $008F
        dc.w  $008C          ;ICI     $008C
        dc.w  $008C         ;IRQ1    $0089
        dc.w  $008C          ;SWI     $0086
        dc.w  $008C          ;NMI     $0083
        dc.w  RESET           ;RESET   $FFFE & $FFFF


