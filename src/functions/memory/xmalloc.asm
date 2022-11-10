
.export XMALLOC_ROUTINE

.proc XMALLOC_ROUTINE

.out     .sprintf("|MODIFY:TR7:XMALLOC_ROUTINE")
.out     .sprintf("|MODIFY:KERNEL_ERRNO:XMALLOC_ROUTINE")


; IN [A & Y ] the length requested
;
; TR7 is modified
; OUT : NULL in A & Y or pointer in A & Y of the first byte of the allocated memory
; Don't use RES or RESB in this routine, if it's used, it affects kernel_create_process routine and kernel_try_to_find_command_in_bin_path
; Verify if there is enough memory
;



.ifdef WITH_DEBUG
    jsr     kdebug_save

    ldx     #XDEBUG_XMALLOC_ENTER_AY

    jsr     xdebug_print_with_ay

    ldx     #XDEBUG_TYPE
    jsr     xdebug_print


    lda     KERNEL_MALLOC_TYPE
    cmp     #KERNEL_PROCESS_STRUCT_MALLOC_TYPE
    bne     @O2
    ldx     #XDEBUG_TYPE_PROCESSSTRUCT
    jsr     xdebug_print
    jmp     @O1
@O2:
    cmp     #KERNEL_UNKNOWN_MALLOC_TYPE
    bne     @O4
    ldx     #XDEBUG_UNKNOWN
    jsr     xdebug_print

    jmp     @O1
@O4:
    cmp     #KERNEL_XMAINARG_MALLOC_TYPE
    bne     @O3
    ldx     #XDEBUG_TYPE_MAINARGS
    jsr     xdebug_print
    jmp     @O1
@O3:
    cmp     #KERNEL_FP_MALLOC_TYPE
    bne     @O5
    ldx     #XDEBUG_TYPE_FPSTRUCT
    jsr     xdebug_print
    jmp     @O1
@O5:
    ; others
@O1:
    jsr     kdebug_restore
.endif

    cpy     kernel_malloc_free_chunk_size+kernel_malloc_free_chunk_size_struct::kernel_malloc_free_chunk_size_high     ; Does High value of the number of the malloc is greater than the free memory ?
    bcc     @allocate

@exit_null:                                      ; If yes, then we have no memory left, return NULL
    ; we don't fix #ENOMEM, because null is returned already means OOM by default


    lda     #ENOMEM
    sta     KERNEL_ERRNO

    lda     #NULL
    ldy     #NULL


    rts
@allocate:

    ; found first available busy table
    sta     TR7                                  ; Save A (low value of the malloc), Y is not saved because we don't modify it

    ldx     #$00

@looking_for_busy_chunck_available:
    ; Try to find a place to set the pid value
    lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_pid_list,x
    ;cmp     #$FF ; UNCOMMENT MAX_PROCESS
    beq     @found
    inx
    cpx     #KERNEL_MAX_NUMBER_OF_MALLOC
    beq     @exit_null
    bne     @looking_for_busy_chunck_available

@found:

    lda     TR7 ; get low byte of size (store the size)
    ; Store the size in the busy table
    sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_low,x

    tya     ; Get high byte of the size and store
    sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_high,x  ; store the length (low)

    lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_high

    sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_high,x
    sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_high,x


    lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_low
    sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_low,x
    sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_low,x


    ; Compute the end of the busy address
    clc
    adc     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_low,x
    bcc     @skip2
    inc     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_high,x
 @skip2:
    sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_low,x

    sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_low                ; update of the next chunk available

    lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_high,x
    clc
    adc     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_high,x
    ; FIXME for 32 bits mode in the future
    sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_high,x

    sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_high

    ; update now the memory available in the chunk memory free


;
    lda     kernel_malloc_free_chunk_size+kernel_malloc_free_chunk_size_struct::kernel_malloc_free_chunk_size_low ; $566 $BE $45 $30
    sec
    sbc     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_low,x ; X=3 X=4 $24 $EB
    bcs     @skip3
    dec     kernel_malloc_free_chunk_size+kernel_malloc_free_chunk_size_struct::kernel_malloc_free_chunk_size_high ; $561
@skip3:
    sta     kernel_malloc_free_chunk_size+kernel_malloc_free_chunk_size_struct::kernel_malloc_free_chunk_size_low ; $45 $24

    lda     kernel_malloc_free_chunk_size+kernel_malloc_free_chunk_size_struct::kernel_malloc_free_chunk_size_high ; $561 $84 $84
    sec
    sbc     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_high,x ; $557 X=3

    ; FIXME 32 bits
    sta     kernel_malloc_free_chunk_size+kernel_malloc_free_chunk_size_struct::kernel_malloc_free_chunk_size_high ; $84 ; $84

    ; Ok now inc the next free memory offset
    inc     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_low
    bne     @skip4
    inc     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_high
@skip4:

  ;  lda     KERNEL_MALLOC_TYPE
   ; sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_type,x


    lda     kernel_process+kernel_process_struct::kernel_current_process
@store:
    sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_pid_list,x


    ; Restore type

    lda     #KERNEL_UNKNOWN_MALLOC_TYPE
    sta     KERNEL_MALLOC_TYPE

    ; Debug

.ifdef WITH_DEBUG
    jsr     kdebug_save

    lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_low,x
    ldy     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_high,x

    ldx     #3

    jsr     xdebug_print_with_ay

    jsr     kdebug_restore
.endif
    lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_low,x
    ldy     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_high,x
    rts
.endproc

_print_hexa:
    pha
    lda     #'#'
    jsr     XWR0_ROUTINE
    pla

    jsr     XHEXA_ROUTINE
    sty     TR7

    jsr     XWR0_ROUTINE
    lda     TR7
    jsr     XWR0_ROUTINE
    rts



_print_hexa_no_sharp:


    jsr     XHEXA_ROUTINE
    sty     TR7

    jsr     XWR0_ROUTINE
    lda     TR7
    jsr     XWR0_ROUTINE
    rts
