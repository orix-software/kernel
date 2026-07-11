.export xvalues_wrapper

.import xvalues_wrapper

.proc xvalues_wrapper
    pha

    lda     $343
    sta     KERNEL_BACKUP_SET

    lda     #<$c006
    sta     VEXBNK + 1
    lda     #>$c006
    sta     VEXBNK + 2
    lda     #$01
    sta     BNKCIB

    pla
    jmp     $40C

.endproc
