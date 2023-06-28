.export _xvalues_get_free_ram_bank_routine
.export _xvalues_get_free_ram_bank_routine_get_real_id

.include "telestrat.inc"

.proc _xvalues_get_free_ram_bank_routine
    KERNEL_XVALUES_GET_FREE_BANK = $10
    ldx     #KERNEL_XVALUES_GET_FREE_BANK
    ldy     #$00
    BRK_TELEMON  $2D
    sty     xvalues_get_free_ram_bank_routine_get_real_id_save
    rts
.endproc

xvalues_get_free_ram_bank_routine_get_real_id_save:
    .res 1

.proc _xvalues_get_free_ram_bank_routine_get_real_id
    lda        xvalues_get_free_ram_bank_routine_get_real_id_save
    ldx        #$00
    rts
.endproc
