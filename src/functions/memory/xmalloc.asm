.export XMALLOC_ROUTINE

.proc XMALLOC_ROUTINE

    ;;@brief Perform a malloc in the kernel memory space (48K). Return NULL if no memory available
    ;;@inputA contains the low byte of the length to allocate
    ;;@inputX contains the high nbyte of the length to allocate
    ;;@modifyMEM_TR6
    ;;@modifyMEM_TR7
    ;;@```asm
    ;;@` lda #<5
    ;;@` ldy #>5
    ;;@` BRK_TELEMON XMALLOC
    ;;@` rts
    ;;@```


; $fb64

.out     .sprintf("|MODIFY:TR7:XMALLOC_ROUTINE")
.out     .sprintf("|MODIFY:KERNEL_ERRNO:XMALLOC_ROUTINE")

; IN [A & Y ] the length requested
;
; TR7 is modified
; OUT : NULL in A & Y or pointer in A & Y of the first byte of the allocated memory
; Don't use RES or RESB in this routine, if it's used, it affects kernel_create_process routine and kernel_try_to_find_command_in_bin_path
; Verify if there is enough memory
;

    ; Does High value of the number of the malloc is greater than the free memory ?
    cpy     kernel_malloc_free_chunk_size + kernel_malloc_free_chunk_size_struct::kernel_malloc_free_chunk_size_high
    bcc     @allocate

    ; If yes, then we have no memory left, return NULL
@exit_null:
    ; we don't fix #ENOMEM, because null is returned already means OOM by default
    lda     #ENOMEM
    sta     KERNEL_ERRNO

    lda     #NULL
    ldy     #NULL

    rts

@allocate:
    ; found first available busy table
    sta     TR7                                  ; Save A (low value of the malloc), Y is not saved because we don't modify it
    sty     TR6                                  ; Save Y (high value of the malloc)

    ldx     #$00

@looking_for_busy_chunck_available:
    ; Try to find a place to set the pid value
    lda     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_pid_list,x
    ;cmp     #$FF ; UNCOMMENT MAX_PROCESS
    beq     @found
    inx
    cpx     #KERNEL_MAX_NUMBER_OF_MALLOC
    beq     @exit_null
    bne     @looking_for_busy_chunck_available

@found:
    ; X contains the PID position to keep PID of the current malloc
    ; TR6 contains the high byte of the size to allocate
    ; TR7 contains the low byte of the size to allocate
    ; Trying to look if we have free slot available which is not used
    ldy     #$01

@looking_for_free_chunk_available:

    lda     kernel_malloc + kernel_malloc_struct::kernel_malloc_free_chunk_begin_high,y ; Check if begin high is busy, if it's zero, this slot is not used
    beq     @is_greater ; os isedwe check next free chunk

    lda     kernel_malloc_free_chunk_size + kernel_malloc_free_chunk_size_struct::kernel_malloc_free_chunk_size_high,y ;
    cmp     TR6 ; check high byte of the size to allocate
    bcc     @is_greater ; if freater than size (high byte), we can not use this chunk
    ; Check low now
    lda     kernel_malloc_free_chunk_size + kernel_malloc_free_chunk_size_struct::kernel_malloc_free_chunk_size_low,y ;
    cmp     TR7 ; Low
    bcc     @is_greater ; if greater or equal than size (low byte),
    ; we can use this chunk, here we go, change it to busy chunk
    lda     TR7 ; get low byte of size (store the size)
    sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_size_low,x

    ;lda     kernel_malloc_free_chunk_size + kernel_malloc_free_chunk_size_struct::kernel_malloc_free_chunk_size_high,y
    lda     TR6
    sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_size_high,x

    lda     kernel_malloc + kernel_malloc_struct::kernel_malloc_free_chunk_begin_low,y
    sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_begin_low,x

    lda     kernel_malloc + kernel_malloc_struct::kernel_malloc_free_chunk_begin_high,y
    sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_begin_high,x

    lda     kernel_malloc + kernel_malloc_struct::kernel_malloc_free_chunk_end_low,y
    sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_end_low,x

    lda     kernel_malloc + kernel_malloc_struct::kernel_malloc_free_chunk_end_high,y
    sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_end_high,x

    ; Free slot now
    lda     #$00
    sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_free_chunk_begin_high,y
    jmp     @return_pointer

    ; lda     kernel_malloc_free_chunk_size + kernel_malloc_free_chunk_size_struct::kernel_malloc_free_chunk_size_high,y
    ; sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_size_high,x

    ; lda     kernel_malloc + kernel_malloc_struct::kernel_malloc_free_chunk_begin_low,y
    ; sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_begin_low,x

    ; lda     kernel_malloc + kernel_malloc_struct::kernel_malloc_free_chunk_begin_high,y
    ; sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_begin_high,x

    ; lda     kernel_malloc + kernel_malloc_struct::kernel_malloc_free_chunk_end_low,y
    ; sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_end_low,x

    ; lda     kernel_malloc + kernel_malloc_struct::kernel_malloc_free_chunk_end_high,y


