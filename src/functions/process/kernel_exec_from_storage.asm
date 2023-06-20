; Calls XFREE

.proc kernel_try_to_find_command_in_bin_path
    .out     .sprintf("|MODIFY:RES:kernel_try_to_find_command_in_bin_path")
    .out     .sprintf("|MODIFY:RESB:kernel_try_to_find_command_in_bin_path")
    .out     .sprintf("|MODIFY:RESC:kernel_try_to_find_command_in_bin_path")
    .out     .sprintf("|MODIFY:RESD:kernel_try_to_find_command_in_bin_path")
    .out     .sprintf("|MODIFY:RESE:kernel_try_to_find_command_in_bin_path")
    .out     .sprintf("|MODIFY:RESF:kernel_try_to_find_command_in_bin_path")
    .out     .sprintf("|MODIFY:RESG:kernel_try_to_find_command_in_bin_path")
    .out     .sprintf("|MODIFY:RESH:kernel_try_to_find_command_in_bin_path")
    .out     .sprintf("|MODIFY:RESI:kernel_try_to_find_command_in_bin_path")
    .out     .sprintf("|MODIFY:PTR_READ_DEST:kernel_try_to_find_command_in_bin_path")


    ; A & Y contains the command
	; here we found no command, let's go trying to find it in /bin
    ; Malloc
    sta     RESG
    sty     RESG+1

    jsr     _XFORK

    lda     #$00
    sta     RESH ; Flag to say if XFREE must be performed

    lda     RESG
    sta     RES

    ldy     RESG+1
    sty     RES+1

    ldy     #$00
    lda     (RESG),y
    cmp     #'/'
    beq     @is_absolute
    cmp     #'.'
    beq     @is_relative

    lda     #$01
    sta     RESH ; Malloc performed


    jmp     @malloc_path

@is_relative:
    lda     RESG
    ldy     RESG+1
    jsr     compute_path_relative ; Use RESE
    sta     RESE
    sty     RESE+1

    ; Y contains the length of the final path
    jmp     @is_absolute_no_concat_bin

@is_absolute:
    lda     RESG
    sta     RESE
    lda     RESG+1
    sta     RESE+1
    ; place 0 when we reached a space

    ldy     #$00
; strcat of the command
@L20:
    lda     (RESG),y
    beq     @end30
    cmp     #' '
    beq     @end30
    iny
    bne     @L20
    ; now copy argv[0]
@end30:
    lda     #$00
    sta     (RESG),y

    jmp     @is_absolute_no_concat_bin


@malloc_path:
    jsr     kernel_exec_from_storage_malloc_path_store_RESE
    cpx     #$00 ; X=0 OK, else error
    beq     @malloc_ok
    rts

@malloc_ok:

    sta     RESC
    sty     RESC+1

@concat_bin:

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


@is_absolute_no_concat_bin:
open_binary_and_exec:

    ; At this step RES (only) can be used again

    ; At this step RESB contains the beginning of the string

    lda     RESE
    sta     RESC

    lda     RESE+1
    sta     RESC+1

@S1:
    ldy     #O_RDONLY
    lda     RESE            ; Path of the binary
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
    jmp     process_kill_and_exit

@not_null:
    sta     RESF       ; save fp
    stx     RESF+1     ; save fp

    ; When the command is an absolute path, the malloc for path had not been done, in that case, we did not call XFREE
    ldy     #$00
    lda     RESH
    beq     @is_absolute_no_free

    lda     RESE
    ldy     RESE+1

    jsr     XFREE_ROUTINE

@is_absolute_no_free:

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

    jsr     process_kill_and_exit
    ldy     #ENOMEM         ; Error

    rts


@not_null2:
    ; $0A05
    ; RESD contains pointer to header and the length is equal to the file to load
    sta     RESD
    sty     RESD+1 ; $842

    sta     PTR_READ_DEST
    sty     PTR_READ_DEST+1
    ; Save in order to compute nb_bytes_read
    sta     RESC
    sty     RESC+1

    ; save RESD
    ldx     kernel_process+kernel_process_struct::kernel_current_process

    jsr     kernel_get_struct_process_ptr

    sta     KERNEL_CREATE_PROCESS_PTR1
    sty     KERNEL_CREATE_PROCESS_PTR1+1

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

    ;save Y
    sty     RESI
    ; CLose fp used to load script
    lda     RESF     ; FP
    ldy     RESF+1
    jsr     XCLOSE_ROUTINE

    ; At this step RESF can be used

    ldy     RESI

    lda     RESD
    sta     RESI
    lda     RESD+1
    sta     RESI+1

    jmp     shebang_management


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
    jsr     kernel_get_struct_process_ptr
    sta     KERNEL_CREATE_PROCESS_PTR1
    sty     KERNEL_CREATE_PROCESS_PTR1+1

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
    jsr     process_kill_and_exit


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
    jmp     (RESE) ; jmp : it means that if program launched do an rts, it returns to interpreter

@read_program:
    lda     #$FF ; read all the binary
    ldy     #$FF
    ldx     RESF     ; FP

    jsr     XREADBYTES_ROUTINE

    ; FIXME return nb_bytes read malloc must be done

    ; FIXME 65C02 TXY

    pha
    txa
    tay
    pla


    rts



str_root_bin:
    ; If you change this path, you need to change .strlen("/bin/") above
    .asciiz "/bin/"


.endproc

.proc kernel_exec_from_storage_malloc_path_store_RESE

    lda     #<(.strlen("/bin/")+8+1+39) ; 8 for the length of the command, 1 for \0 39 for extra args
    ldy     #>(.strlen("/bin/")+8+1+39)

    jsr     XMALLOC_ROUTINE
    cmp     #NULL
    bne     @malloc_ok
    cpy     #NULL
    bne     @malloc_ok
    ldx     #$01 ; Error
    ldy     #ENOMEM
    sty     KERNEL_ERRNO

    rts
    ; FIX ME test OOM
