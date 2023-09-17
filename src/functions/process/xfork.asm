.export _XFORK

; Enter TR0,TR1


; Calls : proc kernel_create_process
; Modify TR4,TR5,RES, RESB, kernel_create_process,KERNEL_XKERNEL_CREATE_PROCESS_TMP, kernel_process+kernel_process_struct::kernel_pid_list, KERNEL_MALLOC_TYPE
; kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_low, kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_high
; KERNEL_CREATE_PROCESS_PTR1

.proc _XFORK

; At the end of XFORK, the current process is the new process

.out     .sprintf("|MODIFY:RES:_XFORK")
.out     .sprintf("|MODIFY:TR0:_XFORK")
.out     .sprintf("|MODIFY:TR1:_XFORK")

.out     .sprintf("|MODIFY:RES:_XFORK via kernel_create_process")
.out     .sprintf("|MODIFY:RESB:_XFORK via kernel_create_process")
.out     .sprintf("|MODIFY:TR4:_XFORK via kernel_create_process")
.out     .sprintf("|MODIFY:TR5:_XFORK via kernel_create_process")

.ifdef WITH_DEBUG
  ldx     #XDEBUG_XFORK_STARTING
  ;jsr     xdebug_print_with_a
.endif

; ***********************************************************************************************************************
;                                          Save ZP of the current process
; ***********************************************************************************************************************

  ldx     HRS3
  cpx     #KERNEL_NOFORK_PROCESS ; HRS3 contains the value of XEXEC mode call ()
  bne     @perform_fork

  ; At this step we replace the process
  ; ; Let's free all memory from this process
  ldx     kernel_process+kernel_process_struct::kernel_current_process
  ;jsr     erase_all_chunk_from_current_process

  ; Change command line
  lda     kernel_process+kernel_process_struct::kernel_current_process
  jsr     kernel_get_struct_process_ptr

  sty     KERNEL_CREATE_PROCESS_PTR1+1
  sta     KERNEL_CREATE_PROCESS_PTR1

  clc
  adc     #kernel_one_process_struct::cmdline
  bcc     @S7
  inc     KERNEL_CREATE_PROCESS_PTR1+1
@S7:
  sta     KERNEL_CREATE_PROCESS_PTR1

; Shebang management
; Copy new cmdline with #!
  ldy     #$00
@L10:
  lda     (TR0),y ; Get the command launched (full command)
  beq     @S8
  sta     (KERNEL_CREATE_PROCESS_PTR1),y
  iny
  cpy     #(KERNEL_LENGTH_MAX_CMDLINE-1)
  bne     @L10
  lda     #$00    ; Store 0
@S8:
  sta     (KERNEL_CREATE_PROCESS_PTR1),y

  ldy     #EOK

  rts

@perform_fork:
  ldx     kernel_process+kernel_process_struct::kernel_current_process
  cpx     #$FF ; is it init ?
  beq     @skip_save_zp  ; For instance, we don't save init zp because all are reserved

  jsr     kernel_get_struct_process_ptr
  sta     RES
  sty     RES+1

  ldx     #$00
  ldy     #kernel_one_process_struct::zp_save_userzp
@L1:
  lda     userzp,x
  sta     (RES),y
  iny
  inx
  cpx     #KERNEL_USERZP_SAVE_LENGTH
  bne     @L1

@skip_save_zp:
  lda     TR0
  ldy     TR1

  jsr     kernel_create_process ; returns null if we reached max process or KERNEL_ERRNO is filled too

  rts

.endproc
