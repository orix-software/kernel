.proc XOPEN_ROUTINE

.out     .sprintf("|MODIFY:RES:XOPEN_ROUTINE")
.out     .sprintf("|MODIFY:RESB:XOPEN_ROUTINE")
.out     .sprintf("|MODIFY:TR5:XOPEN_ROUTINE")
.out     .sprintf("|MODIFY:TR7:XOPEN_ROUTINE")
.out     .sprintf("|MODIFY:XOPEN_SAVE:XOPEN_ROUTINE")
.out     .sprintf("|MODIFY:XOPEN_FLAGS:XOPEN_ROUTINE")
.out     .sprintf("|MODIFY:XOPEN_RES_SAVE:XOPEN_ROUTINE")
.out     .sprintf("|MODIFY:XOPEN_SAVEA:XOPEN_ROUTINE")
.out     .sprintf("|MODIFY:KERNEL_ERRNO:XOPEN_ROUTINE")
.out     .sprintf("|MODIFY:KERNEL_XOPEN_PTR1:XOPEN_ROUTINE")


; INPUT
;     this routine use :
;        RES, A X Y, XOPEN_SAVE XOPEN_FLAGS, XOPEN_RES_SAVE, XOPEN_SAVEA
;	  and with XMALLOC :
;		     TR7 (malloc)
; OUTPUT
;     A=$FF and X=$FF if it does not exists
;     FD id  in A
; Calls XFREE

  ; A and X contains char * pointer ex /usr/bin/toto.txt but it does not manage the full path yet
  ; Save string in 2 locations RES
  ; Y contains flag
  ; O_RDONLY        = $01
  ; O_WRONLY        = $02
  ; O_RDWR          = $03
  ; O_CREAT         = $10
  ; O_TRUNC         = $20
  ; O_APPEND        = $40
  ; O_EXCL          = $80


; Since kernel 2023.1

  ; Flag               | File exists | behaviour
  ; O_WRONLY & O_CREAT |    No       | Create file, open and return FD
  ; O_WRONLY           |    No       | return Null
  ; O_WRONLY           |    Yes      | open and return FD
  ; O_RDONLY           |    Yes      | open and return FD
  ; O_WRONLY           |    No       | return Null
  ; O_CREAT            |    No       | Create file and open and return FD
  ; O_CREAT            |    Yes      | open and return FD

; Before kernel 2023.1

  ; Flag               | File exists | behaviour
  ; O_WRONLY & O_CREAT |    No       | Create file, open and return FD
  ; O_WRONLY           |    No       | open and return FD
  ; O_WRONLY           |    Yes      | open and return FD
  ; O_RDONLY           |    Yes      | open and return FD
  ; O_WRONLY           |    No       | return Null
  ; O_CREAT            |    No       | Create file and open and return FD
  ; O_CREAT            |    Yes      | open and return FD

  sta     RES
  stx     RES+1
  ; Save ptr
  sta     XOPEN_RES_SAVE
  stx     XOPEN_RES_SAVE+1
  ; save flag

  sty     XOPEN_FLAGS

  ;
  ; Close current file if we already open a file
  lda     kernel_process+kernel_process_struct::kernel_fd_opened ; if there is already a file open on ch376 if value <> $FF, if it's equal to $ff, there is no file opened
  cmp     #$FF
  bne     @open_new_file

  ; close it
  jsr     _ch376_file_close

@open_new_file:
.ifdef WITH_DEBUG2
  jsr     kdebug_save
  ldy     XOPEN_RES_SAVE+1
  ldx     #XDEBUG_XOPEN_ENTER
  jsr     xdebug_print_with_ay_string
  jsr     kdebug_restore
.endif

  lda     #EOK
  sta	    KERNEL_ERRNO

  ; check if device is available
  jsr     _ch376_verify_SetUsbPort_Mount
  cmp     #$01
  bne     @L1
  ; impossible to mount return null and store errno

  lda     #EIO
  sta	    KERNEL_ERRNO
  ldx     #$FF
  txa
  rts
@L1:


  ldy     #$00
  lda     (RES),y
  ;
  cmp     #"/"
  beq     @it_is_absolute      ; It's absolute then skip currentpath
  ; concat
  jsr     XGETCWD_ROUTINE      ; Modify RESB

  jsr     _create_file_pointer ; Modify RES
  ; Check if oom or other too much busy chunk
  cmp     #$00
  bne     @not_null_2
  cpy     #$00
  bne     @not_null_2
  ; For cc65 compatibility

