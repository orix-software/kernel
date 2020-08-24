
.export XMALLOC_ROUTINE

.proc XMALLOC_ROUTINE

; IN [A & Y ] the length requested
; 
; TR7 is modified
; OUT : NULL in A & Y or pointer in A & Y of the first byte of the allocated memory
; Don't use RES or RESB in this routine, if it's used, it affects kernel_create_process routine and kernel_try_to_find_command_in_bin_path
; Verify if there is enough memory
; 

    cpy     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high     ; Does High value of the number of the malloc is greater than the free memory ?
    bcc     @allocate                             
@exit_null:                                      ; If yes, then we have no memory left, return NULL
    ; we don't fix #ENOMEM, because null is returned already means OOM by default

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
    
    lda     KERNEL_MALLOC_TYPE 
    sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_type,x

    ; register process in malloc table 
    ;lda     KERNEL_MALLOC_TYPE
    ;cmp     #KERNEL_PROCESS_STRUCT_MALLOC_TYPE ; Is it a kernel create process ?
    ;beq     @not_kernel_create_process_malloc
    
    ;lda     #$01   ; store init process in malloc_pid_list
    ;bne     @store

;@not_kernel_create_process_malloc:    
    lda     kernel_process+kernel_process_struct::kernel_current_process
  ;  bne     @store
  ;  lda     #$FF ; init
@store:      
    sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_pid_list,x

    ; Restore type

    lda     #KERNEL_UNKNOWN_MALLOC_TYPE
    sta     KERNEL_MALLOC_TYPE  

    lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_low,x
    ldy     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_high,x
    ; Debug
    rts
    pha
    ;sta     TR6
    tya
    pha

    ; Y
    
    jsr     _print_hexa
    lda     TR6
    jsr     _print_hexa_no_sharp

    lda     KERNEL_MALLOC_TYPE  
    ldy     #$00
    ldx     #$20 ;
    stx     DEFAFF
    ldx     #$00
    ;jsr     XDECIM_ROUTINE


    ;jsr     XCRLF_ROUTINE
    pla 
    tay
    pla

    ; Restore type

    
    rts
.endproc

_print_hexa:
    pha
    lda #'#'
    jsr XWR0_ROUTINE
    pla

    jsr XHEXA_ROUTINE
    sty TR7
    
    jsr XWR0_ROUTINE
    lda TR7
    jsr XWR0_ROUTINE
    rts



_print_hexa_no_sharp:


    jsr XHEXA_ROUTINE
    sty TR7
    
    jsr XWR0_ROUTINE
    lda TR7
    jsr XWR0_ROUTINE
    rts    
