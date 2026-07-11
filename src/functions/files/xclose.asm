.export XCLOSE_ROUTINE

.proc XCLOSE_ROUTINE
 ; $d046
  ;  jmp XCLOSE_ROUTINE
    ; A contains FD
    ; Calls XFREE
    .out    .sprintf("|MODIFY:RESB:XCLOSE_ROUTINE")
    .out    .sprintf("|MODIFY:TR7:XCLOSE_ROUTINE")
    sta     RESB
    sty     RESB + 1 ; save fp



  ; Try to found FP
  ; kernel_process+kernel_process_struct::kernel_fd contient un tableau où la position 0 est le FD 3 (car on commence à 3 avec stin- 0 , stdout, stderr)

  ; kernel_process+kernel_process_struct::kernel_fd,x contient 0 si le FD n'est pas connu
  ; si c'est différent de 0, alors cela contient le process concerné
    sec
    sbc     #KERNEL_FIRST_FD
    sta     TR7

    ; Checking if we tries to close a fp greater than the max allowed
    cmp     #KERNEL_MAX_FP
    bcs     @exit

    tax
    lda     kernel_process + kernel_process_struct::kernel_fd,x ; A contient l'id du process, X contient l'id du FD retranché de 3
    bne     @found_fp_slot


@exit:
    rts

@found_fp_slot:
    ; Process should be called here


    txa ; Transfert fd 'id slot'
    asl ; Multiply * 2
    tax
    ; remove fp from main struct

.IFPC02
.pc02
    stz     kernel_process + kernel_process_struct::fp_ptr,x
    inx
    stz     kernel_process + kernel_process_struct::fp_ptr,x
.p02
.else
    lda     #$00
    sta     kernel_process + kernel_process_struct::fp_ptr,x
    inx
    sta     kernel_process + kernel_process_struct::fp_ptr,x
.endif

;       store pointer in process struct
    ldx     kernel_process + kernel_process_struct::kernel_current_process                ; Get current process
    jsr     kernel_get_struct_process_ptr
    sta     RESB ; $741
    sty     RESB + 1

    lda     TR7
    asl
    clc
    adc     #kernel_one_process_struct::fp_ptr
    tay

@try_to_find_a_free_fp_for_current_process:
    lda     (RESB),y

    pha
    iny
    lda     (RESB),y

    tay
    pla
     ; $7D5

    jsr     XFREE_ROUTINE

    ; Clear fp in current process
    lda     TR7
    asl
    clc
    adc     #kernel_one_process_struct::fp_ptr
    tay
    lda     #$00
    sta     (RESB),y
    iny
    sta     (RESB),y

    ; Flush entry
    ldx     TR7

.IFPC02
.pc02
    stz     kernel_process + kernel_process_struct::kernel_fd,x
.p02
.else
    lda     #$00
    sta     kernel_process + kernel_process_struct::kernel_fd,x
.endif

    cpx     kernel_process + kernel_process_struct::kernel_fd_opened ; does the fd sent is the current file opened ? if no, it's already close, then don't close it from ch376
    beq     close_in_ch376
    rts

close_in_ch376:
    jmp     _ch376_file_close
.endproc
