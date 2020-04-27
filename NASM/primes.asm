; ----------------------------------------------------------------------------------------
; Seeks prime numbers until number defined in first argument ie: ./primes 100
; macOS NASM
; Compile instructions:
; nasm -fmacho64 primes.asm && gcc timebase.c -o primes primes.o
; ----------------------------------------------------------------------------------------

    global      _main
    extern      _atoi
    extern      _printf
    extern      _mach_absolute_time
    extern      _timebase
    extern      _puts
    default     rel

section .text

; function to find the number of primes from 1 to NUM
; parameters: edi = num, rsi = cache, rdx = count
subCheckPrimes:
    push        rbp	                ; save base pointer, aligns the stack for OS X

    mov         edi, [num]          ; upper limit number to test to edi
    mov         rsi, cache          ; cache address
    mov         rdx, count          ; count address

    mov         r11d, edi           ; r11d <- edi num
    mov         rdx, rsi            ; rdx <- rsi cache (1st time is at the base = zero)
    mov         r10, 4*cacheSize    ; r10 <- 4 * 1000 = 4000 as cache size = end
    add         r10, rdx            ; r10 <- adds count (1st time is zero)
    
    mov         edi, 1              ; edi <- 1 i (number being tested)

    mov         r9d, 1              ; r9d <- 1 adds 1 to count as we add number 2 below
    mov         [rdx], DWORD 2      ; adds number 2 as first prime in the cache
    add         rdx, 4              ; moves the cache address 4 bytes given add above (32bit)
    
    ; edi = i, r9d = count, r11d = num, rdx = pos, r10 = end

outerloop:
    add         edi, 2              ; increment the number being tested - 1st time edi 3
    
    cmp         edi, r11d           ; finished once that number exceeds num: i vs num
    jge         subCheckPrimesEnd
    
    call        subIsPrime          ; check if number is prime - per the 64-bit ABI, 
                                    ;arguments are passed in registers
    
    cmp         eax, 1              ; not equal: i is not prime - back to outerloop
    jne         outerloop           ; number was not prime, jump to the top to test the next number
    
    ; i is prime                                
    inc         r9d                 ; increment prime number count
    
    cmp         rdx, r10            ; compares position of cache vs cache end
    jge         outerloop           ; if there's no space remaining in the cache, return to top
    
    mov         [rdx], edi          ; add i to the cache
    add         rdx, 4              ; move cache pointer forward for next number

    jmp         outerloop

subCheckPrimesEnd:
    mov         [count], r9d        ; copies final number count to [count] 
    pop         rbp	                ; restore base pointer, cleans up stack for OS X - redundant?
    ret

; function to check if given number is prime
; edi = i number to be tested , rsi = cache, rdx = cache pos
subIsPrime:
    mov         r12, rdx            ; r12 <- rdx (cache pos)
    push        rdx                 ; save parameter register
    
    ;calc sqrt of number to test - divisor limit
    cvtsi2ss    xmm0, edi           ; convert int to single float
    sqrtss      xmm0, xmm0          ; calc sqrt single float
    cvttss2si   r15d, xmm0          ; convert result to int and store it in r15d

    mov         r14d, 1             ; divisor initialized to 1 
    ; r12 = end, r13 = cache, r14d = divisor, r15d = divisor max (sqrt of num)

    ; Uncomment to enable search through cache first - Disabled here
    ; first test all numbers in cache for potential divisors of n
;topcacheloop:

    ;cmp r13, r12        ; if done with cache, skip to main test loop
    ;jge innerloop
    
    ;mov r14d, [r13]     ; get current value from cache
    ;cmp r14d, r15d      ; if value from cache exceeds max, done testing, number is prime
    ;jg isAPrime
    
    ;mov eax, edi
    ;mov edx, 0
    ;div r14d            ; divide current value by cached value
    
    ;cmp edx, 0
    ;je isNotAPrime      ; if remainder is zero, current value is not a prime
    
    ;add r13, 4          ; move forward in the cache
    ;jmp topcacheloop
    
innerloop:
    add         r14d, 2             ; set divisor - first time = 3
    cmp         r14d, r15d          ; if divisor > sqrt, done testing, number is prime
    jg          isAPrime
    
    mov         eax, edi            ; number to be tested to eax
    mov         edx, 0              ; edx saves integer division reminder - here initialized to 0
    div         r14d                ; divides eax (i) by r14d (divisor)
    cmp         edx, 0              ; compares reminder with 0
    je          isNotAPrime         ; if reminder is zero tested number is not a prime
    
    jmp         innerloop           ; continue loop testing next divisor

isAPrime:
    mov         eax, 1              ; returns "true"
    jmp         subIsPrimeEnd       ; end the innerloop
isNotAPrime:
    mov         eax, 0              ; returns "false" & fallsthrough to end innerloop
subIsPrimeEnd:
    pop         rdx	                ; restore parameter register - redundant?
    ret

subPrintPrimes:
    mov         r13, cache          ; get first postition of cache (its base)
printLoop:
    cmp         r13, r12            ; cache at the end if pointer greater or equal
    jge         subPrintloopEnd

    mov         r14, [r13]          ; get current value from cache   
    ; print it
    push        rdi                 ; save register before call to printf
    push        rsi
    lea         rdi, [primesStr]    ; 1st arg to printf
    mov         rsi, r14            ; numbert to print
    call        _printf
    pop         rsi                 ; restore registers after printf call
    pop         rdi

    add         r13, 4              ; move forward next pos in the cache - 4 = 32bits
    jmp         printLoop
