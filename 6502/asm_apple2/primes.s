; primes.s
; compiles with: cl65 -t apple2enh -o prog.bin -C apple2bin.cfg -l primes.list primes.s
; Automated build with build.sh

.org $6000

    jmp start

; Kernel
CLRSCRN         = $FC58
CHROUT          = $FDF0
KEYBD           = $C000
STROBE          = $C010
NEWLINE         = $FC62

; character codes
RETURN          = $8D
CHAR_0          = $B0
CHAR_9          = $B9
SPACE           = $A0

; Zero Page "registers"
; Only 19 bytes available in Apple ][e:
; $06, $07, $08, $09
; $1E, $1F
; $CE, $CF
; $D7
; $EB, $EC, $ED, $EE, $EF
; $FA, $FB, $FC, $FD, $FE
;STR_PTR = $FC       ; address of string to be printed
STR_PTR = $1E
number  = $06       ; division variables
divisor = $08
remain  = $FC
result  = $CE

num     = $EB       ; root variables
rem     = $ED
temp    = $FA
root    = $EF

; Macros 6502 & 65C02S
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
input_string:   .res 8       
temp_word:      .word 0
input_binary:   .word 0
limit:          .word 0
printnum:       .word 0
scratch:        .word 0
count:          .word 0
ivar:           .word 0

; test with normal variables demonstrated that when zeroed out worked fine
; number:         .word 0
; divisor:        .word 0
; remain:         .word 0
; result:         .word 0
; num:            .word 0
; rem:            .word 0
; temp:           .word 0
; root:           .byte 0

; prompts
title:            .asciiz "*** Primes for Apple ][e ***"
prompt:           .asciiz "Search primes limit: "
num_error_prompt: .asciiz "Must be a number: "
count_of_primes:  .asciiz "Number of primes: "

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
start:
    ; zero register variables if not gives wrong result
    stz number
    stz number+1  
    stz divisor 
    stz divisor+1
    stz remain
    stz remain+1  
    stz result  
    stz result+1
    stz num
    stz num+1     
    stz rem
    stz rem+1     
    stz temp
    stz temp+1
    stz root

    ; jsr CLRSCRN
    PRINT_STRING title
    jsr NEWLINE
    PRINT_STRING prompt
    jsr get_number
    MoveW input_binary, limit
    StoreImm 1, ivar        ; init outerloop variable
    
    StoreImm 1, count       ; 2 is a prime
    ; StoreImm 2, printnum    ; print it
    ; ldy #0                  ; Pad char '0' #48 or ' ' #32 or #0 for none
    ; jsr PrDec16
    ; lda #','
    ; jsr print_char
    ; lda #SPACE
    ; jsr CHROUT 

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
    jsr NEWLINE
    MoveW count, printnum
    PRINT_STRING count_of_primes
    ldy #0                  ; no padding
    jsr PrDec16
    jsr NEWLINE
    lda #0                  ; return to basic
    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Adjust for ASCII to Apple character map
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_char:
    pha
    clc
    adc #128                ; ASCII to apple character map
    jsr CHROUT
    pla
    rts    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Print string
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_str:                  ; STR_PTR = address of null-terminated string
    phy
    ldy #0
@loop:
    lda (STR_PTR),y
    beq @done
    jsr print_char
    iny
    bra @loop
@done:
    ply
    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get input from keyboard - custom routine for Apple ][e
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHRIN:                      
    lda KEYBD
    BPL CHRIN               ; if no key pressed, loop back 
    sta STROBE              ; clear bit #7 of the keyboard
    jsr CHROUT              ; print char pressed
    rts

print_prime:
    MoveW ivar, printnum    ; copy ivar to printnum to convert and print 
    ldy #0                  ; Pad char '0' #48 or ' ' #32 or #0 for none
    jsr PrDec16
    lda #','
    jsr print_char
    lda #SPACE
    jsr CHROUT 
    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Print 16-bit decimal number
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INPUT:    printnum = value to print, copied to scratch
;           .Y  = pad character
;           (e.g. '0' #48 or ' ' #32 or #0 for none)
;
; INPUT:    at PrDec16Lp1
;           Y=(number of digits)*2-2, e.g. 8 for 5 digits
;
; OUTPUT:   A,X,Y corrupted
PrDec16:    
	sty pad                 ; Save new padding character
	MoveW printnum, scratch
	ldy #8                  ; Offset to powers of ten
PrDec16Lp1:
	ldx #$FF                ; Start with digit=-1
	sec
PrDec16Lp2:
	lda scratch             ; Subtract current tens
	sbc PrDec16Tens+0,Y
    sta scratch
    lda scratch+1
    sbc PrDec16Tens+1,Y
    sta scratch+1
    inx                     ; Loop until <0
    bcs PrDec16Lp2
    lda scratch             ; Add current tens back in
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
    ;jsr CHROUT             ; need to adjust for Apple2 character map
    jsr print_char
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
    cpx #8
    bne @input_loop
    ;jsr flush_chrin            ; no need to flush as STROBE does that
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
    jsr divideby8bit        ; divide by 8bit - much faster
	lda remain              ; if remainder is zero it is not a prime
	beq @exit	            ; branch if equal to 0 

    ldx divisor             ; are we done yet?
    cpx root
    bne @loopcheck 
@exit:
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;16-Bit Binary Division
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculates 8-bit sqrt of 16-bit integer in num/num+1
;result in root (0-255) and remainder in remain (0-511) in rem/rem+1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
