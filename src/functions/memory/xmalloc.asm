
.export XMALLOC_ROUTINE

.proc XMALLOC_ROUTINE

; IN [A & Y ] the length requested
; TR7 is modified
; OUT : NULL in A & Y or pointer in A & Y of the first byte of the allocated memory
; Don't use RES or RESB in this routine, if it's used, it affects kernel_create_process routine and kernel_try_to_find_command_in_bin_path
; Verify if there is enough memory
; 
.ifdef WITH_DEBUG
 ;   jsr     xdebug_enter_XMALLOC
  ;  jsr     xdebug_send_ay_to_printer
.endif
    cpy     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high     ; Does High value of the number of the malloc is greater than the free memory ?
    bcc     @allocate                             
@exit_null:                                      ; If yes, then we have no memory left, return NULL
    ; we don't fix #ENOMEM, because null is returned already means OOM by default
.ifdef WITH_DEBUG
    ;jsr     xdebug_end
.endif
    lda     #NULL
    ldy     #NULL


    rts
@allocate:

    ; found first available busy table
    ldx     #$00
    sta     TR7                                  ; Save A (low value of the malloc), Y is not saved because we don't modify it
 
@looking_for_busy_chunck_available:
    ; Try to find a place to set the pid value
    lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_pid_list,x
    beq     @found
    inx 
    cpx     #KERNEL_MAX_NUMBER_OF_MALLOC
    beq     @exit_null 
    bne     @looking_for_busy_chunck_available

@found:
.ifdef WITH_DEBUG
    ; Send id_free_chunk
 ;   jsr     xdebug_send_x_to_printer
.endif
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
    
    lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_low
    sec
    sbc     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_low,x
    bcs     @skip3
    dec     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high
@skip3:
    sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_low
    
    lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high
    sec
    sbc     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_high,x

    ; FIXME 32 bits
    sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high
    
    ; Ok now inc the next free memory offset 
    inc     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_low
    bne     @skip4
    inc     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_high
@skip4:
    
    ; register process in malloc table 
    lda     kernel_process+kernel_process_struct::kernel_current_process
    sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_pid_list,x
    
.ifdef WITH_DEBUG
    ;jsr     xdebug_send_ay_to_printer
    ;jsr     xdebug_end
.endif

    lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_low,x
    ldy     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_high,x

    
    rts
.endproc

