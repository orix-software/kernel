
.include "include/xvars.inc"

.proc XVARS_ROUTINE
  lda     XVARS_TABLE_LOW,x
  ldy     XVARS_TABLE_HIGH,x
  ldx     #$00
  rts
.endproc

.proc XVALUES_ROUTINE
  cpx     #KERNEL_XVALUES_FREE_MALLOC_TABLE
  beq     @malloc_table_copy    ; Used by lsmem

  cpx     #KERNEL_XVALUES_BUSY_MALLOC_TABLE
  beq     @malloc_table_busy_copy   ; Used by lsmem

  cpx     #$08
  beq     @XVARS_GET_PROCESS_NAME_PTR_CALL ; Used by lsmem

  cpx     #$09
  beq     @xvars_get_fd_list_call   ; Used by lsof

  cpx     #KERNEL_XVALUES_GET_FTELL_FROM_FD
  beq     @xvars_ftell_call   ; Used by lsof

  cpx     #$00
  bne     @check_who_am_i

  lda     XVARS_TABLE_LOW,x
  sta     RES

  lda     XVARS_TABLE_HIGH,x
  sta     RES+1

  ldy     #$00
  lda     (RES),y

  rts

@xvars_ftell_call:
  jmp     xvars_ftell

@malloc_table_copy:
  lda     #<(.sizeof(kernel_malloc_struct));+.sizeof(kernel_malloc_busy_begin_struct)+.sizeof(kernel_malloc_free_chunk_size_struct))
  ldy     #>(.sizeof(kernel_malloc_struct));+.sizeof(kernel_malloc_busy_begin_struct)+.sizeof(kernel_malloc_free_chunk_size_struct))
  jsr     XMALLOC_ROUTINE

  sta     RES
  sta     RESB

  sty     RES+1
  sty     RESB+1

  jsr     XMALLOC_COPY_TABLE_FREE

  lda     RESB
  ldy     RESB+1

  rts

@XVARS_GET_PROCESS_NAME_PTR_CALL:
  jmp   XVARS_GET_PROCESS_NAME_PTR

@xvars_get_fd_list_call:
  jmp   xvars_get_fd_list

@malloc_table_busy_copy:
  lda     #<(.sizeof(kernel_malloc_struct));+.sizeof(kernel_malloc_busy_begin_struct)+.sizeof(kernel_malloc_free_chunk_size_struct))
  ldy     #>(.sizeof(kernel_malloc_struct));+.sizeof(kernel_malloc_busy_begin_struct)+.sizeof(kernel_malloc_free_chunk_size_struct))
  jsr     XMALLOC_ROUTINE

  sta     RES
  sta     RESB

  sty     RES+1
  sty     RESB+1

  jsr     XMALLOC_COPY_TABLE_BUSY2

  lda     RESB
  ldy     RESB+1

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


.proc xvars_ftell
  ; A contains the fd
  jsr     compute_fp_struct
  ; Return the current size
  ; Set now seek position to 0 ("32 bits")
  ldy     #_KERNEL_FILE::f_seek_file

  lda     (KERNEL_XOPEN_PTR1),y   ; A
  sta     RESB
  iny
  lda     (KERNEL_XOPEN_PTR1),y   ; X
  tax
  iny
  lda     (KERNEL_XOPEN_PTR1),y   ; Y
  sta     RESB+1

  iny
  lda     (KERNEL_XOPEN_PTR1),y   ; RES
  sta     RES
  lda     RESB
  ldy     RESB+1
  rts


.endproc

.proc xvars_get_fd_list
  ; Y contains the fd to get
  lda     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_low,y

  sta     RES

  lda     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_high,y
  sta     RES+1

  ; ptr Fd = $0000 if yes no fd opened
  lda     RES
  bne     continue

  lda     RES+1
  bne     continue

  rts



continue:

  lda   #_KERNEL_FILE::f_path
  clc
  adc   RES
  bcc   @S1
  inc   RES+1
@S1:
  ; A is valid
  ldy   RES+1

  rts
.endproc

