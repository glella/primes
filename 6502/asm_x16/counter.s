; primes.s
; compiles with: cl65 -t cx16 -o COUNTER.PRG counter.s 
; executes with: x16emu -debug 
; Test: get input from console, looping test and print numbers in decimal format

.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

    jmp start

; Zero Page
USR_PTR         = $30
STR_PTR         = $60

; Kernal
CHRIN           = $FFCF
CHROUT          = $FFD2

; PETSCII
RETURN          = $0D
CHAR_0          = $30
CHAR_9          = $39
NEWLINE         = $0D
SPACE           = $20

; Zero Page "registers" 16 bit       
U0 = USR_PTR      
U1 = U0+2
U2 = U1+2
U3 = U2+2
U4 = U3+2
U5 = U4+2
U6 = U5+2
U7 = U6+2
U8 = U7+2
U9 = U8+2
U10 = U9+2
U11 = U10+2
U12 = U11+2
U13 = U12+2
U14 = U13+2
U15 = U14+2

; Zero Page "registers" 8 bit
b1 = U15+2          
b2 = b1+1
b3 = b2+1
b4 = b3+1
b5 = b4+1
b6 = b5+1

; meaningful variable names
number = U0         ; division variables
divisor = U1
remain = U2
divresult = U3

num = U4            ; root variables
rem = U5
temp = U6
root = b1

isPrime = b2        ; main variables
count = U7
limit = U8
ivar = U9
nvar = divisor      ; reuse same register as it does not change during division & avoids assignments
printnum = U10
; U11 is used by PrDecimal subroutine

;Macros 6502 & 65C02S
;    .macro PushAll
;      pha
;      txa
;      pha
;      tya 
;      pha   
;   .endmacro

;   .macro PullAll
;       pla
;       tay
;       pla
;       tax
;       pla
;   .endmacro

    .macro PushAll
        pha
        phx
        phy
    .endmacro

    .macro PullAll
        ply
        plx
        pla
    .endmacro
    
    ; Loads a 16-bit Word (immediate) to A (lo-byte) and X (hi-byte)
    .macro	LoadWordAX value
	    lda #<value
	    ldx #>value
    .endmacro

    ; Store the 16-bit Word in AX to address (lo,hi)
    .macro	StoreAX address
	    sta address
	    stx address+1
    .endmacro

    ; Store a 16-bit Word (immediate) to address (lo,hi)
    .macro	StoreImm value, address
	    LoadWordAX value
	    StoreAX address
    .endmacro

    ; Moves 1 byte from source to dest
    .macro MoveB source, dest
	    lda source
	    sta dest
    .endmacro

    ; Moves the 16-bit Word from source (lo,hi) to dest (lo,hi)
    .macro MoveW source, dest
	    MoveB source+0, dest+0
	    MoveB source+1, dest+1
    .endmacro

    .macro PRINT_STRING string
        pha
        lda #<string
        sta STR_PTR
        lda #>string
        sta STR_PTR+1
        jsr print_str
        pla
    .endmacro

; globals
input_string: .res 5
;input_string_null: .byte 0 ; make sure input_string is null-terminated
temp_word: .word 0
input_binary: .word 0

; prompts
prompt:           .asciiz "enter count limit: "
num_error_prompt: .asciiz "must be a number:  "

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
start:
    StoreImm 0, ivar        ; init outerloop variable
    PRINT_STRING prompt
    jsr get_number
    lda input_binary
    sta limit
    lda input_binary+1
    sta limit+1
outerloop:
    inc ivar
    bne @cont1
    inc ivar+1
@cont1:
    ; loop check
    lda ivar+1              ; compare high byte
    cmp limit+1
    bcc continue
    bne outerloopdone
    lda ivar                ; compare low byte
    cmp limit
    bcc continue            ; islower - ivar is lower than limit
    beq continue            ; issame - ivar = limit
    bne outerloopdone       ; ishigher - ivar is higher
continue:
    jsr print_prime
    jmp outerloop
outerloopdone:
    rts

