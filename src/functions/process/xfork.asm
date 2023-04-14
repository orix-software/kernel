.export _XFORK

; Enter TR0,TR1


; Calls : proc kernel_create_process
; Modify TR4,TR5,RES, RESB, kernel_create_process,KERNEL_XKERNEL_CREATE_PROCESS_TMP, kernel_process+kernel_process_struct::kernel_pid_list, KERNEL_MALLOC_TYPE
; kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_low, kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_high
; KERNEL_CREATE_PROCESS_PTR1

.proc _XFORK

.out     .sprintf("|MODIFY:RES:_XFORK")
.out     .sprintf("|MODIFY:TR0:_XFORK")
.out     .sprintf("|MODIFY:TR1:_XFORK")

.out     .sprintf("|MODIFY:RES:_XFORK via kernel_create_process")
.out     .sprintf("|MODIFY:RESB:_XFORK via kernel_create_process")
.out     .sprintf("|MODIFY:TR4:_XFORK via kernel_create_process")
.out     .sprintf("|MODIFY:TR5:_XFORK via kernel_create_process")

.ifdef WITH_DEBUG
  ldx     #XDEBUG_XFORK_STARTING
  ;jsr     xdebug_print_with_a
.endif

; ***********************************************************************************************************************
;                                          Save ZP of the current process
; ***********************************************************************************************************************



  ldx     kernel_process+kernel_process_struct::kernel_current_process
  cpx     #$FF ; is it init ?
  beq     @skip_save_zp  ; For instance, we don't save init zp because all are reserved

  lda     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_low,x
  sta     RES

  lda     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_high,x
  sta     RES+1

  ldx     #$00
  ldy     #kernel_one_process_struct::zp_save_userzp
@L1:
  lda     userzp,x
  sta     (RES),y
  iny
  inx
  cpx     #KERNEL_USERZP_SAVE_LENGTH
  bne     @L1

@skip_save_zp:
  lda     TR0
  ldy     TR1

  jsr     kernel_create_process ; returns null if we reached max process or KERNEL_ERRNO is filled too

  ; we reached max process to launch ?
  lda     KERNEL_ERRNO
  cmp     #KERNEL_ERRNO_MAX_PROCESS_REACHED
  beq     exit_to_kernel_rts    ; Yes we
  rts
exit_to_kernel:
; pull from stack old pc
  pla
  pla
exit_to_kernel_rts:
  rts
.endproc
