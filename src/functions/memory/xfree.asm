.export XFREE_ROUTINE

 ; 6c6 b3ff ac3c

.proc XFREE_ROUTINE
  ; A & Y

  .out     .sprintf("|MODIFY:TR5:XFREE_ROUTINE")
  .out     .sprintf("|MODIFY:RES:XFREE_ROUTINE")
  .out     .sprintf("|MODIFY:KERNEL_XFREE_TMP:XFREE_ROUTINE")

  
 ; jmp     XFREE_ROUTINE : f91b
  sta     KERNEL_XFREE_TMP    ; Save A (low)

  ; AY contains ptr
  sty     HRSX

.ifdef WITH_DEBUG
  jsr     kdebug_save
    
  lda     KERNEL_XFREE_TMP
  ldx     #XDEBUG_XFREE_ENTER_PRINT
  jsr     xdebug_print_with_ay
    
  jsr     kdebug_restore
.endif

; [A & Y] the first adress of the pointer.
  
  lda     #$01
  sta     TR5 ; TR0 contains the next free chunk

.ifdef WITH_DEBUG
  jsr     kdebug_save
  jsr     xdebug_lsmem
  jsr     kdebug_restore
.endif  

  ; **************************************************************************************
  ; Try to find chunk
  ; Search which chunck is used
  ldx     #$00

@search_busy_chunk:
  lda     KERNEL_XFREE_TMP
  cmp     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_low,x ; Looking if low is available.
  bne     @next_chunk
  tya
  cmp     kernel_malloc_busy_begin+kernel_malloc_busy_begin_struct::kernel_malloc_busy_chunk_begin_high,x
  beq     @busy_chunk_found
  
@next_chunk:
  inx
  cpx     #KERNEL_MAX_NUMBER_OF_MALLOC
  bne     @search_busy_chunk
  
  ; We did not found2 this busy chunk, return 0 in A
.ifdef WITH_DEBUG2
  jsr     xdebug_enter_not_found
.endif
    
.ifdef WITH_DEBUG
  ;jsr     kdebug_save
  ;jsr     xdebug_lsmem
  ;jsr     kdebug_restore
.endif
  lda     #NULL
  
  rts

@busy_chunk_found:
  ; X contains the id of the busy chunk
  lda     KERNEL_XFREE_TMP ; ????


.ifdef WITH_DEBUG2
  jsr     kdebug_save

  jsr     xdebug_send_ay_to_printer

  jsr     kdebug_restore  
.endif  

  ; Free now 
  ; TODO check process
  ; at this step X is on the right busy table
  ; looking if we can merge with a free chunk
  ; FIXME BUG

  ; We try to find where the free chunk is
  lda     #$00
  ; Erase pid reference
  ; FR : On set 0 dans la table de malloc (dans la liste des pid de malloc) pour dire que le chunk "busy" est libre
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_pid_list,x
  sta     RES

  ; Try to recursive  

  ;lda     KERNEL_XFREE_TMP    ; Save A (low)
  ;cmp     #$D5
  ;bne     @continue

;@continue:
  ; FR : on essaie de trouver un chunk libre
  ldy     #$00
@try_another_free_chunk:
  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_low,y ; $FC $B4

  ; FIXME 65C02, use 'dec A'
  sec
  sbc     #$01 ; $FB ;$B3
  bcs     @skip_inc_high
  inc     RES
  ; X contains the index of the busy chunk found
@skip_inc_high:  
  cmp     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_low,x ; kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_low,5 : $DF
  beq     @compare_high
  ; At this step it's not the first free chunk
@next_free_chunk:  
  lda     #$00
  sta     RES
  iny 
  cpy     #KERNEL_MALLOC_FREE_FRAGMENT_MAX
  bne     @try_another_free_chunk

  ;jsr     find_free_chunk_from_end_of_chunk
  ;cmp     #$01    
  ;beq     @not_found_chunk
  ;jmp     merge_with_chunk
@not_found_chunk:
  ; Force first free chunk
  ldy     TR5                                 ; Get next free chunk
  sty     RES+1

  jmp     @create_new_freechunk
    
@compare_high:
  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_high,y
  sty     RES+1 ; Save current free chunk
  ldy     RES
  bne     @next_free_chunk


@don_t_inc_carry:
  ; X contains the index of the busy chunk found
  cmp     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_high,x
  beq     @merge_with_free_table


; at this step we can not merge the chunk, we needs to create a new free chunk
@create_new_freechunk:
.ifdef WITH_DEBUG2
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
  jsr     free_clear_free_chunk
  jmp     xfree_exit

; at this step we can merge   
@merge_with_free_table:
  ; Y contains the id of the free chunk
  sty     RES

.ifdef WITH_DEBUG2
;  jsr   xdebug_enter_merge_free_table ; Ne pas décommenter, cela surcharge X ...
.endif
  ; add in the free malloc table
  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_low,x
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_low,y

  lda     kernel_malloc_busy_begin+kernel_malloc_busy_begin_struct::kernel_malloc_busy_chunk_begin_high,x
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_high,y
 
  ; update size

  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_low,x
  clc
  adc     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_low,y
  bcc     @do_not_inc
  pha
  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high,y ; It should be better here but inc does not manage inc $xx,y	
  clc
  adc     #$01
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high,y
  pla
