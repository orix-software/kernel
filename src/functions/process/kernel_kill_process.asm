; Parameter in : A id of the PID to kill

.proc      kernel_kill_process
    
; ***********************************************************************************************************************
;                                          load ZP of the PPID
; ***********************************************************************************************************************
  ; at this step, it's not possible to kill init (ID = 0)

  cmp     #$FF ; is it init 
  beq     @skip_load_zp  ; For instance, we don't load zp because all are reserved for init
  
  sta     KERNEL_XKERNEL_CREATE_PROCESS_TMP ; Save index to remove


.ifdef WITH_DEBUG
  pha
  ldx     #XDEBUG_KILL_PROCESS_ENTER
  jsr     xdebug_print_with_a
  pla
.endif  
  ; Try to close fp from this process

  jsr     close_all_fp

@continue:
  ; destroy it's own memory chunks
  ;sta     RES

; Try to find all malloc from this process
  ldx     #$00
@L2:  

  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_pid_list,x

  beq     @skip             ; is it 0 ? Yes it's a free chunk
  
  cmp     KERNEL_XKERNEL_CREATE_PROCESS_TMP
  beq     @erase_chunk
  
@skip:  
  inx 
  cpx     #KERNEL_MAX_NUMBER_OF_MALLOC
  bne     @L2
  beq     @all_chunk_are_free
@erase_chunk:
  txa
  pha

  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_low,x
  ldy     kernel_malloc_busy_begin+kernel_malloc_busy_begin_struct::kernel_malloc_busy_chunk_begin_high,x

  jsr     XFREE_ROUTINE
  
  pla
  tax
  jmp     @L2
             
@all_chunk_are_free:
  ; Get the PPID  



  ldx     KERNEL_XKERNEL_CREATE_PROCESS_TMP
  ;tax
  lda     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_low,x
  sta     RES

  lda     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_high,x
  sta     RES+1

  ldy     #kernel_one_process_struct::ppid

  lda     (RES),y   ; A contains the PPID

  ; X contains the current PID to kill here clear struct
  sta     kernel_process+kernel_process_struct::kernel_current_process


  ; remove reference of process struct in the main struct
  lda     #$00
  sta     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_low,x
  sta     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_high,x
  
  ; remove pid from ps list
  sta     kernel_process+kernel_process_struct::kernel_pid_list,x   ; Flush pidlist to 0 for the current index

  lda     RES
  ldy     RES+1
  jsr     XFREE_ROUTINE ; We remove reference of the memory but it's still in RES
  
  ; at this step process struct is clear and does not exists again
  
  ; restore zp of the PPID

  ldy     kernel_process+kernel_process_struct::kernel_current_process
  
  ;dey
  
  lda     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_low,y
  sta     RES

  lda     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_high,y
  sta     RES+1


  ldx     #$00
  ldy     #kernel_one_process_struct::zp_save_userzp
@L1:  
  lda     (RES),y
  sta     userzp,x
  iny
  inx
  cpx     #KERNEL_USERZP_SAVE_LENGTH
  bne     @L1

@skip_load_zp: 

  ; destroy process
  ;lda  #<str_destroyed
  ;ldy  #>str_destroyed
  ;jsr  XWSTR0_ROUTINE
  rts
;str_destroyed:
  ;.asciiz "Destroyed" 


close_all_fp:
  ldx     #$00
@init_fp:  
  cmp     kernel_process+kernel_process_struct::kernel_fd,x
  bne     @next
  
  txa 
  pha
  clc
  adc     #KERNEL_FIRST_FD
  jsr     XCLOSE_ROUTINE ; Close
  pla
  tax
  lda     KERNEL_XKERNEL_CREATE_PROCESS_TMP
  

@next:
  inx
  cpx     #KERNEL_MAX_FP
  bne     @init_fp
  rts


.endproc
