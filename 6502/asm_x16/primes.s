; primes.s
; compiles with: cl65 -t cx16 -o PRIMES.PRG -l primes.list primes.s
; executes with: x16emu -debug 

.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

    jmp start

; Kernal
CHROUT = $FFD2
; PETSCII
NEWLINE = $0D
SPACE = $20

; Zero Page "registers" 16 bit
user_zp = $30       
U0 = user_zp        
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

isPrime = b2        ; main variables
count = U7
limit = U8
ivar = U9
nvar = divisor      ; reuse same register as it does not change during division & avoids assignments

;Macros 6502 & 65C02S
;    .macro PushAll
;       pha
;       txa
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


; lookup table to print hex digits
hex_digits: .asciiz "0123456789abcdef"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
start:
    StoreImm 100, limit      ; test limit
    StoreImm 1, count       ; 2 is a prime
    StoreImm 1, ivar        ; init outerloop variable
    ; later save number 2 to results array
    ; later - output instructions
    ; later - user input to set aearch limit
    ; later - start measuring time
    lda #2
    jsr print_prime

    lda #0
    sta nvar+1
    ;jsr print_header
outerloop:
    ; increment ivar by 2
    ldx #0          
@do_inc:
    inx
    inc ivar
    bne @check
    inc ivar+1
@check:
    cpx #2
    bne @do_inc 

    ; cmp limit or outerloopdone
    lda ivar+1      ; compare high byte
    cmp limit+1
    bcc continue
    bne outerloopdone
    lda ivar        ; compare low byte
    cmp limit
    bcs outerloopdone
continue:
    jsr checkPrime  ; check if ivar is prime
    lda isPrime
    ;cmp #1
    ;beq @processPrime
    ;jmp outerloop
    beq outerloop
@processPrime:
    inc count
    bne @done_inc
    inc count+1 
@done_inc:
    ; later - save prime
    lda ivar
    jsr print_prime

    jmp outerloop
outerloopdone:
    ; later - stop measuting time
    ; later - calc elapsed time
    ; later - print time it took
    lda NEWLINE
    jsr CHROUT
    lda count+1
    jsr printhex
    lda count
    jsr printhex
    
    rts

print_prime:
    jsr printhex
    lda #','
    jsr CHROUT
    lda #' '
    jsr CHROUT 
    rts

checkPrime:
    PushAll
	lda #1              ; set nvar / divisor / isPrime to 1
	sta isPrime				
	sta nvar		
    lda ivar            ; load num & number with ivar
    sta num
    sta number
    lda ivar+1
    sta num+1
    sta number+1
    jsr sqroot          ; calc sqroot of num
    inc root            ; add 1 to root for loop limit
@loopcheck:
	inc nvar		    ; start at 3 - inc by 2 
	inc nvar
	lda nvar
	cmp root		    ; test divide until sqrt of number
	bcs @finishedcheck	; branch if carry set Acc >= value (nvar >= sq)
    jsr divide          ; trial division 
	lda remain
	;cmp #0			    ; if remainder zero it is not a prime
	beq @notaprime	    ; branch if equal (zero flag 1 after compare)
	jmp @loopcheck
@notaprime:
    lda #0				; is Prime = false
	sta isPrime
@finishedcheck:
    PullAll
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

header: .asciiz " a  x  y sp sr"
vars: .asciiz "ivar ro  n  re pri"

print_header:
    ldx #0
@header_loop:
    ;lda header,x
    lda vars,x
    beq @header_done
    jsr CHROUT
    inx
    bra @header_loop
@header_done:
    lda #NEWLINE
    jsr CHROUT
    rts

print_vars:
    lda ivar+1
    jsr printhex
    lda ivar
    jsr printhex
    lda #SPACE
    jsr CHROUT
    lda root
    jsr printhex
    lda #SPACE
    jsr CHROUT
    lda #SPACE
    jsr CHROUT
    lda nvar
    jsr print_hex
    lda #SPACE
    jsr CHROUT
    lda remain
    jsr print_hex
    lda #SPACE
    jsr CHROUT
    lda isPrime
    jsr printhex
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