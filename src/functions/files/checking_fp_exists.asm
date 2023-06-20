.proc checking_fp_exists
    ; X fp to find
    ; Save A & X

    .out     .sprintf("|MODIFY:RES:checking_fp_exists")
    .out     .sprintf("|MODIFY:RESB:checking_fp_exists")
    .out     .sprintf("|MODIFY:TR5:checking_fp_exists")

    sty     KERNEL_XWRITE_XCLOSE_XFSEEK_XFREAD_SAVE_Y

    txa     ; X contains the fp
    sta     KERNEL_XWRITE_XCLOSE_XFSEEK_XFREAD_SAVE_X ; save fp id
    ; Compute fd index in main fp struct
    sec
    sbc     #KERNEL_FIRST_FD
    cmp     #KERNEL_MAX_FP                                         ; Does X is greater than the fp ?
    bcs     @doesnot_exists                                        ; Yes error

     ; When orix boots, kernel_fd_opened is equal to $FF, if the fd passed into arg is the same than kernel_fd_opened it means that we don't need to close and store
    cmp     kernel_process+kernel_process_struct::kernel_fd_opened
    beq     @do_not_seek


    ldx     kernel_process+kernel_process_struct::kernel_fd_opened
    cpx     #$FF ; First file opened when orix boots ?
    bne     @store_and_seek

    sta     kernel_process+kernel_process_struct::kernel_fd_opened
    jmp     @do_not_seek

@store_and_seek:
    ; store the new fd to open
    sta     kernel_process+kernel_process_struct::kernel_fd_opened
    ; At this step we can store the seek of the file
    ; close current file

    lda     RES
    sta     KERNEL_XFSEEK_SAVE_RESB

    lda     RES+1
    sta     KERNEL_XFSEEK_SAVE_RESB+1

    jsr     _ch376_file_close

    ; seek now
    lda     KERNEL_XWRITE_XCLOSE_XFSEEK_XFREAD_SAVE_X ; Get again FD id

    jsr     compute_fp_struct


    lda     #CH376_SET_FILE_NAME        ;$2F
    sta     CH376_COMMAND

    lda     #'/'
    sta     CH376_DATA

    jsr     @send_0_to_ch376_and_open

    lda     #CH376_SET_FILE_NAME        ;$2F
    sta     CH376_COMMAND

    ldy     #_KERNEL_FILE::f_path+1 ; Skip first '/'
@loop_next_byte:
    ;jmp     @loop_next_byte
    lda     (KERNEL_XOPEN_PTR1),y

    beq     @send_end_out
    cmp     #'/'
    beq     @send
    jsr     XMINMA_ROUTINE
    sta     CH376_DATA
    iny
    bne     @loop_next_byte
    ; Here we should not reach this part except if there is an overflow

@doesnot_exists:

    jsr     restore
    sec
    rts

@do_not_seek:
    jsr     restore
    clc
    rts

@send:
    iny
    sty     TR5

    jsr     @send_0_to_ch376_and_open
    lda     #CH376_SET_FILE_NAME        ;$2F
    sta     CH376_COMMAND

    ldy     TR5
    jmp     @loop_next_byte

@send_end_out:
    jsr     @send_0_to_ch376_and_open

    ldy     #_KERNEL_FILE::f_seek_file

    lda     (KERNEL_XOPEN_PTR1),y
    sta     RES
    iny
    lda     (KERNEL_XOPEN_PTR1),y
    sta     RES+1
    iny
    lda     (KERNEL_XOPEN_PTR1),y
    tax
    iny
    lda     (KERNEL_XOPEN_PTR1),y
    sta     RESB

    lda     RES
    ldy     RES+1

    jsr     _ch376_seek_file32

    lda     KERNEL_XFSEEK_SAVE_RESB
    sta     RES

    lda     KERNEL_XFSEEK_SAVE_RESB+1
    sta     RES+1

    jmp     @do_not_seek

@send_0_to_ch376_and_open:

.IFPC02
.pc02
    stz     CH376_DATA
.p02
.else
    lda     #$00
    sta     CH376_DATA
.endif

    jsr     _ch376_file_open ; Open slash
    rts

restore:
    ldy     KERNEL_XWRITE_XCLOSE_XFSEEK_XFREAD_SAVE_Y
    ldx     KERNEL_XWRITE_XCLOSE_XFSEEK_XFREAD_SAVE_X
    rts

.endproc
