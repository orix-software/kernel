.export XCLOSE_ROUTINE

.proc XCLOSE_ROUTINE
    ; A & Y contains fd
    ; Calls XFREE
    .out     .sprintf("|MODIFY:RESB:XCLOSE_ROUTINE")  
    .out     .sprintf("|MODIFY:TR7:XCLOSE_ROUTINE")  
    sta     RESB
    sty     RESB+1 ; save fp



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

  ; $580
    sec
    sbc     #KERNEL_FIRST_FD
    
    sta     TR7
    
    ; Cheking if we tries to close a fp greater than the max allowed

    cmp     #KERNEL_MAX_FP
    bcs     @exit

    tax
    lda     kernel_process+kernel_process_struct::kernel_fd,x ; If 
    bne     @found_fp_slot


.ifdef WITH_DEBUG
    jsr     kdebug_save
    txa
    ldx     #XDEBUG_XCLOSE_FD_NOT_FOUND
    jsr     xdebug_print_with_a
    jsr     kdebug_restore
.endif
@exit:
    rts

@found_fp_slot:
    ; Process should be called here
.ifdef WITH_DEBUG
    pha
    lda     RESB
    ldx     #XDEBUG_XCLOSE_FD_FOUND
    jsr     xdebug_print
    pla
        
.endif


    txa
    asl
    
  
    tax
    ; remove fp from main struct
    lda     #$00
    sta     kernel_process+kernel_process_struct::fp_ptr,x
    inx
    sta     kernel_process+kernel_process_struct::fp_ptr,x

;       store pointer in process struct
    ldx     kernel_process+kernel_process_struct::kernel_current_process                ; Get current process

    lda     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_low,x   ; Get current process struct 
    sta     RESB


    lda     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_high,x
    sta     RESB+1



    ldy     #kernel_one_process_struct::fp_ptr
@try_to_find_a_free_fp_for_current_process:
    lda     (RESB),y
 
    pha
    iny
    lda     (RESB),y

    tay
    pla
     ; $7D5
    jsr     XFREE_ROUTINE

    ldy     #kernel_one_process_struct::fp_ptr
    lda     #$00
    sta     (RESB),y
    iny
    sta     (RESB),y



    ; Flush entry
    ldx     TR7
    lda     #$00
    sta     kernel_process+kernel_process_struct::kernel_fd,x

    
    jmp     _ch376_file_close
.endproc	
