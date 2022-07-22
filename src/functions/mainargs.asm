.struct XMAINARGS_STRUCT
    argv_ptr          .res     KERNEL_MAX_ARGS_COMMAND_LINE
    argv_value_ptr    .res     KERNEL_LENGTH_MAX_CMDLINE+KERNEL_MAX_ARGS_COMMAND_LINE ; add 0 to string
.endstruct

.if     .sizeof(XMAINARGS_STRUCT) > 255
  .error  "XMAINARGS_STRUCT size is greater than 255. It's impossible because code does not handle a struct greater than 255"
.endif

; A : Cut 

.out     .sprintf("|MODIFY:TR0:XMAINARGS_ROUTINE")
.out     .sprintf("|MODIFY:TR1:XMAINARGS_ROUTINE")
.out     .sprintf("|MODIFY:TR4:XMAINARGS_ROUTINE")
.out     .sprintf("|MODIFY:TR3:XMAINARGS_ROUTINE")
.out     .sprintf("|MODIFY:RES:XMAINARGS_ROUTINE")
.out     .sprintf("|MODIFY:REB:XMAINARGS_ROUTINE")
.out     .sprintf("|MODIFY:KERNEL_ERRNO:XMAINARGS_ROUTINE")


; Register Modify : A,X,Y
; Memory modify : RES,RESB,TR0,TR1,TR2,TR3,TR4


XMAINARGSC            := TR0 ; 1 byte
XMAINARGSV            := TR1 ; 2 byte
XMAINARGS_SPACEFOUND  := TR3 ; 1 byte
XMAINARGS_MODE        := TR4 ; 1 byte


.proc XMAINARGS_ROUTINE

    sta     XMAINARGS_MODE
    ldx     kernel_process+kernel_process_struct::kernel_current_process

    lda     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_low,x
    sta     RES

    lda     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_high,x
    sta     RES+1


    lda     RES
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
    sta     (XMAINARGSV),y
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

    ldy     #$00

@loop:
    lda     (RES),y

    beq     @out
    cmp     #' '
    beq     @new_arg
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
    lda     RESB ; $7C9
    ldy     RESB+1


    rts
@new_arg:
    lda     XMAINARGS_SPACEFOUND
    bne     @no_new_arg

    lda     #$01
    sta     XMAINARGS_SPACEFOUND

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

    inc     XMAINARGSC

@no_new_arg:
    iny
    jmp     @loop


.endproc