@oom_error:
  lda     #ENOMEM
  sta	    KERNEL_ERRNO

  lda     #$FF
  tax

  rts

@not_null_2:
  sta     KERNEL_XOPEN_PTR1
  sty     KERNEL_XOPEN_PTR1+1
  ; now concat
  ; reach the end of string in the pointer
  ldy     #_KERNEL_FILE::f_path
@L3:
  lda     (KERNEL_XOPEN_PTR1),y
  beq     @end_of_string_found
  iny
  cpy     #KERNEL_MAX_PATH_LENGTH+_KERNEL_FILE::f_path
  bne     @L3

  ; at this step, we cannot detect the end of string : BOF, return null
  jmp     @exit_open_with_null

@end_of_string_found:
  ; This solution avoid to compute pointer and to create another zp address
  cpy    #_KERNEL_FILE::f_path+$01 ; is it slash "/",0 ?
  beq    @don_t_add_slash  ; yes
  ; it's a relative path and we are still in a folder (except /)
  ; add slash then
  lda    #'/'
  sta    (KERNEL_XOPEN_PTR1),y

  iny

@don_t_add_slash:
  sty    RES

  lda    #$00
  sta    XOPEN_SAVEA   ; It will be used to read offset of relative path passed in XOPEN arg

@L4:
  ldy    XOPEN_SAVEA
  lda    (XOPEN_RES_SAVE),y
  beq    @end_of_path_from_arg

  iny
  sty    XOPEN_SAVEA
  ldy    RES

  sta    (KERNEL_XOPEN_PTR1),y

  ; Be careful BOF can occurs if
  iny
  sty    RES
  cpy    #KERNEL_MAX_PATH_LENGTH+_KERNEL_FILE::f_path

  bne     @L4
  ; Bof return NULL

  jmp     @exit_open_with_null

@end_of_path_from_arg:
  ldy     RES
  sta     (KERNEL_XOPEN_PTR1),y

  jmp     @open_from_device

@it_is_absolute:
  ; Pass arg to createfile_pointer

  lda     RES
  ldy     RES+1
  ; and XOPEN_FLAGS too at this step

  jsr     _create_file_pointer
  cmp     #NULL
  bne     @not_null_1
  cpy     #NULL
  bne     @not_null_1
  ; oom error
  jmp     @oom_error


@not_null_1:
  sta     KERNEL_XOPEN_PTR1
  sty     KERNEL_XOPEN_PTR1+1

@open_from_device:
  ; Reset flag to say that end of string is reached
  lda     #$01
  sta     XOPEN_SAVEA

  lda     #CH376_SET_FILE_NAME        ;$2F
  sta     CH376_COMMAND

  lda     #'/'
  sta     CH376_DATA

  jsr     send_0_to_ch376_and_open

  ldy     #_KERNEL_FILE::f_path+1 ; skip /

@next_filename:
  lda     #CH376_SET_FILE_NAME        ;$2F
  sta     CH376_COMMAND
  jsr     ch376_open_filename
  cmp     #$00
  bne     @slash_found

@end_of_string:
  sta     XOPEN_SAVEA ; Contains 0
  beq     @S3
  ; cpy     #_KERNEL_FILE::f_path+1  ; Do we reach $00 ? at the second char ? It means that it's '/' only
  ; beq     @open_and_register_fp
  ; bne     @S3

@slash_found:
  ; do we reach / at the first char ? It should, then we enter
  ;sta     XOPEN_SAVEA ; Contains /
  cpy     #_KERNEL_FILE::f_path
  bne     @S3
  sta     CH376_DATA ; store /

@S3:

  sty     XOPEN_SAVEY

  jsr     send_0_to_ch376_and_open

  cmp     #CH376_ERR_MISS_FILE
  beq     @file_not_found

  ldy     XOPEN_SAVEY ; reload Y
  lda     XOPEN_SAVEA
  beq     @open_and_register_fp
  iny
  lda     (KERNEL_XOPEN_PTR1),y
  bne     @next_filename
  cpy     #_KERNEL_FILE::f_path+1
  beq     @open_and_register_fp

  bne     @next_filename


@file_not_found:

  ; Checking if filesys is found
  ; lda     FILESYS_BANK
  ; beq     @filesys_bank_not_found