print_prime:
    MoveW ivar, printnum    ; copy ivar to U10 "printnum" to convert and print 
    ldy #0                  ; Pad char '0' #48 or ' ' #32 or #0 for none
    jsr PrDec16
    lda #','
    jsr CHROUT
    lda #SPACE
    jsr CHROUT 
    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Print 16-bit decimal number
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INPUT:    U10 = value to print, copied to scratch U11
;           .Y  = pad character
;           (e.g. '0' #48 or ' ' #32 or #0 for none)
;
; INPUT:    at PrDec16Lp1
;           Y=(number of digits)*2-2, e.g. 8 for 5 digits
;
; OUTPUT:   A,X,Y corrupted
PrDec16:    
	sty pad                 ; Save new padding character
	MoveW U10, U11
	ldy #8                  ; Offset to powers of ten
PrDec16Lp1:
	ldx #$FF                ; Start with digit=-1
	sec
PrDec16Lp2:
	lda U11                 ; Subtract current tens
	sbc PrDec16Tens+0,Y
    sta U11
    lda U11+1
    sbc PrDec16Tens+1,Y
    sta U11+1
    inx                     ; Loop until <0
    bcs PrDec16Lp2
    lda U11                 ; Add current tens back in
    adc PrDec16Tens+0,Y
    sta U11
    lda U11+1
    adc PrDec16Tens+1,Y
    sta U11+1
    txa                     ; Not zero, print it
    bne PrDec16Digit
    lda pad                 ; pad<>0, use it
    bne PrDec16Print
    beq PrDec16Next
PrDec16Digit:
    ldx #48                 ; ASC"0", No more zero padding
    stx pad
    ora #48                 ; ASC"0", Print this digit
PrDec16Print:
    jsr CHROUT
PrDec16Next:
    dey                     ; Loop for next digit
    dey
    bpl PrDec16Lp1
    rts
PrDec16Tens:
    .word 1
    .word 10
    .word 100
    .word 1000
    .word 10000
pad:.res 1			; default 0 = no padding

print_str: ; STR_PTR = address of null-terminated string
    phy
    ldy #0
@loop:
    lda (STR_PTR),y
    beq @done
    jsr CHROUT
    iny
    bra @loop
@done:
    ply
    rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Flush chrin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
flush_chrin:
    jsr CHRIN
    cmp #RETURN
    bne flush_chrin
    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get number input from console
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_number:
    pha
    phx
    phy
    ldx #0
@input_loop:
    jsr CHRIN
    cmp #RETURN
    beq @input_done
    sta input_string,x
    inx
    cpx #5
    bne @input_loop
    jsr flush_chrin
@input_done: ; A = RETURN
    jsr CHROUT
    stz input_string,x ; null termination
    ; check for number
    ldx #0
@check_loop:
    lda input_string,x
    cmp #0
    beq @check_empty
    cmp #CHAR_0
    bmi @error
    cmp #(CHAR_9 + 1)
    bpl @error
    inx
    bra @check_loop
@check_empty:
    cpx #0
    bne @convert
@error:
    PRINT_STRING num_error_prompt
    jmp @input_loop
@convert:
    ldx #0
    stz input_binary
    stz input_binary+1
@conv_loop:
    lda input_string,x
    beq @done
    ; new digit, multiply input_binary by 10
    asl input_binary
    rol input_binary+1
    lda input_binary
    ; multiplied by 2 - save value in temp variable
    sta temp_word
    lda input_binary+1
    sta temp_word+1
    ; continue shifting two more bits to multiply by 8
    asl input_binary
    rol input_binary+1
    asl input_binary
    rol input_binary+1
    ; now add x2 value to x8 value to get x10 value
    lda input_binary
    clc
    adc temp_word
    sta input_binary
    lda input_binary+1
    adc temp_word+1
    sta input_binary+1
    ; now add digit from string
    lda input_string,x
    and #$0F ; zero out upper nybble to get digit numerical value
    clc
    adc input_binary
    sta input_binary
    lda input_binary+1
    adc #0 ; let carry happen, if necessary
    sta input_binary+1
    inx
    bra @conv_loop
@done:
    ply
    plx
    pla
    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Print hex 8 bit numbers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; printhex:           ; prints an 8 bit value in hex - easier to understand logic
;     pha             ; saves A for lowest significant digit
; print_hi:
;     lsr             ; shift right 4 bits
;     lsr
;     lsr
;     lsr
;     jsr hex
; print_lo:
;     pla             ; fetch for lowest significant digit
; hex:
;     and #$0f        ; keep only the lower 4 bits
;     ora #$30        ; i.e. "0" - convert to ASCII - suma $30 (si $3 -> $33)
;     cmp #$3a        ; digit? (ascii code above numbers - es $33 < $3A?)
;     bcc echo        ; yes - if it is a digit just print it
;     adc #6          ; add offset for A if it a letter A to F
; echo:
;     jsr CHROUT      ; print it
; rts

; lookup table to print hex digits
hex_digits: .asciiz "0123456789abcdef"

printhex:           ; prints an 8 bit value in hex - faster with no branching using lookup table
    PushAll 
    pha
    and  #$0f
    tax
    ldy  hex_digits,x
    pla
    lsr  a
    lsr  a
    lsr  a
    lsr  a
    tax
    lda  hex_digits,x
    jsr CHROUT      ; print high nibble
    tya
    jsr CHROUT      ; print low nibble
    PullAll
    rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;16-Bit Binary Division
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;number = U0
;divisor = U1
;remain = U2
;divresult = U3
divide:
    PushAll
	lda #0	        ; preset remainder to 0
	sta remain
	sta remain+1
	ldx #16	       	; repeat for each bit - 16 times
@divloop:	
	asl number		; dividend lb & hb*2, msb -> Carry
	rol number+1	
	rol remain		; remainder lb & hb * 2 + msb from carry
	rol remain+1
	lda remain
	sec
	sbc divisor		; substract divisor to see if it fits in
	tay	        	; lb divresult -> Y, for we may need it later
	lda remain+1
	sbc divisor+1
	bcc @skip		; if carry=0 then divisor didn't fit in yet
	sta remain+1	; else save substraction divresult as new remainder
	sty remain	
	inc divresult		; and increment divresult cause divisor fit in 1 times
@skip:
	dex
	bne @divloop	
    PullAll
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculates 8-bit sqrt of 16-bit integer in num/num+1
;result in root (0-255) and remainder in remain (0-511) in rem/rem+1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; num = U4
; rem = U5
; temp = U6
; root = b1
sqroot:
	PushAll
	lda	#0  		; clear A
	sta	rem		    ; clear remainder low byte
	sta	rem+1    	; clear remainder high byte
	sta	root		; clear Root
	ldx	#8  		; 8 pairs of bits to do
@loop:
	asl	root		; root = root * 2

	asl	num		    ; shift highest bit of number ..
	rol	num+1
	rol	rem		    ; .. into remainder
	rol	rem+1

	asl	num		    ; shift highest bit of number ..
	rol	num+1
	rol	rem		    ; .. into remainder
	rol	rem+1

	lda	root		; copy root ..
	sta	temp		; .. to temp
	lda	#0  		; clear byte
	sta	temp+1		; clear temp high byte

	sec				; +1
	rol	temp		; temp = temp * 2 + 1
	rol	temp+1		

	lda	rem+1    	; get remainder high byte
	cmp	temp+1		; compare with partial high byte
	bcc	@next		; skip sub if remainder high byte smaller

	bne	@subtr		; do sub if <> (must be remainder>partial !)

	lda	rem	    	; get remainder low byte
	cmp	temp		; comapre with partial low byte
	bcc	@next		; skip sub if remainder low byte smaller
				    
                    ; else remainder>=partial so subtract then
				    ; and add 1 to root. carry is always set here
@subtr:
	lda	rem		    ; get remainder low byte
	sbc	temp		; subtract partial low byte
	sta	rem    	    ; save remainder low byte
	lda	rem+1    	; get remainder high byte
	sbc	temp+1		; subtract partial high byte
	sta	rem+1    	; save remainder high byte
	inc	root		; increment Root

@next:
	dex				; decrement bit pair count
	bne	@loop		; loop if not all done
	PullAll
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Print registers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
header: .asciiz " a  x  y sp sr"

print_header:
    ldx #0
@header_loop:
    lda header,x
    beq @header_done
    jsr CHROUT
    inx
    bra @header_loop
@header_done:
    lda #NEWLINE
    jsr CHROUT
    rts

print_regs:
    php
    pha
    phx
    php ; push P again for quick retrieval
    jsr print_hex
    lda #SPACE
    jsr CHROUT
    txa
    jsr print_hex
    lda #SPACE
    jsr CHROUT
    tya
    jsr print_hex
    lda #SPACE
    jsr CHROUT
    tsx
    txa
    clc
    adc #6 ; calculate SP from before JSR
    jsr print_hex
    lda #SPACE
    jsr CHROUT
    pla ; pull earlier P into A
    jsr print_hex
    lda #NEWLINE
    jsr CHROUT
    plx
    pla
    plp
    rts

; like how these subroutines work without lookup tables and easy to understand (yet another version 3 in this file)
print_hex:
    pha	   ; push original A to stack
    lsr
    lsr
    lsr
    lsr      ; A = A >> 4
    jsr print_hex_digit
    pla      ; pull original A back from stack
    and #$0F ; A = A & 0b00001111
    jsr print_hex_digit
    rts

print_hex_digit:
    cmp #$0A
    bpl @letter
    ora #$30    ; PETSCII numbers: 1=$31, 2=$32, etc.
    bra @print
@letter:
    clc
    adc #$37		; PETSCII letters: A=$41, B=$42, etc.
@print:
    jsr CHROUT
    rts