@is_greater:
    iny
    cpy     #KERNEL_MALLOC_FREE_CHUNK_MAX
    bne     @looking_for_free_chunk_available


@malloc_from_first_free_chunk_main_memory:
    lda     TR7 ; get low byte of size (store the size)
    ; Store the size in the busy table
    sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_size_low,x
    lda     TR6
   ; tya     ; Get high byte of the size and store
    sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_size_high,x  ; store the length (low)

    lda     kernel_malloc + kernel_malloc_struct::kernel_malloc_free_chunk_begin_high
    sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_begin_high,x
    sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_end_high,x

    lda     kernel_malloc + kernel_malloc_struct::kernel_malloc_free_chunk_begin_low
    sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_begin_low,x
    sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_end_low,x

    ; Compute the end of the busy address
    clc
    adc     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_size_low,x
    bcc     @skip2
    inc     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_end_high,x
 @skip2:
    sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_end_low,x

    sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_free_chunk_begin_low                ; update of the next chunk available

    lda     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_size_high,x
    clc
    adc     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_end_high,x
    ; FIXME for 32 bits mode in the future
    sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_end_high,x
    sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_free_chunk_begin_high

    ; update now the memory available in the chunk memory free
;
    lda     kernel_malloc_free_chunk_size + kernel_malloc_free_chunk_size_struct::kernel_malloc_free_chunk_size_low ; $566 $BE $45 $30
    sec
    sbc     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_size_low,x ; X=3 X=4 $24 $EB
    bcs     @skip3
    dec     kernel_malloc_free_chunk_size + kernel_malloc_free_chunk_size_struct::kernel_malloc_free_chunk_size_high ; $561
@skip3:
    sta     kernel_malloc_free_chunk_size + kernel_malloc_free_chunk_size_struct::kernel_malloc_free_chunk_size_low ; $45 $24

    lda     kernel_malloc_free_chunk_size + kernel_malloc_free_chunk_size_struct::kernel_malloc_free_chunk_size_high ; $561 $84 $84
    sec
    sbc     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_size_high,x ; $557 X=3

    ; FIXME 32 bits
    sta     kernel_malloc_free_chunk_size + kernel_malloc_free_chunk_size_struct::kernel_malloc_free_chunk_size_high ; $84 ; $84

    ; Ok now inc the next free memory offset
    inc     kernel_malloc + kernel_malloc_struct::kernel_malloc_free_chunk_begin_low
    bne     @skip4
    inc     kernel_malloc + kernel_malloc_struct::kernel_malloc_free_chunk_begin_high

@return_pointer:
@skip4:
    lda     kernel_process + kernel_process_struct::kernel_current_process
@store:
    sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_pid_list,x


    ; Debug


    lda     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_begin_low,x
    ldy     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_begin_high,x
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
