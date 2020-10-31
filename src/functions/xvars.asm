
XVARS_ROUTINE:
  lda     XVARS_TABLE_LOW,x
  ldy     XVARS_TABLE_HIGH,x
  rts

XVARS_TABLE:
XVARS_TABLE_LOW:
  .byt     <kernel_process
  .byt     <kernel_malloc
  .byt     <KERNEL_CH376_MOUNT
  .byt     <KERNEL_CONF_BEGIN
  .byt     <KERNEL_ERRNO
  
XVARS_TABLE_HIGH:
  .byt     >kernel_process
  .byt     >kernel_malloc
  .byt     >KERNEL_CH376_MOUNT
  .byt     >KERNEL_CONF_BEGIN
  .byt     >KERNEL_ERRNO
  
  