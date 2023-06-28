.proc compute_path_relative
    ; Enter : A and Y contains the ptr with the path
    ; returns : X the length
    ; Modified : ptr in A and Y will be fill with absolute path
    .out     .sprintf("|MODIFY:RESB:compute_path_relative")
    .out     .sprintf("|MODIFY:RESC:compute_path_relative")
    .out     .sprintf("|MODIFY:RESD:compute_path_relative")
    .out     .sprintf("|MODIFY:RESE:compute_path_relative")
    .out     .sprintf("|MODIFY:RESF:compute_path_relative")

    sta     RESE
    sty     RESE+1

    ; Checking if ./
    ldy     #$01 ; We are looking if it's ./
    lda     (RESE),y
    cmp     #'/'
    beq     @it_s_dot_slash
    cmp     #'.'
    beq     @it_s_dot_dot_slash
@error_relative:
    ldx     #$01 ; Error
    rts

@it_s_dot_dot_slash:
    ; Trying to resolve
    ldx     #$00 ; First ../

    ldy     #$02
    lda     (RESE),y
    cmp     #'/'
    beq     @ok_dot_dot_slash_found ; ../ found
    bne     @error_relative

@ok_dot_dot_slash_found:
    iny
    lda     (RESE),y
    cmp     #'.'
    beq     @is_dot
    bne     @stop_relative_compute
@is_dot:
    iny
    lda     (RESE),y
    cmp     #'.'
    beq     @is_dot_dot
    bne     @error_relative
@is_dot_dot:
    inx
    iny
    lda     (RESE),y
    cmp     #'/'
    beq     @ok_dot_dot_slash_found
    bne     @error_relative

@stop_relative_compute:
    stx     RESD        ; Contains the number of "../"

    jsr     get_xgetcwd_and_store_to_RESC
    ; Goes to EOS
    ldx     #$00
    ldy     #$00
@loop_str:
    lda     (RESC),y
    beq     @eos_found
    cmp     #'/' ; Count number of  "/"
    bne     @not_slash
    inx

@not_slash:
    iny
    bne     @loop_str
@eos_found:
    ; Check if we have more "/" or equal than "../"
    txa
    cmp     RESD
    bcc     @relative_is_ok
    jmp     @error_relative


@relative_is_ok:

    rts

@it_s_dot_slash:
    ; Compute STR

    jsr     get_xgetcwd_and_store_to_RESC


    ldx     kernel_process+kernel_process_struct::kernel_current_process
    jsr     kernel_get_struct_process_ptr
    sta     RESD
    sty     RESD+1

    lda     #kernel_one_process_struct::cmdline
    clc
    adc     RESD
    bcc     @S1
    inc     RESD+1
@S1:
    sta     RESD

    ; Now RESD is the ptr of cmdline process
    ldy     #$00
@L1:
    lda     (RESC),y
    beq     @strcpy_end
    sta     (RESD),y

    iny
    bne     @L1

@strcpy_end:
    lda     #'/'
    sta     (RESD),y

    iny
    sty     RESF ; Backup position for cmdline

    ldy     #$02
    sty     RESF+1 ; backup position for string to copy

@copy:

    ldy     RESF+1
    lda     (RESE),y
    beq     @out2

    inc     RESF+1
    ldy     RESF
    cpy     #KERNEL_LENGTH_MAX_CMDLINE
    beq     @out2
    sta     (RESD),y

    inc     RESF
    jmp     @copy

@out2:
    ; Store 0

    ldy     RESF
    lda     #$00
    sta     (RESD),y

    iny
    tya
    ldy     #$00

    jsr     XMALLOC_ROUTINE
    cmp     #NULL
    bne     @malloc_ok
    cpy     #NULL
    bne     @malloc_ok
    ldy     #ENOMEM
    sty     KERNEL_ERRNO
    ldx     #$01 ; Error
    rts

@malloc_ok:
    ; Now copy
    sta     RESF
    sty     RESF+1

    ldy     #$00

@L100:
    lda     (RESD),y
    beq     @strcpy2_end
    cmp     #' '
    beq     @strcpy2_end
    sta     (RESF),y

    iny
    bne     @L100
@strcpy2_end:

    lda     #$00
    sta     (RESF),y

    lda     #$01
    sta     RESH ; Malloc is done

    lda     RESF
    ldy     RESF+1

    ; A contains the compute
    rts

.endproc

.proc get_xgetcwd_and_store_to_RESC
    jsr     XGETCWD_ROUTINE ; Use RESB

    ; Store cwd ptr into RESC
    sta     RESC
    sty     RESC+1
    rts
.endproc
