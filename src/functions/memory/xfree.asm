.export XFREE_ROUTINE


.proc XFREE_ROUTINE

.ifdef WITH_DEBUG  
    sta     RESB
    sty     RESB+1
    stx     TR4
    jsr     xdebug_install  
    lda     RESB
    ldy     RESB+1    
    ldx     TR4

.endif

.ifdef WITH_DEBUG
    ldx     #XDEBUG_XFREE_ENTER_PRINT
    jsr     xdebug_print
    jsr     xdebug_load

.endif

  ;jsr     xfree_debug_enter
; [A & Y] the first adress of the pointer.

  sta     KERNEL_XFREE_TMP    ; Save A (low)
  
  lda     #$01
  sta     TR0 ; TR0 contains the next free chunk

.ifdef WITH_DEBUG

  lda     KERNEL_XFREE_TMP    ; Save A (low)
  jsr xdebug_send_ay_to_printer
  jsr xdebug_enter_xfree_found

  ;jsr xdebug_lsmem

.endif  

; **************************************************************************************
; Try to fund chunk
  ; Search which chunck is used
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
  cpx     #(KERNEL_MAX_NUMBER_OF_MALLOC+1)
  bne     @search_busy_chunk
  
  ; We did not found this busy chunk, return 0 in A
.ifdef WITH_DEBUG  
  jsr xdebug_enter_not_found
.endif
    
.ifdef WITH_DEBUG
  jsr xdebug_lsmem
.endif
  lda     #NULL
  
  rts

@busy_chunk_found:
  lda     KERNEL_XFREE_TMP
.ifdef WITH_DEBUG
  jsr xdebug_send_ay_to_printer
.endif  

  ; Free now 
  ; TODO check process
  ; at this step X is on the right busy table
  ; looking if we can merge with a free chunk
  ; FIXME BUG
  lda     #$00
  ; Erase pid reference
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
  ; X contains the index of the busy chunk found
@skip_inc_high:  
  cmp     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_low,x
  beq     @compare_high
  ; At this step it's not the first free chunk
  lda     #$00
  sta     RES
  iny 
  cpy     #KERNEL_MALLOC_FREE_FRAGMENT_MAX
  bne     @try_another_free_chunk
 

  ;KERNEL_MALLOC_FREE_CHUNK_MAX

  ; Force first free chunk
  ldy    TR0 ; get next free chunk
  sty    RES+1

  jmp    @create_new_freechunk

  ;rts

    
@compare_high:
  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_high,y
  sty     RES+1 ; Save current free chunk
  ldy     RES
  cpy     #$01
  bne     @don_t_inc_carry
  sec
  sbc     #$01
@don_t_inc_carry:
  ; X contains the index of the busy chunk found
  cmp     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_high,x
  beq     @merge_with_free_table
  ; at this step we can not merge the chunk, we needs to create a new free chunk
@create_new_freechunk:
.ifdef WITH_DEBUG

  jsr xdebug_enter_XFREE_new_freechunk  
.endif

  ; Looking for Free chunk available
  ldy     RES+1
@find_a_free_chunk:
  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_low,y
  beq     @free_chunk_is_available
  iny
  cpy     #(KERNEL_MALLOC_FREE_FRAGMENT_MAX)
  bne     @find_a_free_chunk  
  ; Panic
  PRINT   str_can_not_find_any_free_chunk_available
  PRINT   str_kernel_panic
@panic:  
  jmp     @panic



@free_chunk_is_available:
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

  ; update size
  
  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_low,x  
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_low,y

  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_high,x  
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high,y


    
.ifdef WITH_DEBUG
  jsr xdebug_lsmem
.endif
  lda     #$01 ; Chunk found

  rts

; at this step we can merge   
@merge_with_free_table:
  ; Y contains the id of the free chunk
  sty     RES

.ifdef WITH_DEBUG
  jsr   xdebug_enter_merge_free_table
.endif
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

  ; Y contains the current free chunk found, we destroy it now


    ; move the busy malloc table
; FIXME
;  inx 
 ; cpx     #KERNEL_MAX_NUMBER_OF_MALLOC
  ;beq     @no_need_to_merge
  ;lda     #$01
  ;rts
  ldy      RES+1 ; restore id chunk
@no_need_to_merge:


  cpy     #$00 ; was it the main free chunk
  beq     @main_free_no_action ; Yes we do not destroy it

  ; we initialize free chunk used (set to 0)
  ; we set only high to 00 because it's impossible to have a malloc with High adress equal to $00
  lda     #$00
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_high,y
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_low,y

  



@main_free_no_action:

.ifdef WITH_DEBUG
    jsr     xdebug_end
.endif

out:
.ifdef WITH_DEBUG
  jsr xdebug_lsmem
.endif  
  lda     #$01 
  rts
.endproc

.proc garbage_collector

  ldy     #$00
@try_another_free_chunk:
  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_low,y
  ; FIXME 65C02, use 'dec A'
  sec
  sbc     #$01
  ;bcs     @skip_inc_high
  inc     RES
  ; X contains the index of the busy chunk found
@skip_inc_high:  
  cmp     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_low,x
  ;beq     @compare_high
  ; At this step it's not the first free chunk
  lda     #$00
  sta     RES
  iny 
  cpy     #KERNEL_MALLOC_FREE_FRAGMENT_MAX
  bne     @try_another_free_chunk
 

  rts
.endproc


str_can_not_find_any_free_chunk_available:
  .asciiz "Can not find another free chunk slot"
str_kernel_panic:
  .byte  $0D
  .byte "Kernel panic !"
  .byte $00