.proc XMALLOC_COPY_TABLE_FREE

  lda     #$00
  sta     TR0 ; number of lines

  ldy     #$01 ; Because we store the number of line
  ldx     #$00
@loop_copy_free_chunk_begin_low:
  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_high,x
  beq     @free_slot_not_used      ; Begin low is equal to 0 ? Yes, it's empty
  sta     (RES),y
  iny

  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_low,x
  sta     (RES),y
  iny

  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_end_high,x
  sta     (RES),y
  iny


  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_end_low,x
  sta     (RES),y
  iny

  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high,x
  sta     (RES),y
  iny


  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_low,x
  sta     (RES),y
  iny

  inc     TR0

@free_slot_not_used:
  inx
  cpx     #KERNEL_MALLOC_FREE_CHUNK_MAX
  bne     @loop_copy_free_chunk_begin_low

  ldy     #$00
  lda     TR0
  sta     (RES),y

; Store number of line at the first byte


  rts
.endproc

.proc XMALLOC_COPY_TABLE_BUSY2

  lda     #$00
  sta     TR0 ; number of lines

  ldy     #$01
  ldx     #$00

@loop_copy_busy_chunk_begin_low:

  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_high,x

  beq     @busy_slot_not_used      ; Begin low is equal to 0 ? Yes, it's empty

  sta     (RES),y
  iny

  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_low,x
  sta     (RES),y
  iny

  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_high,x
  sta     (RES),y
  iny


  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_low,x
  sta     (RES),y
  iny

  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_high,x
  sta     (RES),y
  iny

  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_low,x
  sta     (RES),y
  iny

  inc     TR0

@busy_slot_not_used:
  inx
  cpx     #KERNEL_MAX_NUMBER_OF_MALLOC
  bne     @loop_copy_busy_chunk_begin_low

  ldy     #$00
  lda     TR0
  sta     (RES),y


  rts
.endproc

.proc XVARS_GET_PROCESS_NAME_PTR
  ; Y contains the chunk

  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_pid_list,y
  cmp     #$FF    ; is init ?
  beq     @init

  tay

  lda     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_low,y
  sta     RES

  lda     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_high,y
  sta     RES+1

  ; now get name

  lda     RES
  ldy     RES+1

  rts
@init:
  lda   #$00 ; Return null if it's init
  ldy   #$00
  rts
.endproc

.proc XVARS_COPY_MALLOC_TABLE_COMPUTE_OFFSET_FREE_CHUNK
  lda     RES
  clc
  adc     #KERNEL_MALLOC_FREE_CHUNK_MAX
  bcc     @S1
  inc     RES+1
@S1:
  sta     RES
  rts
.endproc


.proc XVARS_COPY_MALLOC_TABLE_COMPUTE_OFFSET_BUSY_CHUNK
  lda     RES
  clc
  adc     #KERNEL_MAX_NUMBER_OF_MALLOC
  bcc     @S1
  inc     RES+1
@S1:
  sta     RES
  rts
.endproc


XVARS_TABLE_VALUE_LOW:
  .byt     <KERNEL_ERRNO
XVARS_TABLE_VALUE_HIGH:
  .byt     >KERNEL_ERRNO

XVARS_TABLE:
XVARS_TABLE_LOW:
  .byt     <kernel_process      ; 0
  .byt     <kernel_malloc       ; 1
  .byt     <KERNEL_CH376_MOUNT  ; 2
  .byt     <KERNEL_CONF_BEGIN   ; 3
  .byt     <KERNEL_ERRNO        ; 4
  .byt     KERNEL_MAX_NUMBER_OF_MALLOC ; 5
  .byt     CURRENT_VERSION_BINARY      ; Used in untar
  .byte    $00 ; Table low malloc

XVARS_TABLE_HIGH:
  .byt     >kernel_process
  .byt     >kernel_malloc
  .byt     >KERNEL_CH376_MOUNT
  .byt     >KERNEL_CONF_BEGIN
  .byt     >KERNEL_ERRNO
  .byt     KERNEL_MALLOC_FREE_CHUNK_MAX
  .byt     $00
  .byt     $00 ; ; Table high