@filesys_bank_not_found:
  ; When we have file not found, do we have O_CREATE flag ?
  lda     XOPEN_FLAGS
  and     #O_CREAT
  cmp     #O_CREAT
  beq     @could_be_created ; Yes, create

  ; When we have 'file not found', do we have O_WRONLY flag ?
  lda     XOPEN_FLAGS ; Get flags
  and     #O_WRONLY
  cmp     #O_WRONLY
  beq     @exit_open_with_null ; yes, return NULL


  ; Le fichier n'a pas été trouvé,
  ; On va vérifier qu'on avait un fichier ouvert avant
  lda     kernel_process+kernel_process_struct::kernel_fd_opened ; if there is already a file open on ch376 if value <> $FF, if it's equal to $ff, there is no file opened
  cmp     #$FF
  beq     @exit_open_with_null

  clc
  adc     #KERNEL_FIRST_FD
  jsr     open_full_filename

@exit_open_with_null:
  lda     KERNEL_XOPEN_PTR1
  ldy     KERNEL_XOPEN_PTR1+1
  jsr     XFREE_ROUTINE
  ; No such file_or_directy
  lda     #ENOENT
  sta     KERNEL_ERRNO

.ifdef    WITH_DEBUG2
  ldx     #XDEBUG_XOPEN_FILE_NOT_FOUND
  lda     #$FF
  jsr     xdebug_print_with_a
.endif

  lda     #$FF
  tax

  rts
;XOPEN m'a posé quelques soucis, je pensais utiliser les flags O_RDONLY
;et O_RDWR ou O_WRONLY, mais O_WRONLY fait une création systématique du
;fichier et O_RDWR n'est pas pris en charge.
@could_be_created:
  jsr     _ch376_file_create

@open_and_register_fp:
  ; Register fp in process struct
  ;       store pointer in process struct
  ldx     kernel_process+kernel_process_struct::kernel_current_process                ; Get current process
  jsr     kernel_get_struct_process_ptr
  sta     RES
  sty     RES+1

  ; Fill the address of the fp
  ; Manage only 1 FP for instance FIXME bug
  ldx     #$00
  ldy     #(kernel_one_process_struct::fp_ptr+1)

@try_to_find_a_free_fp_for_current_process:
  lda     (RES),y                             ; Load high
  beq     @fp_is_not_busy                     ; If it's equal to $00, it means that it's empty because it's impossible to have a fp registered in zp

  iny
  iny

  inx
  cpx     #KERNEL_MAX_FP_PER_PROCESS
  bne     @try_to_find_a_free_fp_for_current_process

  lda     #KERNEL_ERRNO_REACH_MAX_FP_FOR_A_PROCESS
  sta     KERNEL_ERRNO

  beq     @exit_open_with_null
  ;
@fp_is_not_busy:
  lda     KERNEL_XOPEN_PTR1+1
  sta     (RES),y
  dey
  lda     KERNEL_XOPEN_PTR1
  sta     (RES),y

  ; Now try to find an available FD

  ldx     #$00

@init_fp:
  lda     kernel_process+kernel_process_struct::kernel_fd,x
  beq     @found_fp_slot
  inx
  cpx     #KERNEL_MAX_FP
  bne     @init_fp

  ; No available fd
  lda     KERNEL_XOPEN_PTR1
  ldy     KERNEL_XOPEN_PTR1+1
  jsr     XFREE_ROUTINE

  lda     #EMFILE
  sta     KERNEL_ERRNO

  lda     #$FF
  tax
  rts

  ; not found
@found_fp_slot:
  lda     kernel_process+kernel_process_struct::kernel_current_process ; Get the current process
  sta     kernel_process+kernel_process_struct::kernel_fd,x            ; and store in fd slot the id of the process
  txa
  pha ; save Id of the fd
  asl
  tax

  ; Store fp in main process
  lda     KERNEL_XOPEN_PTR1
  sta     kernel_process+kernel_process_struct::fp_ptr,x
  inx
  lda     KERNEL_XOPEN_PTR1+1
  sta     kernel_process+kernel_process_struct::fp_ptr,x
  pla   ; restore Id of the fd
  sta     kernel_process+kernel_process_struct::kernel_fd_opened ; Define that it's the new current fd
  clc
  adc     #KERNEL_FIRST_FD

  ; Store the id of the fp opened in ch376
.ifdef WITH_DEBUG2
  pha
  ldx     #XDEBUG_FD
  jsr     xdebug_print_with_a
  pla
.endif
  ldx     #$00


  rts
.endproc
