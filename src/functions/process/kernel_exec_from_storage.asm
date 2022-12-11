;DEBUG_EXEC_FROM_STORAGE=1



; Calls XFREE


.proc kernel_try_to_find_command_in_bin_path
    .out     .sprintf("|MODIFY:RES:kernel_try_to_find_command_in_bin_path")
    .out     .sprintf("|MODIFY:RESB:kernel_try_to_find_command_in_bin_path")
    .out     .sprintf("|MODIFY:RESC:kernel_try_to_find_command_in_bin_path")
    .out     .sprintf("|MODIFY:RESD:kernel_try_to_find_command_in_bin_path")
    .out     .sprintf("|MODIFY:RESE:kernel_try_to_find_command_in_bin_path")
    .out     .sprintf("|MODIFY:RESF:kernel_try_to_find_command_in_bin_path")
    .out     .sprintf("|MODIFY:PTR_READ_DEST:kernel_try_to_find_command_in_bin_path")
    .out     .sprintf("|MODIFY:RESG:kernel_try_to_find_command_in_bin_path")

    ; A & Y contains the command
	; here we found no command, let's go trying to find it in /bin
    ; Malloc
    sta     RESG
    sty     RESG+1

    jsr     _XFORK

.ifdef DEBUG_EXEC_FROM_STORAGE
    lda     #'A'
    sta     $bb80+126
.endif

    lda     RESG
    sta     RES

    ldy     RESG+1
    sty     RES+1

    lda     #<(.strlen("/bin/")+8+1) ; 5 because /bin/ & 8 because length can't be greater than 8 for the command
    ldy     #>(.strlen("/bin/")+8+1)
    jsr     XMALLOC_ROUTINE
    cmp     #NULL
    bne     @malloc_ok
    cpy     #NULL
    bne     @malloc_ok
    ldy     #ENOMEM
    sty     KERNEL_ERRNO

    rts
    ; FIX ME test OOM
@malloc_ok:

    sta     RESE
    sty     RESE+1

    sta     RESC
    sty     RESC+1


    ; Copy /bin
    ; Do a strcat
    ldy     #$00
@L1:
    lda     str_root_bin,y

    beq     @end
    sta     (RESC),y
    iny
    cpy     #.strlen("/bin/")
    bne     @L1


@end:
    tya
    clc
    adc     RESC
    bcc     @S20
    inc     RESC+1
@S20:
    sta     RESC

    ldy     #$00
; strcat of the command
@L2:
    lda     (RES),y
    beq     @end2
    cmp     #' '
    beq     @end2
    sta     (RESC),y
    iny
    cpy     #$08
    bne     @L2
    ; now copy argv[0]
@end2:
    lda     #$00
    sta     (RESC),y

    ; At this step RES (only) can be used again

    ; At this step RESB contains the beginning of the string

    lda     RESE
    sta     RESC
    lda     RESE+1
    sta     RESC+1

@out:
    ldy     #$00
@L5:
    lda     (RESE),y
    beq     @S1

    iny
    bne     @L5


@S1:

.ifdef DEBUG_EXEC_FROM_STORAGE
    lda     #$12
    sta     $bb80+121
.endif

    ldy     #O_RDONLY
    lda     RESE
    ldx     RESE+1
    jsr     XOPEN_ROUTINE

    cpx     #$FF
    bne     @not_null

    cmp     #$FF
    bne     @not_null

    ; Free string used for the strcat
    lda     RESE
    ldy     RESE+1
    jsr     XFREE_ROUTINE

@kill_and_exit:

    lda     kernel_process+kernel_process_struct::kernel_current_process
    jsr     kernel_kill_process

    lda     KERNEL_ERRNO
    ldy     #ENOENT
    ; Error not found


    rts
@not_null:

    sta     RESF       ; save fp
    stx     RESF+1     ; save fp

    lda     RESE
    ldy     RESE+1

    jsr     XFREE_ROUTINE

    ; Found let's fork

    ; RESC contains file pointer
    ; RES can be used
    ; RESB too


    ; Get length of the file
    lda     #CH376_GET_FILE_SIZE
    sta     CH376_COMMAND
    lda     #$68
    sta     CH376_DATA ; ????
    ; store file length
    lda     CH376_DATA
    ldy     CH376_DATA
    iny                 ; Add 256 bytes because reloc files (version 2 and 3) will be aligned to a page

    ; $543
.ifdef DEBUG_EXEC_FROM_STORAGE
    lda     #$13
    sta     $bb80+122
.endif

    ; drop others values
    ldx     CH376_DATA
    ldx     CH376_DATA
    ; Allocate the size of the binary + 256
    jsr     XMALLOC_ROUTINE

    cmp     #NULL
    bne     @not_null2

    cpy     #NULL
    bne     @not_null2


@out_not_found:
    lda     RESF
    ldy     RESF+1

    jsr     XCLOSE_ROUTINE

    jsr     @kill_and_exit
    ldy     #ENOMEM         ; Error

    rts


@not_null2:

    ; $0A05
  ;   RESD contains pointer to header and the length is equal to the file to load
    sta     RESD
    sty     RESD+1 ; $842


    sta     PTR_READ_DEST
    sty     PTR_READ_DEST+1
    ; Save in order to compute nb_bytes_read
    sta     RESC
    sty     RESC+1

    ; save RESD


    ldx     kernel_process+kernel_process_struct::kernel_current_process
    lda     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_low,x
    sta     KERNEL_CREATE_PROCESS_PTR1
    lda     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_high,x
    sta     KERNEL_CREATE_PROCESS_PTR1+1

    ldy     #kernel_one_process_struct::kernel_process_addr
    lda     RESD
    sta     (KERNEL_CREATE_PROCESS_PTR1),y ; $741
    iny
    lda     RESD+1
    sta     (KERNEL_CREATE_PROCESS_PTR1),y



    ; Read 20 bytes in the header

    lda     #20
    ldy     #$00
    ldx     RESF     ; FP

    jsr     XREADBYTES_ROUTINE

