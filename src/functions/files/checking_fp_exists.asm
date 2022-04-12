

; 

.proc checking_fp_exists
    ; X fp to find
    ;clc
    ;rts
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
    lda     kernel_process+kernel_process_struct::kernel_fd,x
    beq     @doesnot_exists
    clc
    rts

    cpx     kernel_process+kernel_process_struct::kernel_fd_opened ; is equal to 0 ? No opened files yet ...
    beq     @do_not_seek

    ; store the new fd to open
    stx     kernel_process+kernel_process_struct::kernel_fd_opened 
    ; At this step we can store the seek of the file
    ; close current file
    jsr     _ch376_file_close
    
    ; seek now



    ; Compute the ptr of the fp and store it in KERNEL_XOPEN_PTR1
    lda     kernel_process+kernel_process_struct::fp_ptr,x
    sta     KERNEL_XOPEN_PTR1
    inx
    lda     kernel_process+kernel_process_struct::fp_ptr,x
    sta     KERNEL_XOPEN_PTR1+1


    lda     #'/'
    sta     CH376_DATA

    jsr     send_0_to_ch376_and_open

    ldy     #_KERNEL_FILE::f_path+1 ; Skip first '/'
@loop_next_byte:    
    lda     (KERNEL_XOPEN_PTR1),y
    beq     @send_end_out
    cmp     #'/'
    beq     @send
    sta     CH376_DATA
    iny
    bne     @loop_next_byte
    ; Here we should not reach this part except if there is an overflow
    jsr     restore
    sec
    rts

@send:
    jsr     send_0_to_ch376_and_open
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



 
 @do_not_seek:
    


    jsr     restore

    clc
    rts
@doesnot_exists:    
    ;lda     #$11
    ;sta     $bb80
    jsr     restore
    sec
    rts
send_0_to_ch376_and_open:
    lda     #$00 
    sta     CH376_DATA 

    jmp     _ch376_file_open ; Open slash

restore:
    ldy     KERNEL_XWRITE_XCLOSE_XFSEEK_XFREAD_SAVE_Y

    ldx     KERNEL_XWRITE_XCLOSE_XFSEEK_XFREAD_SAVE_X
    rts

.endproc

.proc _ch376_seek_file32
    ; A Y X RES : 32 bits
    pha
    lda     #CH376_BYTE_LOCATE
    sta     CH376_COMMAND
    pla
    sta     CH376_DATA
    sty     CH376_DATA
    stx     CH376_DATA
    
    lda     RESB
    sta     CH376_DATA

    jmp     _ch376_wait_response

.endproc
