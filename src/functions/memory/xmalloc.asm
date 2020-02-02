
.export XMALLOC_ROUTINE

.proc XMALLOC_ROUTINE

; IN [A & Y ] the length requested
; TR7 is modified
; OUT : NULL in A & Y or pointer in A & Y of the first byte of the allocated memory
; Don't use RES or RESB in this routine, if it's used, it affects kernel_create_process routine
; Verify if there is enough memory
; 
.ifdef WITH_DEBUG
    jsr     xdebug_enter_XMALLOC
    jsr     xdebug_send_ay_to_printer
.endif
    cpy     ORIX_MALLOC_FREE_SIZE_HIGH_TABLE     ; Does High value of the number of the malloc is greater than the free memory ?
    bcc     @allocate                             
@exit_null:                                      ; If yes, then we have no memory left, return NULL
    ; we don't fix #ENOMEM, because null return already means OOM by default
.ifdef WITH_DEBUG
    jsr     xdebug_end
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
    lda     TR7
    sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_low,x
    sta     ORIX_MALLOC_BUSY_TABLE_SIZE_LOW,x     ; store the length of the busy chunk
    tya
    sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_high,x
    sta     ORIX_MALLOC_BUSY_TABLE_SIZE_HIGH,x    ; store the length (low)
    
    lda     ORIX_MALLOC_FREE_BEGIN_HIGH_TABLE
    sta     ORIX_MALLOC_BUSY_TABLE_BEGIN_HIGH,x   ; to compute High adress
    sta     ORIX_MALLOC_BUSY_TABLE_END_HIGH,x     ; to compute High adress
    
    
    lda     ORIX_MALLOC_FREE_BEGIN_LOW_TABLE      ; get the first offset
    sta     ORIX_MALLOC_BUSY_TABLE_BEGIN_LOW,x    ; and save it
    sta     ORIX_MALLOC_BUSY_TABLE_END_LOW,x
    clc
    adc     ORIX_MALLOC_BUSY_TABLE_SIZE_LOW,x
    bcc     @skip2
    inc     ORIX_MALLOC_BUSY_TABLE_END_HIGH,x
 @skip2:
    sta     ORIX_MALLOC_BUSY_TABLE_END_LOW,x
  
    sta     ORIX_MALLOC_FREE_BEGIN_LOW_TABLE                ; update of the next chunk available
    
    lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_high,x
    lda     ORIX_MALLOC_BUSY_TABLE_SIZE_HIGH,x
    clc
    adc     ORIX_MALLOC_BUSY_TABLE_END_HIGH,x
    ; FIXME for 32 bits mode in the future
    sta     ORIX_MALLOC_BUSY_TABLE_END_HIGH,x
    
    sta     ORIX_MALLOC_FREE_BEGIN_HIGH_TABLE
    
    ; update now the memory available in the chunk memory free
    
    lda     ORIX_MALLOC_FREE_SIZE_LOW_TABLE
    sec
    sbc     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_low,x
    sec
    sbc     ORIX_MALLOC_BUSY_TABLE_SIZE_LOW,x
    bcs     @skip3
    dec     ORIX_MALLOC_FREE_SIZE_HIGH_TABLE
@skip3:
    sta     ORIX_MALLOC_FREE_SIZE_LOW_TABLE
    
    lda     ORIX_MALLOC_FREE_SIZE_HIGH_TABLE
    sec
    sbc     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_high,x
    sec
    sbc     ORIX_MALLOC_BUSY_TABLE_SIZE_HIGH,x
    ; FIXME 32 bits
    sta     ORIX_MALLOC_FREE_SIZE_HIGH_TABLE
    
    ; Ok now inc the next free memory offset 
    inc     ORIX_MALLOC_FREE_BEGIN_LOW_TABLE
    bne     @skip4
    inc     ORIX_MALLOC_FREE_BEGIN_HIGH_TABLE
@skip4:
    
    ; register process in malloc table 
    lda     kernel_process+kernel_process_struct::kernel_current_process
    sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_pid_list,x
    
.ifdef WITH_DEBUG
    jsr     xdebug_end
.endif

    lda     ORIX_MALLOC_BUSY_TABLE_BEGIN_LOW,x    ; return chunk adress
    ldy     ORIX_MALLOC_BUSY_TABLE_BEGIN_HIGH,x
    
    rts
.endproc

