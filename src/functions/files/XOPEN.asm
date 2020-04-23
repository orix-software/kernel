.proc XOPEN_ROUTINE
; INPUT
;     this routine use : 
;        RES, A X Y, XOPEN_SAVE XOPEN_FLAGS, XOPEN_RES_SAVE, XOPEN_SAVEA
;	  and with XMALLOC :
;		     TR7 (malloc)
; OUTPUT
;     NULL if it does not exists
;     filepointer in A & Y (and X for cc65 compatibility)


  ; A and X contains char * pointer ex /usr/bin/toto.txt but it does not manage the full path yet
  ; Save string in 2 locations RES
  sta     RES
  stx     RES+1

  sta     XOPEN_RES_SAVE
  stx     XOPEN_RES_SAVE+1
  ; save flag
  sty     XOPEN_FLAGS
  
  lda     #EOK
  sta	    KERNEL_ERRNO

  ; check if device is available
  jsr     _ch376_verify_SetUsbPort_Mount
  cmp     #$01
  bne     @L1
  ; impossible to mount return null and store errno


  lda     #ENODEV
  sta	    KERNEL_ERRNO
  ldx     #$00
  txa
  rts
@L1:
  ldy     #$00
  lda     (RES),y
  ;
  cmp     #"/"
  beq     @it_is_absolute ; It's absolute then skip currentpath
  ; concat
  jsr     XGETCWD_ROUTINE ; Modify RESB

  jsr     _create_file_pointer ; Modify RES
  
  ;cmp     #NULL
  ;bne     @not_null_2
  ;cpy     #NULL
  ;bne     @not_null_2
  ;lda     #ENOMEM
  ;sta     KERNEL_ERRNO
  ;lda     #NULL
  ;rts

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

  beq     @exit_open_with_null

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


   ; Already set in _create_file_pointer
;  lda     #ENOMEM
 ; sta     KERNEL_ERRNO

  ; and Y equals to NULL
  lda     #NULL
  rts
@not_null_1:
  sta     KERNEL_XOPEN_PTR1
  sty     KERNEL_XOPEN_PTR1+1

@open_from_device:
  ldy     #_KERNEL_FILE::f_path ; skip /

  ; Reset flag to say that end of string is reached
  lda     #$01
  sta     XOPEN_SAVEA

 @next_filename:
  lda     #CH376_SET_FILE_NAME        ;$2F
  sta     CH376_COMMAND

@next_char:

  lda     (KERNEL_XOPEN_PTR1),y
  beq     @slash_found_or_end_of_string_stop
  cmp     #"/"
  beq     @slash_found_or_end_of_string
  cmp     #"a"                        ; 'a'
  bcc     @do_not_uppercase
  cmp     #"z"+1                        ; 'z'
  bcs     @do_not_uppercase
  sbc     #$1F
@do_not_uppercase:    
  sta     CH376_DATA
  iny
  cpy     #_KERNEL_FILE::f_path+KERNEL_MAX_PATH_LENGTH ; Max
  bne     @next_char
    ; error buffer overflow
  
  beq     @exit_open_with_null

@slash_found_or_end_of_string_stop:
  sta    XOPEN_SAVEA
  cpy    #_KERNEL_FILE::f_path+1  ; Do we reach $00 ? at the second char ? It means that it's '/' only
  beq    @open_and_register_fp
  bne    @S3

@slash_found_or_end_of_string:  
  ; do we reach / at the first char ? It should, then we enter 
  sta    XOPEN_SAVEA
  cpy    #_KERNEL_FILE::f_path
  bne    @S3
  sta    CH376_DATA

@S3:  

.IFPC02
.pc02
  stz     CH376_DATA ; INIT  
.p02  
.else  
  lda     #$00 ; used to write in BUFNOM
  sta     CH376_DATA ; INIT  
.endif

  sty     XOPEN_SAVEY
  jsr     _ch376_file_open
  cmp     #CH376_ERR_MISS_FILE
  beq     @file_not_found
  
  ldy     XOPEN_SAVEY ; reload Y
  lda     XOPEN_SAVEA
  beq     @could_be_created
  iny
  bne     @next_filename


 
@file_not_found:
  ; 

  lda     XOPEN_FLAGS ; Get flags
  cmp     #O_RDONLY
  bne     @could_be_created


@exit_open_with_null:

  lda     KERNEL_XOPEN_PTR1
  ldy     KERNEL_XOPEN_PTR1+1
  jsr     XFREE_ROUTINE
  ; No such file_or_directy
  lda     #ENOENT
  sta     KERNEL_ERRNO
  


  ; return null 
  ldy     #NULL
  lda     #NULL
  ldx     #NULL
  rts

@could_be_created:
  lda     XOPEN_FLAGS
  and     #O_WRONLY
  cmp     #O_WRONLY
  beq     @write_only
  ; not write
  bne     @open_and_register_fp 
@write_only  
  jsr     _ch376_file_create
@open_and_register_fp:


 ; register fp in process struct
  
  ;       store pointer in process struct
  ldx     kernel_process+kernel_process_struct::kernel_current_process

  ;kernel_process+kernel_process_struct
  lda     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_low,x
  sta     RES
  ;tya
  lda     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_high,x
  sta     RES+1

  ;Fill the address of the fp
  ; Manage only 1 FP for instance FIXME bug
  ldy     #kernel_one_process_struct::fp_ptr
@try_to_find_a_free_fp_for_current_process:
  lda     (RES),y
  bne     @fp_is_not_busy 
  tax
  iny
  lda     (RES),y
  bne     @fp_not_busy
  iny
  cpy     #KERNEL_MAX_FP_PER_PROCESS*2
  bne     @try_to_find_a_free_fp_for_current_process
  lda     #KERNEL_ERRNO_REACH_MAX_FP_FOR_A_PROCESS
  sta     KERNEL_ERRNO

  
  beq     @exit_open_with_null
  ;       
@fp_is_not_busy:
  lda     KERNEL_XOPEN_PTR1
  sta     (RES),y
  iny
  lda    KERNEL_XOPEN_PTR1
@fp_not_busy:
  sta     (RES),y
  ;kernel_process
  ;return fp

  lda     KERNEL_XOPEN_PTR1
  ldy     KERNEL_XOPEN_PTR1+1 
  ldx     KERNEL_XOPEN_PTR1+1 

  rts
.endproc
