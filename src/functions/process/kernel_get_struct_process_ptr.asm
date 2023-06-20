.proc kernel_get_struct_process_ptr
  ; X contains the pid to get
  ; Returns in A and Y ptr

  lda     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_low,x
  ldy     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_high,x
  rts
.endproc
