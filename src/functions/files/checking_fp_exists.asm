

; 

.proc checking_fp_exists
    ; X fp to find
    ; Save A & X



    tya
    sta     KERNEL_XWRITE_XCLOSE_XFSEEK_XFREAD_SAVE_Y

    txa
    sta     KERNEL_XWRITE_XCLOSE_XFSEEK_XFREAD_SAVE_X ; save fp id
    ; Compute fd index in main fp struct
    sec
    sbc     #KERNEL_FIRST_FD
    cmp     #KERNEL_MAX_FP                                         ; Does X is greater than the fp ?
    bcs     @doesnot_exists                                        ; Yes error
    
    tax

    cpx     kernel_process+kernel_process_struct::kernel_fd_opened ; is equal to 0 ? No opened files yet ...
    beq     @do_not_seek

    ; store the new fd to open
    stx     kernel_process+kernel_process_struct::kernel_fd_opened 
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

    jsr     send_0_to_ch376_and_open

    lda     #CH376_SET_FILE_NAME        ;$2F
    sta     CH376_COMMAND



    ldy     #_KERNEL_FILE::f_path+1 ; Skip first '/'
@loop_next_byte:    

    lda     (KERNEL_XOPEN_PTR1),y

    beq     @send_end_out
    cmp     #'/'
    beq     @send
    jsr     XMINMA_ROUTINE
    sta     CH376_DATA
    iny
    bne     @loop_next_byte
    ; Here we should not reach this part except if there is an overflow
    jsr     restore
    sec
    rts
@doesnot_exists:    

    jsr     restore
    sec
    rts    

@do_not_seek:

    jsr     restore

    clc
    rts    

@send:
    sty     TR5
    jsr     send_0_to_ch376_and_open
    lda     #CH376_SET_FILE_NAME        ;$2F
    sta     CH376_COMMAND

    ldy     TR5
    jmp     @loop_next_byte


@send_end_out:

    jsr     send_0_to_ch376_and_open

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

send_0_to_ch376_and_open:
    lda     #$00 
    sta     CH376_DATA 

    jmp     _ch376_file_open ; Open slash

restore:
    
    ldy     KERNEL_XWRITE_XCLOSE_XFSEEK_XFREAD_SAVE_Y

    ldx     KERNEL_XWRITE_XCLOSE_XFSEEK_XFREAD_SAVE_X
    rts

.endproc