.ifdef DEBUG_EXEC_FROM_STORAGE
    lda     #$14
    sta     $bb80+123
.endif

    ldy     #$00
    lda     (RESD),y ; fixme 65c02

    cmp     #$01
    beq     @is_an_orix_file

    ; Check if it's a shebang
    cmp     #'#'
    bne     @format_unknown

    iny
    lda     (RESD),y ; fixme 65c02
    cmp     #'!'
    bne     @format_unknown
    ; Shebang here

@format_unknown:
; Don't know the format
    ldy     #ENOEXEC
    rts

@is_an_orix_file:
    ; Checking version

  	; Switch off cursor
    ldx     #$00
    jsr     XCOSCR_ROUTINE

    lda     #$02
    cmp     #'X'                ; X is a magic token in order to have a binary which will always start in static mode
    beq     @static_file

    ldy     #$05                ; Get binary version
    lda     (RESD),y
    cmp     #$01                ; Binary version, it's not a relocatable binary
    beq     @static_file
    cmp     #$02
    beq     @relocate_ORI2
    ldy     #ENOEXEC
    sty     KERNEL_ERRNO
    rts
@free:
    lda     RESD
    ldy     RESD+1
    jsr     XFREE_ROUTINE

    lda     RESF
    ldy     RESF+1
    jsr     XCLOSE_ROUTINE

    jmp     @kill_and_exit

@relocate_ORI2:
    jsr     compute_all_offset_ORI2

    jsr     @read_program

    jsr     relocate_ORI2

    ; Now get the execution address

    ldx     kernel_process+kernel_process_struct::kernel_current_process
    lda     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_low,x
    sta     KERNEL_CREATE_PROCESS_PTR1
    lda     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_high,x
    sta     KERNEL_CREATE_PROCESS_PTR1+1



    ldy     #kernel_one_process_struct::kernel_process_addr
    lda     (KERNEL_CREATE_PROCESS_PTR1),y
    sta     RESE
    iny
    lda     (KERNEL_CREATE_PROCESS_PTR1),y
    sta     RESE+1


;
    jmp     @run

; Format 1 : static adress
@static_file:

    ldy     #15             ; Get the loading address
    lda     (RESD),y        ; fixme 65c02
    sta     PTR_READ_DEST+1 ; 08

@continue_loading:

    ldy     #14         ; Get loading low offset
    lda     (RESD),y ; fixme 65c02
    sta     PTR_READ_DEST

    ; init RES to start code

    ldy     #18
    lda     (RESD),y ; fixme 65c02
    sta     RESE

    ldy     #19
    lda     (RESD),y ; fixme 65c02
    sta     RESE+1

    ; Checking if RESD is equal or below than the loading address

    ldy     #15
    lda     (RESD),y   ; Does high byte for malloc ptr is  $08
    cmp     RESD+1     ; greater than the loading adress $7f
    bcc     @error     ; Yes error, can't not start
    bcs     @start_to_read
    ; it's equal
@continue:
    ldy     #14
    lda     (RESD),y    ; Does high byte for malloc ptr is $7f
    cmp     RESD        ; greater than the loading adress
    bcc     @error
@start_to_read:
    jsr     @read_program


@run:
    jsr     @clean_before_execute
.ifdef DEBUG_EXEC_FROM_STORAGE
    lda     #$11
    sta     $bb80+120
.endif
    jsr     @execute

    pha     ; Save return code $91e

    ldy     #kernel_one_process_struct::kernel_process_addr
    lda     (KERNEL_CREATE_PROCESS_PTR1),y
    sta     RESD
    iny
    lda     (KERNEL_CREATE_PROCESS_PTR1),y
    sta     RESD+1
    ; free the length of the binary
    lda     RESD
    ldy     RESD+1
    jsr     XFREE_ROUTINE

    ldy     #EOK
    pla     ; get return code
    rts
@error:
    ; free the length of the binary
    lda     RESD
    ldy     RESD+1
    jsr     XFREE_ROUTINE
    jsr     @kill_and_exit
    ldy     #ENOEXEC   ; Return format error
    rts

@clean_before_execute:
    ; save RES
    lda     RES
    ldy     RES+1

    sta     RESG
    sty     RESG+1

    ; send cmdline ptr

    lda     RESF
    ldy     RESF+1
    jsr     XCLOSE_ROUTINE

    lda     RESG
    ldy     RESG+1
    rts

@execute:
    ;jmp     @execute
    jmp     (RESE) ; jmp : it means that if program launched do an rts, it returns to interpreter

@read_program:
    lda     #$FF ; read all the binary
    ldy     #$FF
    ldx     RESF     ; FP

    jsr     XREADBYTES_ROUTINE
    ; $52F

    ; FIXME return nb_bytes read malloc must be done
    pha
    txa
    tay
    pla
; @me:
;     jmp     @me
    ; lda     PTR_READ_DEST+1
    ; sec
    ; sbc     RESC+1
    ; tay
    ; lda     PTR_READ_DEST
    ; sec
    ; sbc     RES
    ; A and Y contains the length of the file

    ; Save length of the file


    rts


str_root_bin:
    ; If you change this path, you need to change .strlen("/bin/") above
    .asciiz "/bin/"
.endproc
