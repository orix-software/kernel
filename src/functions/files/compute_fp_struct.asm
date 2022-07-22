.proc compute_fp_struct

  ; A contains the fd id
  sec
  sbc     #KERNEL_FIRST_FD
  asl
  tax
  lda     kernel_process+kernel_process_struct::fp_ptr,x
  sta     KERNEL_XOPEN_PTR1
  inx
  lda     kernel_process+kernel_process_struct::fp_ptr,x
  sta     KERNEL_XOPEN_PTR1+1
  rts
.endproc
