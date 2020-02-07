.export XFREE_ROUTINE

.proc XFREE_ROUTINE


.ifdef WITH_DEBUG
    jsr     xdebug_enter_XFREE
.endif

  ;jsr     xfree_debug_enter
; [A & Y] the first adress of the pointer.
  sta     KERNEL_XFREE_TMP
  ldx     #$00
@search_busy_chunk:
  lda     KERNEL_XFREE_TMP
  cmp     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_low,x ; Looking if low is available.
  bne     @next_chunk
  tya
  cmp     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_high,x
  beq     @busy_chunk_found
  
@next_chunk:
  inx
  cpx     #KERNEL_MAX_NUMBER_OF_MALLOC
  bne     @search_busy_chunk
  ; Return NULL ?
  ; We did not found this busy chunk

  rts

@busy_chunk_found
  ; Free now 
  ; TODO check process
  ; at this step X is on the right busy table
  ; looking if we can merge with a free chunk
  ; FIXME BUG
  lda     #$00
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_pid_list,x
  sta     RES

; Try to recursive  
  ldy     #$00
@try_another_free_chunk:
  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_low,y
  ; FIXME 65C02, use 'dec A'
  sec
  sbc     #$01
  bcs     @skip_inc_high
  inc     RES
@skip_inc_high:  
  cmp     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_low,x
  beq     @compare_high
  ; At this step it's not the first free chunk
  lda     #$00
  sta     RES
  iny 
  cpy     #KERNEL_MALLOC_FREE_FRAGMENT_MAX
  bne     @try_another_free_chunk
      
.ifdef WITH_DEBUG
    jsr     xdebug_end
.endif

  rts

    
@compare_high:
  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_high,y
  sty     RES+1
  ldy     RES
  cpy     #$01
  bne     don_t_inc_carry
  sec
  sbc     #$01
don_t_inc_carry:
  cmp     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_high,x
  beq @merge_with_free_table
  ; at this step we can not merge the chunk, we needs to create a new free chunk
  ldy     RES+1
  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_low,x  
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_low,y
  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_high,x  
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_high,y

  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_low,x  
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_end_low,y
  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_high,x  
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_end_high,y

  lda     #$00
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_low,x  
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_high,x  
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_low,x
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_low,x

    
.ifdef WITH_DEBUG
    jsr     xdebug_end
.endif


  rts

; at this step we can merge   
@merge_with_free_table:
  ; add in the free malloc table
  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_low,x
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_low
	
  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_high,x
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_high
  
  ; update size
  
  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_low,x
  clc
  adc     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_low
  bcc     @do_not_inc
  inc     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high	
@do_not_inc:
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_low


  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_high,x
  clc
  adc     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high


    ; move the busy malloc table
; FIXME
  inx 
  cpx     #KERNEL_MAX_NUMBER_OF_MALLOC
  beq     @no_need_to_merge
@no_need_to_merge:

.ifdef WITH_DEBUG
    jsr     xdebug_end
.endif

out:
  rts
.endproc
