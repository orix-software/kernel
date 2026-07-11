.export XREALLOC_ROUTINE
; .import search_busy_chunk_with_address

.proc XREALLOC_ROUTINE ; ; $02
    ;;@brief Perform a realloc in the kernel memory space (48K). Return NULL if no memory available or if the pointer is invalid
    ;;@details Returns 0 in X, if it return a new ptr. it can not resize to lower size
    ;;@inputA contains the new size to allocate low (1 byte)
    ;;@inputY contains the new size to allocate high (1 byte)
    ;;@inputX reserved for future use, should be set to 0 by caller
    ;;@returnsX if XREALLOC uses a new ptr X = 0, if the same but the range is extended, X = 1
    ;;@returnsA ; the ptr if success (low), Null if something goes wrong
    ;;@returnsY ; the ptr if success (high), Null if something goes wrong
    ;;@inputMEM_RES contains the pointer to reallocate  (2 bytes)
    ;;@modifyMEM_RESB
    ;;@modifyMEM_HRS2
    ;;@modifyMEM_HRS3
    ;;@modifyMEM_HRS1
    ;;@```asm
    ;;@`  .include "telestrat.inc"
    ;;@`  lda  ptr_to_extend
    ;;@`  sta  RES
    ;;@`  lda  ptr_to_extend + 1
    ;;@`  sta  RES + 1
    ;;@`  lda  #<100 ; Size
    ;;@`  ldy  #>100
    ;;@`  BRK_TELEMON $02
    ;;@`  rts
    ;;@`ptr_to_extend:
    ;;@`    .word
    ;;@```


    sta     HRS1     ; save size
    sty     HRS1 + 1 ; save size
    sta     HRS3     ; save size won't be modifyed
    sty     HRS3 + 1 ; save size won't be modifyed
    ; get ptr
    lda     RES
    ldy     RES + 1
    jsr     search_busy_chunk_with_address
    cmp     #$01
    beq     @found

@exit_null:
    ; In that case, we get A=NULL, it means that we did not found the chunck
    ; It retuns NULL with search_busy_chunk_with_address
    rts
    ; lda     kernel_malloc + kernel_malloc_struct::kernel_malloc_free_chunk_begin_low,y
    ;lda     kernel_malloc + kernel_malloc_struct::kernel_malloc_free_chunk_end_low,y
    ;kernel_malloc_free_chunk_begin_low

@found:
    ; Chunck found, now we try to see if next memory is available
    ; Save current_busy chunk
    stx     TR0
    lda     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_end_high,x
    tay
    lda     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_end_low,x
    clc
    adc     #$01
    bcc     @skip_high
    iny

@skip_high:
    cmp     kernel_malloc + kernel_malloc_struct::kernel_malloc_free_chunk_begin_low
    bne     @no_contiguous_free_in_free_chunk
    tya
    cmp     kernel_malloc + kernel_malloc_struct::kernel_malloc_free_chunk_begin_high
    bne     @no_contiguous_free_in_free_chunk
    ; Check size now
    lda     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_size_low,x
    sec
    sbc     HRS1
    sta     HRS1

    lda     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_size_high,x
    sbc     HRS1 + 1
    sta     HRS1 + 1
    ; Now HRS1 contains the additionnal size
    ; Let's see if we have enough in free chunk
    lda     kernel_malloc_free_chunk_size + kernel_malloc_free_chunk_size_struct::kernel_malloc_free_chunk_size_high
    cmp     HRS1 + 1
    bcc     @no_contiguous_free_in_free_chunk

    lda     kernel_malloc_free_chunk_size + kernel_malloc_free_chunk_size_struct::kernel_malloc_free_chunk_size_low
    cmp     HRS1
    bcc     @no_contiguous_free_in_free_chunk
    ; Free chunk OK
    ; Now correct busy chunk
    ; Update busy size
    jmp     @update_chunk



    ; Go malloc
@no_contiguous_free_in_free_chunk:
    lda     HRS3     ; get requested size
    ldy     HRS3 + 1 ; get requested size

    ; A and Y contains the pointer to the memory to reallocate, and X contains the new size of the memory to allocate
    ; We need to check if the pointer is valid, if not, we just call XMALLOC
    ; If the pointer is valid, we need to check if the new size is greater than the old size, if not, we can just return the same pointer, if it's greater, we need to allocate new memory and copy the old memory to the new one, then free the old memory and return the new pointer
    ; Check if pointer is valid
    jsr     XMALLOC_ROUTINE ; Modify TR6 & TR7 Does not use RES or RESB, so it does not affect kernel_create_process routine and kernel_try_to_find_command_in_bin_path, it returns NULL in A and Y if no memory available, or the pointer to the allocated memory in A and Y if successful
    ; If the pointer is NULL, it means that the pointer is invalid, we just call XMALLOC
    cmp     #NULL
    bne     @continue_realloc
    cpy     #NULL
    ; The pointer is invalid
    ; Impossible to realloc, we return NULL
    beq     @exit_null

; continue


@continue_realloc:
    ; Let's copy to new memory the content of the old memory, then free the old memory and return the new pointer
    ; New ptr
    sta     RESB                                  ; Save A (low value of the new size), Y is not saved because we don't modify it
    sta     HRS1
    sty     RESB + 1                              ; Save Y (high value of the new size)
    sty     HRS1 + 1                              ; Save Y (high value of the new size)

    ; Save "old malloc ptr" for XFREE
    lda     RES
    sta     HRS2
    lda     RES + 1
    sta     HRS2 + 1

    ; Let's now copy
    ldx     TR0 ; Get position of busy chunk
    lda     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_size_high,x
    ; If high is equal to 0
    beq     @copy_low
   

    ; Get size low
    lda     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_size_high,x
    tax

    ldy     #$00

@restart_copy:
    lda     (RES),y
    sta     (RESB),y ; Copy content of the old memory to the new one
    iny
    bne     @restart_copy
    inc     RES + 1
    inc     RESB + 1
    dex
    bne     @restart_copy

@copy_low:
    ldx     TR0 ; Get position of busy chunk
    lda     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_size_low,x
    sta     HRS1
    ; Y = 0 because the previous loop has Y=0 at the end
@copy:
    lda     (RES),y
    sta     (RESB),y ; Copy content of the old memory to the new one
    iny
    cpy     HRS1
    bne     @copy

    ; Free old memory
@nop:
    lda     HRS2
    ldy     HRS2 + 1
    jsr     XFREE_ROUTINE

    lda     HRS1
    ldy     HRS1 + 1
    ldx     #$00 ; Malloc is performed we return a new ptr

    rts


@update_chunk:
    lda     HRS3
    sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_size_low,x

    lda     HRS3 + 1
    sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_size_high,x

    ; Update free chunk size
    lda     kernel_malloc_free_chunk_size + kernel_malloc_free_chunk_size_struct::kernel_malloc_free_chunk_size_low
    sec
    sbc     HRS2
    sta     kernel_malloc_free_chunk_size + kernel_malloc_free_chunk_size_struct::kernel_malloc_free_chunk_size_low

    lda     kernel_malloc_free_chunk_size + kernel_malloc_free_chunk_size_struct::kernel_malloc_free_chunk_size_high
    sec
    sbc     HRS2 + 1
    sta     kernel_malloc_free_chunk_size + kernel_malloc_free_chunk_size_struct::kernel_malloc_free_chunk_size_high

    lda     HRS2
    clc
    adc     #$01
    adc     kernel_malloc + kernel_malloc_struct::kernel_malloc_free_chunk_begin_low,x
    sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_free_chunk_begin_low,x

    lda     HRS2 + 1
    adc     kernel_malloc + kernel_malloc_struct::kernel_malloc_free_chunk_begin_high,x
    sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_free_chunk_begin_high,x

    ; Now update malloc end
    lda     HRS2

    adc     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_begin_low,x
    sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_begin_low,x

    lda     HRS2 + 1
    adc     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_begin_high,x
    sta     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_begin_high,x

    ldx     #$01 ; Range extended
    rts


.endproc


