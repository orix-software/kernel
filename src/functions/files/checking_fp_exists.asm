; X fp to find

.proc checking_fp_exists
    rts
    txa
    sec
    sbc     #KERNEL_FIRST_FD
    cmp     #KERNEL_MAX_FP                                         ; Does X is greater than the fp ?
    bcs     @doesnot_exists                                        ; Yes error
    tax
    lda     kernel_process+kernel_process_struct::kernel_fd,x
    beq     @doesnot_exists

    cpx     kernel_process+kernel_process_struct::kernel_fd_opened ; is equal to 0 ? No opened files yet ...
    beq     @do_not_seek
  ; At this step we can store the seek of the file
    ; close current file
    jsr     _ch376_file_close
    stx     kernel_process+kernel_process_struct::kernel_fd_opened 
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
    rts

@send:
    jsr     send_0_to_ch376_and_open
    jmp     @loop_next_byte


@send_end_out:
    jsr     send_0_to_ch376_and_open

    ldy     #_KERNEL_FILE::f_seek_file
    
    lda     (KERNEL_XOPEN_PTR1),y
    sta     RESB
    iny
    lda     (KERNEL_XOPEN_PTR1),y
    sta     RESB+1
    iny
    lda     (KERNEL_XOPEN_PTR1),y
    tax
    iny
    lda     (KERNEL_XOPEN_PTR1),y
    sta     RES

    lda     RESB
    ldy     RESB+1
    jsr     _ch376_seek_file32


 
 @do_not_seek:
    




    clc
    rts
@doesnot_exists:    
    ;lda     #$11
    ;sta     $bb80
    sec
    rts
send_0_to_ch376_and_open:
    lda     #$00 
    sta     CH376_DATA 

    jmp     _ch376_file_open ; Open slash
    
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
    
    lda     RES
    sta     CH376_DATA

    jsr     _ch376_wait_response
    rts
.endproc
