.proc _set_to_add_value_seek_file
  ; KERNEL_XOPEN_PTR1 contains the ptr of the file struct
  ; RES & RESB contains the offset
  ; KERNEL_XOPEN_PTR1 must be set to the fd struct

  ldy     #_KERNEL_FILE::f_seek_file
  lda     RES
  sta     (KERNEL_XOPEN_PTR1),y
  iny
  lda     RES+1
  sta     (KERNEL_XOPEN_PTR1),y
  iny
  lda     RESB
  sta     (KERNEL_XOPEN_PTR1),y
  iny
  lda     RESB+1
  sta     (KERNEL_XOPEN_PTR1),y
  rts
.endproc
