.export _XFORK

.proc _XFORK

;;
; This procedure reads data.
; @param CX - number of bytes
; @return DI - address of data
;;

; ***********************************************************************************************************************
;                                          Save ZP of the current process
; ***********************************************************************************************************************

  ldx     kernel_process+kernel_process_struct::kernel_current_process
  ;cpx     #$01 ; is it $FF = init ?
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
   beq     exit_to_kernel    ; Yes we
   rts
exit_to_kernel:
; pull from stack old pc


   pla
   pla
   rts


.endproc 

