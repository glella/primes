; primes3.s
; compiles with: cl65 -t cx16 -o PRIMES.PRG -l primes.list primes3.s
; executes with: x16emu -debug / without -rtc option clock does not work
; clock function does not work well

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
RDTIM           = $FF50

; PETSCII
RETURN          = $0D
CHAR_0          = $30
CHAR_9          = $39
NEWLINE         = $0D
SPACE           = $20

r0	= $02
r0L	= $02
r0H	= $03
r1	= $04
r1L	= $04
r1H	= $05
r2	= $06
r2L	= $06
r2H	= $07
r3	= $08
r3L	= $08
r3H	= $09
r4	= $0a
r4L	= $0a
r4H	= $0b
r5	= $0c
r5L	= $0c
r5H	= $0d
r6	= $0e
r6L	= $0e
r6H	= $0f
r7	= $10
r7L	= $10
r7H	= $11
r8	= $12
r8L	= $12
r8H	= $13
r9	= $14
r9L	= $14
r9H	= $15
r10	= $16
r10L	= $16
r10H	= $17
r11	= $18
r11L	= $18
r11H	= $19
r12	= $1a
r12L	= $1a
r12H	= $1b
r13	= $1c
r13L	= $1c
r13H	= $1d
r14	= $1e
r14L	= $1e
r14H	= $1f
r15	= $20
r15L	= $20
r15H	= $21


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
result = U3

num = U4            ; root variables
rem = U5
temp = U6
root = b1

count = U7          ; main variables
limit = U8
ivar = U9
printnum = U10      ; input to PRDecimal subroutine
scratch = U11       ; Used by PrDecimal subroutine
; t1_time = U12       ; time vars
; t2_time = U13   
; elapsed = U14

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

    ; .macro GET_TIME address
    ;     jsr RDTIM
    ;     ;lda r2L
    ;     lda $5              ; minutes
    ;     sta address
    ;     jsr print_hex
    ;     ;lda r2H
    ;     lda $6              ; seconds
    ;     sta address+1
    ;     jsr print_hex
    ; .endmacro

; globals
;input_string: .res 5
input_string: .res 8        ; need a longer string to get 16bit numbers
temp_word: .word 0
input_binary: .word 0

; prompts
prompt:           .asciiz "search primes limit: "
num_error_prompt: .asciiz "must be a number: "
count_of_primes:  .asciiz "number of primes: "
time_it_took:     .asciiz "took (mins secs): "

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
start:
    PRINT_STRING prompt
    jsr get_number
    MoveW input_binary, limit
    StoreImm 1, ivar        ; init outerloop variable
    
    StoreImm 1, count       ; 2 is a prime
    ; StoreImm 2, printnum    ; print it
    ; ldy #0                  ; Pad char '0' #48 or ' ' #32 or #0 for none
    ; jsr PrDec16
    ; lda #','
    ; jsr CHROUT
    ; lda #SPACE
    ; jsr CHROUT 
    
    ; GET_TIME t1_time        ; start measuring time

outerloop:
    inc ivar                ; increment ivar by 2 
    bne @cont1
    inc ivar+1
@cont1:
    inc ivar
    bne @cont2
    inc ivar+1
@cont2:
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
    jsr checkPrime          ; check if ivar is prime
    lda remain
    beq outerloop      
@processPrime:
    inc count
    bne @done_inc
    inc count+1 
@done_inc:
    ; jsr print_prime       ; don't print the number just count them
    jmp outerloop
outerloopdone:
    ; GET_TIME t2_time        ; stop measuting time
    lda #NEWLINE
    jsr CHROUT
    MoveW count, printnum
    PRINT_STRING count_of_primes
    ldy #0                  ; no padding
    jsr PrDec16
    lda #NEWLINE
    jsr CHROUT
    ; jsr print_elapsed       ; calc and print elapsed timecl
    rts

; print_elapsed:
;     PRINT_STRING time_it_took
;     lda #0
;     sta printnum+1
;     sec
;     lda t2_time
;     sbc t1_time
;     sta printnum
;     ldy #0
;     jsr PrDec16
;     lda #SPACE
;     jsr CHROUT
;     sec
;     lda t2_time+1
;     sbc t1_time+1
;     sta printnum
;     ldy #0
;     jsr PrDec16
;     lda #NEWLINE
;     jsr CHROUT
;     rts

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
; INPUT:    U10 = value to print, copied to scratch scratch
;           .Y  = pad character
;           (e.g. '0' #48 or ' ' #32 or #0 for none)
;
; INPUT:    at PrDec16Lp1
;           Y=(number of digits)*2-2, e.g. 8 for 5 digits
;
; OUTPUT:   A,X,Y corrupted
PrDec16:    
	sty pad                 ; Save new padding character
	MoveW U10, scratch
	ldy #8                  ; Offset to powers of ten
PrDec16Lp1:
	ldx #$FF                ; Start with digit=-1
	sec
PrDec16Lp2:
	lda scratch                 ; Subtract current tens
	sbc PrDec16Tens+0,Y
    sta scratch
    lda scratch+1
    sbc PrDec16Tens+1,Y
    sta scratch+1
    inx                     ; Loop until <0
    bcs PrDec16Lp2
    lda scratch                 ; Add current tens back in
    adc PrDec16Tens+0,Y
    sta scratch
    lda scratch+1
    adc PrDec16Tens+1,Y
    sta scratch+1
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
pad:.res 1		

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
    ;cpx #5
    cpx #8
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
;Check is a given number is prime
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; trial division
checkPrime:
	lda #1                  ; set divisor to 1
	sta divisor	
    MoveW ivar, num         ; load num (root) with ivar
    jsr sqroot              ; calc sqroot of num
    inc root                ; add 1 to root for loop limit = int(sqrt(i))+1
@loopcheck:
	inc divisor
    MoveW ivar, number      ; reset number to be divided
    ;jsr divide              ; trial division 
    jsr divideby8bit        ; divide by 8 bit - much faster
	lda remain              ; if remainder is zero it is not a prime
	beq @exit	            ; branch if equal to 0 

    ldx divisor             ; are we done yet?
    cpx root
    bne @loopcheck 
@exit:
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
;16-Bit by 16-Bit Binary Division
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;number = U0
;divisor = U1
;remain = U2
;result = U3
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
	tay	        	; lb result -> Y, for we may need it later
	lda remain+1
	sbc divisor+1
	bcc @skip		; if carry=0 then divisor didn't fit in yet
	sta remain+1	; else save substraction result as new remainder
	sty remain	
	inc result		; and increment result cause divisor fit in 1 times
@skip:
	dex
	bne @divloop	
    PullAll
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;16-Bit by 8-Bit Binary Division
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
divideby8bit:
    ; PushAll
    lda #0
    sta remain+1
    ldy #16
@L0:    
    asl number
    rol number+1
    rol a
    bcs @L1
    cmp divisor
    bcc @L2
@L1:    
    sbc divisor
    inc number
@L2:    
    dey
    bne @L0
    sta remain
    ; PullAll
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

; like how these subroutined work without lookup tables and easy to understand
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