.proc compute_fp_struct
  ; X contains the fd id
  lda     kernel_process+kernel_process_struct::fp_ptr,x
  sta     KERNEL_XOPEN_PTR1
  inx
  lda     kernel_process+kernel_process_struct::fp_ptr,x
  sta     KERNEL_XOPEN_PTR1+1
  rts
.endproc
