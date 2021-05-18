
XVARS_ROUTINE:
  lda     XVARS_TABLE_LOW,x
  ldy     XVARS_TABLE_HIGH,x
  rts


; 

.define WHO_AM_IAM $01

.proc XVALUES_ROUTINE
  cpx     #$00
  bne     @check_who_am_i

  lda     XVARS_TABLE_LOW,x
  sta     RES
  
  lda     XVARS_TABLE_HIGH,x
  sta     RES+1

  ldy     #$00
  lda     (RES),y
  
  rts

@check_who_am_i:
  cpx     #$01
  bne     @out

  lda     #$00
  sta     RES

  lda     $342
  and     #%00100000
  cmp     #%00100000  
  bne     @rom 
  lda     #32
  sta     RES
@rom:  

  lda     $343
  beq     @do_not_compute
  cmp     #$04
  bne     @not_set_4
  
  lda     #$00
  
@not_set_4:

    
  tax
  ;dex
  lda     #$00
@L1:
  clc
  adc     #$04  
  dex
  bne     @L1

@do_not_compute:
  clc 
  adc     BNK_TO_SWITCH
  clc 
  adc     RES

  rts

@out:
  lda     #$01
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
  
  