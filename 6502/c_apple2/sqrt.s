;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculates 8-bit sqrt of 16-bit integer in num/num+1
;result in root (0-255) and remainder in remain (0-511) in rem/rem+1
;fastcall: LSB of passed num in A and MSB in X
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; only need popa or popax if other args
; .import popa
; .import popax
.export _sqrt

num:            .res 2
rem:            .res 2
temp:           .res 2
root:           .res 1

_sqrt:
	sta num 		; store low byte param
	stx num+1		; store high byte of param
  	; jsr popa 		; popa clobbers .Y but leaves .X alone
	; jsr popax		; pop A and X
  	; the stack has now been cleared of the passed-in parameters.

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
	ldx #0 			; clear the upper 8 bits of the return value, as we are returning A LSB and X MSB (and root is 1 byte)
	lda root		; rutrn root in A
	rts