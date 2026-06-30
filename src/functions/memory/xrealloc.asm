.export XREALLOC_ROUTINE
;.import search_busy_chunk_with_address

.proc XREALLOC_ROUTINE ; ; $02
    ;;@brief Perform a realloc in the kernel memory space (48K). Return NULL if no memory available or if the pointer is invalid
    ;;@inputA contains the new size to allocate low (1 byte)
    ;;@inputY contains the new size to allocate high (1 byte)
    ;;@inputX reserved for future use, should be set to 0 by caller
    ;;@inputMEM_RES contains the pointer to reallocate  (2 bytes)
    ;;@modifyMEM_RESB
    ;;@modifyMEM_HRS2
    ;;@modifyMEM_HRS1


    sta     HRS2     ; save size
    sty     HRS2 + 1 ; save size
    
    ; lda     kernel_malloc + kernel_malloc_struct::kernel_malloc_free_chunk_begin_low,y
    ;lda     kernel_malloc + kernel_malloc_struct::kernel_malloc_free_chunk_end_low,y
    ;kernel_malloc_free_chunk_begin_low

    ; A and Y contains the pointer to the memory to reallocate, and X contains the new size of the memory to allocate
    ; We need to check if the pointer is valid, if not, we just call XMALLOC
    ; If the pointer is valid, we need to check if the new size is greater than the old size, if not, we can just return the same pointer, if it's greater, we need to allocate new memory and copy the old memory to the new one, then free the old memory and return the new pointer
    ; Check if pointer is valid
    jsr     XMALLOC_ROUTINE ; Does not use RES or RESB, so it does not affect kernel_create_process routine and kernel_try_to_find_command_in_bin_path, it returns NULL in A and Y if no memory available, or the pointer to the allocated memory in A and Y if successful
    ; If the pointer is NULL, it means that the pointer is invalid, we just call XMALLOC
    cmp     #NULL
    bne     @continue_realloc
    cpy     #NULL
    bne     @continue_realloc
    ; The pointer is invalid
    ; Impossible to realloc, we return NULL
@exit_null:
    rts

@continue_realloc:
    ; Let's copy to new memory the content of the old memory, then free the old memory and return the new pointer
    ; New ptr
    sta     RESB                                  ; Save A (low value of the new size), Y is not saved because we don't modify it
    sty     RESB + 1                              ; Save Y (high value of the new size)

    ; Save old ptr
    lda     RES
    sta     HRS2

    lda     RES + 1
    sta     HRS2 + 1

    jsr     search_busy_chunk_with_address
    cmp     #NULL
    ; Y will be equal to NULL if we did not found the busy chunk (from search_busy_chunk_with_address), it means that the pointer is invalid
    beq     @exit_null

    ; Now get size of the old memory to reallocate

    stx     HRS1 + 1 ; Save position of the busy chunk found in search_busy_chunk_with_address, because we will need it to free the old memory after copying

    lda     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_size_high,x
    beq     @copy_low
    ;sta     HRS1

    inx

    ldy     #$00

@restart_copy:
    lda     (RES),y
    sta     (RESB),y ; Copy content of the old memory to the new one
    iny
    bne     @copy
    inc     RES + 1
    inc     RESB + 1
    dex
    bne     @restart_copy

@copy_low:
    lda     kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_size_low,x
    sta     HRS1
    beq     @nop

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
    jmp     XFREE_ROUTINE

.endproc


