

.if     .sizeof(XMAINARGS_STRUCT) > 255
  .error  "XMAINARGS_STRUCT size is greater than 255. It's impossible because code does not handle a struct greater than 255"
.endif

; A : Cut

.out     .sprintf("|MODIFY:TR0:XMAINARGS_ROUTINE")
.out     .sprintf("|MODIFY:TR1:XMAINARGS_ROUTINE")
.out     .sprintf("|MODIFY:TR2:XMAINARGS_ROUTINE") ; Because TR1 is used with 16 bits long
.out     .sprintf("|MODIFY:TR3:XMAINARGS_ROUTINE")
.out     .sprintf("|MODIFY:TR4:XMAINARGS_ROUTINE")
.out     .sprintf("|MODIFY:RES:XMAINARGS_ROUTINE")
.out     .sprintf("|MODIFY:REB:XMAINARGS_ROUTINE")
.out     .sprintf("|MODIFY:KERNEL_ERRNO:XMAINARGS_ROUTINE")


; Register Modify : A,X,Y
; Memory modify : RES,RESB,TR0,TR1,TR2,TR3,TR4

XMAINARGSC             := TR0 ; 1 byte
XMAINARGSV             := TR1 ; 2 bytes
XMAINARGS_SPACEFOUND   := TR3 ; 1 byte
XMAINARGS_MODE         := TR4 ; 1 byte
XMAINARGS_DOUBLE_QUOTE := TR5 ; 1 byte


.proc XMAINARGS_ROUTINE

    ;;@brief Build a mainargs array and returns in A and Y the ptr (malloc)
    ;;@inputA Mode (0 or 1)
    ;;@inputX High ptr curl struct
    ;;@modifyMEM_RES
    ;;@modifyMEM_RESB
    ;;@modifyMEM_TR0
    ;;@modifyMEM_TR1
    ;;@modifyMEM_TR2
    ;;@modifyMEM_TR3
    ;;@modifyMEM_TR4
    ;;@modifyMEM_KERNEL_ERRNO

    sta     XMAINARGS_MODE

    ; Get current process
    ldx     kernel_process+kernel_process_struct::kernel_current_process
    ; Get the struct og the process
    jsr     kernel_get_struct_process_ptr
    sta     RES
    sty     RES+1

    ; Compute cmdline offset
    lda     RES ; FIXME A is already populated
    clc
    adc     #kernel_one_process_struct::cmdline ; 1 : number of args
    bcc     @S7
    inc     RES+1

@S7:
    sta     RES

    lda     #KERNEL_XMAINARG_MALLOC_TYPE
    sta     KERNEL_MALLOC_TYPE
    lda     #<.sizeof(XMAINARGS_STRUCT)
    ldy     #>.sizeof(XMAINARGS_STRUCT)

    jsr     XMALLOC_ROUTINE
    cmp     #$00
    bne     @continue
    cpy     #$00
    bne     @continue

    lda     #ENOMEM
    sta     KERNEL_ERRNO
    ldx     #$00 ; Return argc=0

    ; oom

    rts

@continue:
    ; Save malloc
    sta     RESB
    sty     RESB+1

    lda     XMAINARGS_MODE
    beq     @parse

    ; Mode 1 : Copy only

    ldy     #$00

@loop2:
    lda     (RES),y
    beq     @out2
    sta     (RESB),y
    iny
    bne     @loop2

@out2:
    sta     (RESB),y

    lda     RESB
    ldy     RESB+1

    rts

@parse:

    ; Compute offsets
    ; Get first offset
    ldy     #XMAINARGS_STRUCT::argv_ptr
    lda     #XMAINARGS_STRUCT::argv_value_ptr
    sta     (RESB),y

    lda     RESB+1
    sta     XMAINARGSV+1

    lda     #XMAINARGS_STRUCT::argv_value_ptr
    clc
    adc     RESB
    bcc     @S3
    inc     XMAINARGSV+1

@S3:
    sta     XMAINARGSV ; TR2 contains the first offset

    lda     #$00
    sta     XMAINARGS_SPACEFOUND

    lda     #$01       ; 1 because there is at least the binary
    sta     XMAINARGSC ; TR0 contains number of args

    lda     #$00
    sta     XMAINARGS_DOUBLE_QUOTE

    ldy     #$00

@loop:
    lda     (RES),y

    beq     @out
    cmp     #' '
    beq     @new_arg
    cmp     #'"' ; Is it '"' ?
    bne     @not_double_quote

    lda     XMAINARGS_DOUBLE_QUOTE ; If equal two 0, it " is found here, let's
    beq     @begin_double_quote

    ; End of double quote found, close param
    bne     @out

@begin_double_quote:
    inc     XMAINARGS_DOUBLE_QUOTE

    lda     RES
    clc
    adc     #$01
    bcc     @no_inc
    inc     RES+1

@no_inc:
    sta     RES
    jsr     @init_param
    jmp     @loop

@not_double_quote:
    ; store the string
    sta     (XMAINARGSV),y

    lda     #$00
    sta     XMAINARGS_SPACEFOUND

    iny
    bne     @loop

@out:
    lda     #$00
    sta     (XMAINARGSV),y

    ldx     XMAINARGSC
    ; return ptr
    lda     RESB
    ldy     RESB+1
    rts

@new_arg:
    ldx     XMAINARGS_DOUBLE_QUOTE
    beq     @double_quote_not_opened

    ; At this step we found a space in a " sentence
    ; A contains " "
    sta     (XMAINARGSV),y
    jmp     @no_new_arg

@double_quote_not_opened:
    lda     XMAINARGS_SPACEFOUND
    bne     @no_new_arg

    lda     #$01
    sta     XMAINARGS_SPACEFOUND

    jsr     @init_param
    inc     XMAINARGSC

@no_new_arg:
    iny
    jmp     @loop

@init_param:
    lda     #$00
    sta     (XMAINARGSV),y

    tya
    tax
    sec     ; add 1 in order to be after \0
    adc     #XMAINARGS_STRUCT::argv_value_ptr

    ldy     XMAINARGSC
    sta     (RESB),y

    txa
    tay

    rts
.endproc
