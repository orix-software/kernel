
.export XMALLOC_ROUTINE

.proc XMALLOC_ROUTINE

; [A & Y ] the length requested
; TR7 is modified
; Don't use RES or RESB, if it's used, it affects kernel_create_process routine
; Verify if there is enough memory
; 
    cpy     ORIX_MALLOC_FREE_SIZE_HIGH_TABLE
    bcc     @allocate
@exit_null:
    lda     #NULL
    ldy     #NULL

    rts
@allocate:

    ; found first available busy table
    ldx     #$00
    sta     TR7
 
@looking_for_busy_chunck_available:
    lda     ORIX_MALLOC_BUSY_TABLE_PID,x
    beq     @found
    inx 
    cpx     #ORIX_NUMBER_OF_MALLOC
    beq     @exit_null 
    bne     @looking_for_busy_chunck_available

@found:
    lda     TR7
    sta     ORIX_MALLOC_BUSY_TABLE_SIZE_LOW,x     ; store the length of the busy chunk
    tya
    sta     ORIX_MALLOC_BUSY_TABLE_SIZE_HIGH,x    ; store the length (low)
    
    lda     ORIX_MALLOC_FREE_BEGIN_HIGH_TABLE
    sta     ORIX_MALLOC_BUSY_TABLE_BEGIN_HIGH,x   ; to compute High adress
    sta     ORIX_MALLOC_BUSY_TABLE_END_HIGH,x   ; to compute High adress
    
    
    lda     ORIX_MALLOC_FREE_BEGIN_LOW_TABLE                ; get the first offset
    sta     ORIX_MALLOC_BUSY_TABLE_BEGIN_LOW,x    ; and save it
    sta     ORIX_MALLOC_BUSY_TABLE_END_LOW,x
    clc
    adc     ORIX_MALLOC_BUSY_TABLE_SIZE_LOW,x
    bcc     @skip2
    inc     ORIX_MALLOC_BUSY_TABLE_END_HIGH,x
 @skip2:
    sta     ORIX_MALLOC_BUSY_TABLE_END_LOW,x
  
    sta     ORIX_MALLOC_FREE_BEGIN_LOW_TABLE                ; update of the next chunk available
    
    
    lda     ORIX_MALLOC_BUSY_TABLE_SIZE_HIGH,x
    clc
    adc     ORIX_MALLOC_BUSY_TABLE_END_HIGH,x
    ; FIXME for 32 bits mode in the future
    sta     ORIX_MALLOC_BUSY_TABLE_END_HIGH,x
    
    sta     ORIX_MALLOC_FREE_BEGIN_HIGH_TABLE
    
    ; update now the memory available in the chunk memory free
    
    lda     ORIX_MALLOC_FREE_SIZE_LOW_TABLE
    sec
    sbc     ORIX_MALLOC_BUSY_TABLE_SIZE_LOW,x
    bcs     @skip3
    dec     ORIX_MALLOC_FREE_SIZE_HIGH_TABLE
@skip3:
    sta     ORIX_MALLOC_FREE_SIZE_LOW_TABLE
    
    lda     ORIX_MALLOC_FREE_SIZE_HIGH_TABLE
    sec
    sbc     ORIX_MALLOC_BUSY_TABLE_SIZE_HIGH,x
    ; FIXME 32 bits
    sta     ORIX_MALLOC_FREE_SIZE_HIGH_TABLE
    
    
   ; inc ORIX_MALLOC_BUSY_TABLE_NUMBER             ; increment the number of count 
    
    ; Ok now inc the next free memory offset 
    inc     ORIX_MALLOC_FREE_BEGIN_LOW_TABLE
    bne     @skip4
    inc     ORIX_MALLOC_FREE_BEGIN_HIGH_TABLE
@skip4:
    
    ; register process in malloc table 
    lda     ORIX_CURRENT_PROCESS_FOREGROUND

    sta     ORIX_MALLOC_BUSY_TABLE_PID,x

    sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_pid_list,x
    
    lda     ORIX_MALLOC_BUSY_TABLE_BEGIN_LOW,x    ; return chunk adress
    ldy     ORIX_MALLOC_BUSY_TABLE_BEGIN_HIGH,x
    
    rts
.endproc

