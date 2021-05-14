
XVARS_ROUTINE:
  lda     XVARS_TABLE_LOW,x
  ldy     XVARS_TABLE_HIGH,x
  rts

.proc XVALUES_ROUTINE:

  lda     XVARS_TABLE_LOW,x
  sta     RES
  
  lda     XVARS_TABLE_HIGH,x
  sta     RES+1

  ldy     #$00
  lda     (RES),y
  
  rts
.endproc  

XVARS_TABLE_VALUE_LOW:
  .byt     <KERNEL_ERRNO
XVARS_TABLE_VALUE_HIGH:  
  .byt     >KERNEL_ERRNO

XVARS_TABLE:
XVARS_TABLE_LOW:
  .byt     <kernel_process
  .byt     <kernel_malloc
  .byt     <KERNEL_CH376_MOUNT
  .byt     <KERNEL_CONF_BEGIN
  .byt     <KERNEL_ERRNO
  .byt     KERNEL_MAX_NUMBER_OF_MALLOC
  
XVARS_TABLE_HIGH:
  .byt     >kernel_process
  .byt     >kernel_malloc
  .byt     >KERNEL_CH376_MOUNT
  .byt     >KERNEL_CONF_BEGIN
  .byt     >KERNEL_ERRNO
  .byt     KERNEL_MALLOC_FREE_CHUNK_MAX
  
  