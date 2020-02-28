.export _XFORK

.proc _XFORK

; ***********************************************************************************************************************
;                                          Save ZP of the current process
; ***********************************************************************************************************************

  ldx     kernel_process+kernel_process_struct::kernel_current_process
  cpx     #$FF ; is it $FF = init ?
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
 
    ;iny
  ;cpy     #KERNEL_USERZP_SAVE_LENGTH  
  ;lda     RESB+1
  ;sta     TR5

  ;lda     RESB
  ;clc
  ;adc     #kernel_one_process_struct::zp_save_userzp
  ;bcc     @S11
  ;inc     TR5
;@S11:
  ;sta     TR4
; now TR4 & TR5 are set the the beginning of cmdline

  ;ldy     #$00
;@L11:  
 ; lda     userzp,y
;  sta     (TR4),y
  ;iny
  ;cpy     #KERNEL_USERZP_SAVE_LENGTH
  ;bne     @L11
@skip_save_zp:
   lda     TR0
   ldy     TR1


   jsr     kernel_create_process
   rts
.endproc 