subPrintloopEnd:
    ; print newline and go quit program
    lea         rdi, [newline]      ; First argument is address of message
    call        _puts                         
    jmp         done                ; go quit

_main:  
    push        rbx                 ; we don't ever use this, but it is necesary
                                    ; to align the stack so we can call stuff from C
    dec         rdi                 ; argc-1, since we don't count program name
    jz          noArguments         ; if no arguments signal error and then exit

    ; convert arg from string to int using atoi and then save in rdi
    push        rdi                 ; save register across call to atoi
    push        rsi
    mov         rdi, [rsi+rdi*8]    ; argv[rdi]
    call        _atoi               ; now rax has the int value of arg
    pop         rsi                 ; restore registers after atoi call
    pop         rdi
    mov         [num], rax          ; saving number to num

    ; calculate SQRT on number passed to validate input and exit on error if needed
    cvtdq2pd    xmm0, [num]         ; convert int to double float and store in xmm0
    sqrtsd      xmm0, xmm0          ; calc sqrt
    cvttsd2si   rax, xmm0           ; convert result to int
    test        rax, rax            ; test if rax=0
    jz          nonNumber           ; if zero means what was passed to atoi could not be converted to a number
    js          negativeNumber      ; if signed means what was passed was negative

    ; call time here to get start time
    call        _mach_absolute_time ; get the absolute time hardware dependant
    mov         [start], rax        ; save start time in start
    
    call        subCheckPrimes      ; main program stuff

    ;call time to get end time and calc elapsed time
    call        _mach_absolute_time
    mov         [end], rax

    ; calc elapsed
    mov         r10d, [end]         
    mov         r11d, [start]
    sub         r10d, r11d          ; r10d = end - start
    mov         [diff], r10d        ; copy to diff
    ; get conversion ratio from C function to get nanoseconds from mach_absolute_time (HW dependent)
    call        _timebase           ; get conversion ratio to nanoseconds into xmm0    
    cvtsi2sd    xmm1, [diff]        ; load diff from mach_absolute time in xmm1
    ; calc nanoseconds - xmm0 ends with nanoseconds
    mulsd       xmm0, xmm1          ; ratio * diff -> xmm0
    cvtsd2si    rax, xmm0           ; convert float to int in rax
    mov         [result], rax       ; save to result

    ; print count
    lea         rdi, [printStr]
    movsxd      rsi, r9d            ; move 32 bit reg to 64 bit reg
    call        _printf

    ; print elapsed time in nanoseconds
    lea         rdi, [timedifstr]   
    mov         rsi, [result]
    call        _printf  
    ; print elapsed time in miliseconds
    ; calc miliseconds
    mov         rdx,0               ; avoid error (reminder)
    mov         rax, [result]       ; number of nanoseconds
    mov         rcx, [divisor]     ; 1_000_000 to get miliseconds
    ;mov         edx, 0             ; edx saves integer division reminder - here initialized to 0
    div         rcx
    mov         [result_mili], rax  ; save miliseconds to [result_mili]
    ; print it
    lea         rdi, [timedifmil]
    mov         rsi, [result_mili]
    call        _printf
    
    ; print cache - check if we want to print the primes
    ; print prompt
    lea         rdi, [prompt]      
    call        _puts
    ; get input
    mov         rax, 0x02000003     ; system call for read
    mov         rdi, 0              ; stdin
    mov         rsi, character
    mov         rdx, 1              ; read just 1 byte?
    syscall
    ; comparison to 'y'
    xor         rax, rax            ; clear whole rax register
    mov         al, 'y' 
    cmp         [character], al     ; don't compare more bytes than used for the vars  
    je          subPrintPrimes      ; go print primes if answer was 'y'
    jmp         done                ; if not go quit - we are done

negativeNumber:                     ; error message
    lea         rdi, [error3]
    xor         rax, rax            ; clear the register
    call        _printf
    jmp         done

nonNumber:                          ; error message
    lea         rdi, [error2]
    xor         rax, rax            ; clear the register
    call        _printf
    jmp         done

noArguments:                        ; error message
    lea         rdi, [error1]
    xor         rax, rax            ; clear the register
    call        _printf
    
done:
    pop         rbx                 ; undoes the push at the beginning for C calls stack alignment
    ret

section .data
    num         dq  0
    error1      db  "There are no command line arguments to calculate primes", 10, 0
    error2      db  "Please input a number as argument", 10, 0
    error3      db  "Please input a positive number as argument", 10, 0

    cacheSize   equ 1000                                ; size of the prime number cache
    cache	    TIMES cacheSize dd 0		            ; 1000 sized cache initialized to zero
    count	    dq	0                                   ; count of primes
    printStr	db	"Number of primes found: %ld",10, 0	; output string for printf count
    primesStr   db  "%d ", 0                            ; output string printing primes
    newline     db 10, 0                                ; newline

    prompt      db "Print primes (up to first 1000)? (y/n) ", 0
    character   db 1

    timedifstr  db "Took: %ld nanoseconds", 10, 0
    timedifmil  db "Took: %ld miliseconds", 10, 0
    divisor     dq 1000000                              ; 1_000_000 divisor to convert nano to milisecs

    ; should use registers but for clarity
    start:      dq 0
    end:        dq 0
    diff:       dq 0
    result:     dq 0
    result_mili dq 0
