
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
  lda     (KERNEL_XOPEN_PTR1),y ; Get first byte
  clc
  adc     XOPEN_RES
  sta     (KERNEL_XOPEN_PTR1),y  ; update byte 1 of the file position
  bcc     @no_inc_byte2

  ldy     #(_KERNEL_FILE::f_seek_file+1)
  jsr     inc_byte_superior ; byte 2
  bcc     @no_inc_byte2

  ldy     #(_KERNEL_FILE::f_seek_file+2)
  jsr     inc_byte_superior
  bcc     @no_inc_byte2

  ldy     #(_KERNEL_FILE::f_seek_file+3)
  jsr     inc_byte_superior
  bcc     @no_inc_byte2


@no_inc_byte2:
  ldy     #(_KERNEL_FILE::f_seek_file+1)
  lda     (KERNEL_XOPEN_PTR1),y
  adc     XOPEN_RES+1
  sta     (KERNEL_XOPEN_PTR1),y  ; update byte 2 of the file position
  bcc     @no_inc_byte3

  ldy     #(_KERNEL_FILE::f_seek_file+2)
  jsr     inc_byte_superior ; Byte 3
  bcc     @no_inc_byte3

  ldy     #(_KERNEL_FILE::f_seek_file+3)
  jsr     inc_byte_superior ; byte 4

@no_inc_byte3:
  lda     XOPEN_RES
  ldx     XOPEN_RES+1
  rts

inc_byte_superior:
  clc
  lda     #$01
  adc     (KERNEL_XOPEN_PTR1),y
  sta     (KERNEL_XOPEN_PTR1),y
  rts
.endproc