@do_not_inc:

  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_low,y


  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_high,x
  clc
  adc     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high,y
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high,y


  lda     #$00
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_low,x
  sta     kernel_malloc_busy_begin+kernel_malloc_busy_begin_struct::kernel_malloc_busy_chunk_begin_high,x
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_low,x  
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_high,x

  ; Y contains the current free chunk found, we destroy it now


  ; Move the busy malloc table

  ldy     RES+1               ; Restore id chunk
@no_need_to_merge:

  cpy     #$00                 ; Was it the main free chunk
  beq     @main_free_no_action ; Yes we do not destroy it

  ; We initialize free chunk used (set to 0)
  ; We set only high to 00 because it's impossible to have a malloc with High adress equal to $00
  lda     #$00
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_high,y
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_low,y



  ; $1B
  ; Update the main memory chunk
  ; Y=2
  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_low,y 
  clc
  adc     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_low 
  bcc     @do_not_inc2
  pha
  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high,y ; It should be better here but inc does not manage inc $xx,y	
  clc
  adc     #$01
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high 
  pla
@do_not_inc2:
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_low


@main_free_no_action:

.ifdef WITH_DEBUG2
  jsr     xdebug_end
.endif

out:
.endproc



.proc find_free_chunk_from_end_of_chunk
  ; A=0 success, and Y is the free chunk to merge with current offset calls

  lda     #$00
  sta     RES

  ldy     #$01
@try_another_free_chunk:
  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_end_low,y ; $FC $B4

  ; FIXME 65C02, use 'dec A'
  clc
  adc     #$01 ; $FB ;$B3
  bcc     @skip_inc_high
  inc     RES
  ; X contains the index of the busy chunk found
@skip_inc_high:
  cmp     KERNEL_XFREE_TMP ; 
  beq     @compare_high
  ; At this step it's not the first free chunk
@next_free_chunk:  
  lda     #$00
  sta     RES
  iny 
  cpy     #KERNEL_MALLOC_FREE_FRAGMENT_MAX
  bne     @try_another_free_chunk
  lda     #$01 ; Not found
  rts
 
    
@compare_high:
  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_end_high,y
  cmp     HRSX
  beq     @found

  bne     @next_free_chunk
  rts
@found:
  lda     #$00
  rts  
.endproc

.proc merge_with_chunk
  rts
.endproc


; Don't move this proc
.proc xfree_exit
  jsr     xfree_garbage

.ifdef WITH_DEBUG
  jsr     kdebug_save
  jsr     xdebug_lsmem
  jsr     kdebug_restore
.endif  

  lda     #$01 
  rts
.endproc

.proc free_clear_free_chunk

  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_low,x  
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_low,y

  lda     kernel_malloc_busy_begin+kernel_malloc_busy_begin_struct::kernel_malloc_busy_chunk_begin_high,x  
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_high,y

  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_low,x  
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_end_low,y

  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_high,x  
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_end_high,y


  jsr     xfree_clear_busy_chunk

  ; update size
  
  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_low,x  
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_low,y

  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_high,x  
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high,y
  rts
.endproc  

.proc xfree_clear_busy_chunk
  lda     #$00
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_low,x  
  sta     kernel_malloc_busy_begin+kernel_malloc_busy_begin_struct::kernel_malloc_busy_chunk_begin_high,x  

  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_low,x
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_low,x
  rts
.endproc


.proc xfree_garbage

  ldx     #$01
  lda     #$00
  sta     RES
  ; FR : on essaie de trouver un chunk libre
  ldy     #$02
  cpy     #(KERNEL_MALLOC_FREE_CHUNK_MAX-1)
  bcc     @try_another_free_chunk
  rts
  
@try_another_free_chunk:
  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_end_high,y
  beq     @next_free
  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_end_high,x
  beq     @next_free

  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_end_low,y
  ; FIXME 65C02, use 'dec A'
  clc
  adc     #$01

  bcc     @skip_inc_high
  inc     RES
  ; X contains the index of the busy chunk found
@skip_inc_high:  
  cmp     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_low,x
  beq     @compare_high
  bne     @next_free
    
@compare_high:

  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_end_high,y
  clc     
  adc     RES
  cmp     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_high,x
  bne     @not_same

  ; concat

  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_end_high,x
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_end_high,y

  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_end_low,x
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_end_low,y

  ; Compute size

  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_low,x
  


  clc
  adc     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_low,y
  bcc     @do_not_inc

; [lsmem state]
; Free:#07F6:B3FF #AC0D
; Busy:#06C2:0734 #0072
; Busy#0735:075B #0026
; Busy:#075C:07C0 #0064
; Busy:#07C1:07F5 #0034

  pha
  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high,y ; It should be better here but inc does not manage inc $xx,y	
  clc
  adc     #$01
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high,y
  pla
@do_not_inc:
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_low,y




  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high,x
  clc
  adc     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high,y
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high,y

  ; Clear the free chunk
  lda     #$00
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_low,x
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_high,x

  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_end_low,x
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_end_high,x
  
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_low,x
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high,x



@not_same:
@next_free:
  
  iny
  cpy     #(KERNEL_MALLOC_FREE_CHUNK_MAX)  
  bne     @try_another_free_chunk

  ldy     #$02
  inx
  cpx     #(KERNEL_MALLOC_FREE_CHUNK_MAX)  
  bne     @try_another_free_chunk




  rts
.endproc

str_can_not_find_any_free_chunk_available:
  .asciiz "Free chunk slot error"
str_kernel_panic:
  .byte $0D
  .byte "KPANIC!"
  .byte $00
