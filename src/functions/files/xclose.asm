.export XCLOSE_ROUTINE

.proc XCLOSE_ROUTINE
    ; A & Y contains fd
    sta     RESB
    stx     RESB+1 ; save fp

.ifdef WITH_DEBUG
    pha
    ldx     #XDEBUG_FCLOSE_ENTER
    jsr     xdebug_print_with_a
    pla
.endif

  ; Try to found FP
  ;ldx     #$00
  ; kernel_process+kernel_process_struct::kernel_fd contient un tableau où la position 0 est le FD 3 (car on commence à 3 avec stin- 0 , stdout, stderr)

  ; kernel_process+kernel_process_struct::kernel_fd,x contient 0 si le FD n'est pas connu 
  ; si c'est différent de 0, alors cela contient le process concerné
  lda     kernel_process+kernel_process_struct::kernel_fd,x ; If 
  bne     @found_fp_slot


.ifdef WITH_DEBUG
    ldx     #XDEBUG_XCLOSE_FD_NOT_FOUND
    jsr     xdebug_print_with_a
.endif
    rts
@found_fp_slot:
    ; Process should be called here

    lda     #$00
    sta     kernel_process+kernel_process_struct::kernel_fd,x

    txa
    asl
    tax
    lda     #$00
    sta     kernel_process+kernel_process_struct::fp_ptr,x
    inx
    sta     kernel_process+kernel_process_struct::fp_ptr,x

    ; close FD
    ;XDEBUG_XCLOSE_FD_NOT_FOUND
	;jsr     XFREE_ROUTINE
    
    jmp     _ch376_file_close
.endproc	
