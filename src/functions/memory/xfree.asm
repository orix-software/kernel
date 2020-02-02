.export XFREE_ROUTINE

.proc XFREE_ROUTINE

; [A & Y] the first adress of the pointer.
  ldx     #$00
@search_busy_chunk:
  cmp     ORIX_MALLOC_BUSY_TABLE_BEGIN_LOW,x ; Looking if low is available.
  bne     @next_chunk
  tya
  cmp     ORIX_MALLOC_BUSY_TABLE_BEGIN_HIGH,x
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
  sta     ORIX_MALLOC_BUSY_TABLE_PID,x
 ; sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_pid_list,x
  sta     RES
  
  ldy #$00
@try_another_free_chunk:
  lda ORIX_MALLOC_FREE_BEGIN_LOW_TABLE,y
  ; FIXME 65C02, use 'dec A'
  sec
  sbc #$01
  bcs @skip_inc_high
  inc RES
@skip_inc_high:  
  cmp ORIX_MALLOC_BUSY_TABLE_END_LOW,x
  beq @compare_high
  ; At this step it's not the first free chunk
  lda #$00
  sta RES
  iny 
  cpy #KERNEL_MALLOC_FREE_FRAGMENT_MAX
  bne @try_another_free_chunk
  rts

    
@compare_high:
  lda ORIX_MALLOC_FREE_BEGIN_HIGH_TABLE,y
  sty RES+1
  ldy RES
  cpy #$01
  bne don_t_inc_carry
  sec
  sbc #$01
don_t_inc_carry:
  cmp ORIX_MALLOC_BUSY_TABLE_END_HIGH,x
  beq @merge_with_free_table
  ; at this step we can not merge the chunk, we needs to create a new free chunk
  ldy RES+1
  lda ORIX_MALLOC_BUSY_TABLE_BEGIN_LOW,x  
  sta ORIX_MALLOC_FREE_BEGIN_LOW_TABLE,y
  lda ORIX_MALLOC_BUSY_TABLE_BEGIN_HIGH,x  
  sta ORIX_MALLOC_FREE_BEGIN_HIGH_TABLE,y

  lda ORIX_MALLOC_BUSY_TABLE_END_LOW,x  
  sta ORIX_MALLOC_FREE_END_LOW_TABLE,y
  lda ORIX_MALLOC_BUSY_TABLE_END_HIGH,x  
  sta ORIX_MALLOC_FREE_END_HIGH_TABLE,y

  lda #$00
  sta ORIX_MALLOC_BUSY_TABLE_BEGIN_LOW,x  
  sta ORIX_MALLOC_BUSY_TABLE_BEGIN_HIGH,x  
  sta ORIX_MALLOC_BUSY_TABLE_END_LOW,x
  sta ORIX_MALLOC_BUSY_TABLE_END_LOW,x


  rts

; at this step we can merge   
@merge_with_free_table:
  ; add in the free malloc table
  lda ORIX_MALLOC_BUSY_TABLE_BEGIN_LOW,x
  sta ORIX_MALLOC_FREE_BEGIN_LOW_TABLE
	
  lda ORIX_MALLOC_BUSY_TABLE_BEGIN_HIGH,x
  sta ORIX_MALLOC_FREE_BEGIN_HIGH_TABLE
  
  ; update size
  
  lda ORIX_MALLOC_BUSY_TABLE_SIZE_LOW,x
  clc
  adc ORIX_MALLOC_FREE_SIZE_LOW_TABLE
  bcc @do_not_inc
  inc ORIX_MALLOC_FREE_SIZE_HIGH_TABLE	
@do_not_inc:
  sta ORIX_MALLOC_FREE_SIZE_LOW_TABLE

  lda ORIX_MALLOC_BUSY_TABLE_SIZE_HIGH,x
  clc
  adc ORIX_MALLOC_FREE_SIZE_HIGH_TABLE
  sta ORIX_MALLOC_FREE_SIZE_HIGH_TABLE

    ; move the busy malloc table
; FIXME
  inx 
  cpx ORIX_MALLOC_BUSY_TABLE_NUMBER
  beq @no_need_to_merge
@no_need_to_merge:
  rts ; FIXME remove
out:
  rts
.endproc