@malloc_ok:
    ldx     #$00            ; OK
    ; $7B8
    ; $94D

    sta     RESE            ;  RESE contains the malloc /bin/path
    sty     RESE+1
    rts
.endproc

.proc shebang_management
    ; Let's read shebang
@check_space:
    iny
    cpy     #20
    beq     @format_unknown ; overflow
    ; read until we reach a char
    lda     (RESD),y ; fixme 65c02

    cmp     #$0A
    beq     @format_unknown               ; We found "#!           \n"
    cmp     #$0D
    beq     @format_unknown               ; We found "#!           \n"
    cmp     #' '
    beq     @check_space
    bne     @start_command_shebang

@start_command_shebang:
    tya
    clc
    adc     RESD
    bcc     @advance_ptr_resd
    inc     RESD+1

@advance_ptr_resd:
    sta     RESD
    sty     RESC ; Backup

    ; On alloue RESE
    jsr     kernel_exec_from_storage_malloc_path_store_RESE
    cpx     #$00
    beq     @malloc_shebang_ok
    rts

@format_unknown:
    lda     #$01
    rts

@malloc_shebang_ok:
    ; A cette etape on a RESE et on va copié dans RESE la commande après #!
    ldx     RESC

    ; Let's copy /bin/submit for example

    ldy     #$00
@loop:
    lda     (RESD),y
    cmp     #' '
    beq     @EOS
    cmp     #$0A
    beq     @EOS
    cmp     #$0D
    beq     @EOS
    sta     (RESE),y
    inx
    iny
    cpx     #19
    bne     @loop

@EOS:
    lda     #$00
    sta     (RESE),y
    ; A cette étape, RESE contient la commande à lancer ex : /bin/submit

    ; RESD Free here (and RESI)
    ; On désalloue RESI qui est juste le ptr RESD après malloc, avec cette opération on libère ces 2 offsets
    lda     RESI
    ldy     RESI+1 ; $842
    jsr     XFREE_ROUTINE

    ; Nous allons donc changer la ligne de commande pour écrire submit + le processname

    ; On calcule le ptr de la structure du process
    ldx     kernel_process+kernel_process_struct::kernel_current_process

    jsr     kernel_get_struct_process_ptr

    sta     KERNEL_CREATE_PROCESS_PTR1
    sty     KERNEL_CREATE_PROCESS_PTR1+1

    lda     KERNEL_CREATE_PROCESS_PTR1
    clc
    adc     #kernel_one_process_struct::cmdline
    bcc     @S7
    inc     KERNEL_CREATE_PROCESS_PTR1+1
@S7:
    sta     KERNEL_CREATE_PROCESS_PTR1

    ; Cmdline normale : ./a
    ; processname : a

    ; pour que submit puisse récupérer les paramètres, il faut qu'il soit dans cmdline
    ; ex :
    ; submit a.sub

;     On copie le shebang

    lda     KERNEL_CREATE_PROCESS_PTR1
    sta     RESCONCAT
    lda     KERNEL_CREATE_PROCESS_PTR1+1
    sta     RESCONCAT+1

    lda     RESE
    ldy     RESE+1
    jsr     kernel_concat_from_RESB_to_RESCONCAT

;     ; Puis on ajouter un espace pour avoir "/bin/submit|_|""

    lda     #' '
    sta     (RESCONCAT),y
    iny
    lda     #'/'
    sta     (RESCONCAT),y
    iny
    tya
    clc
    adc     RESCONCAT
    bcc     @S100
    inc     RESCONCAT+1
@S100:
    sta     RESCONCAT

    ; On copie le commande lancée
    lda     #<str_bin
    ldy     #>str_bin
    jsr     kernel_concat_from_RESB_to_RESCONCAT

    lda     #'/'
    sta     (RESCONCAT),y

    iny
    tya
    clc
    adc     RESCONCAT
    bcc     @S10000
    inc     RESCONCAT+1
@S10000:
    sta     RESCONCAT


    lda     RESG
    ldy     RESG+1
    jsr     kernel_concat_from_RESB_to_RESCONCAT

; ; For debug

    ldx     kernel_process+kernel_process_struct::kernel_current_process

    jsr     kernel_get_struct_process_ptr

    sta     KERNEL_CREATE_PROCESS_PTR1
    sty     KERNEL_CREATE_PROCESS_PTR1+1

    lda     KERNEL_CREATE_PROCESS_PTR1
    clc
    adc     #kernel_one_process_struct::cmdline
    bcc     @S70
    inc     KERNEL_CREATE_PROCESS_PTR1+1
@S70:
    sta     KERNEL_CREATE_PROCESS_PTR1


    ; Display debug
    ldy     #$00
@ME:
    lda     (KERNEL_CREATE_PROCESS_PTR1),y
    beq     @exit_me
    sta     $bb80,y
    iny
    bne     @ME

@exit_me:
    jmp     kernel_try_to_find_command_in_bin_path::open_binary_and_exec

str_bin:
    .asciiz "bin"
.endproc

.proc process_kill_and_exit

    lda     kernel_process+kernel_process_struct::kernel_current_process
    jsr     kernel_kill_process

    lda     KERNEL_ERRNO
    ldy     #ENOENT
    ; Error not found
    rts
.endproc

.proc kernel_concat_from_RESB_to_RESCONCAT
    sta     RESB
    sty     RESB+1

    ldy     #$00

@L110:
    lda     (RESB),y
    beq     @S800
    sta     (RESCONCAT),y
    iny
    bne     @L110

@S800:
    sta     (RESCONCAT),y
    rts
.endproc
