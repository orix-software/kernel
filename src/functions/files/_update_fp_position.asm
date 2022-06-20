
.proc _update_fp_position

  sec
  lda     PTR_READ_DEST
  sbc     RES
  tay
  lda     PTR_READ_DEST+1
  sbc     RES+1
  tax
  tya

  ; X & A are the size to update
  ; y is the fp

  ; Save length

  sta     XOPEN_RES
  stx     XOPEN_RES+1

  ; compute fp
  lda     KERNEL_XWRITE_XCLOSE_XFSEEK_XFREAD_SAVE_X
  ; A is the id of the fp
  jsr     compute_fp_struct


  ldy     #_KERNEL_FILE::f_seek_file

  lda     (KERNEL_XOPEN_PTR1),y

  clc
  adc     XOPEN_RES
  sta     (KERNEL_XOPEN_PTR1),y

  iny
  lda     (KERNEL_XOPEN_PTR1),y
  adc     XOPEN_RES+1

  iny
  lda     (KERNEL_XOPEN_PTR1),y
  adc     #$00

  iny
  lda     (KERNEL_XOPEN_PTR1),y
  adc     #$00

  ; restore A & X

  lda     XOPEN_RES
  ldx     XOPEN_RES+1


  rts

.endproc
