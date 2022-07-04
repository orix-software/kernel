CH395_COMMAND_PORT            := $381
CH395_DATA_PORT               := $380
CH395_WRITE_SEND_BUF_SN       = $39
CH395_GET_SOCKET_STATUS_SN    = $2F
CH395_SINT_STAT_SENBUF_FREE = $01
CH395_GET_INT_STATUS_SN       = $30
CH395_SINT_STAT_SEND_OK     = $02

; void ch395_write_send_buf_sn(unsigned char *msg, unsigned int length,unsigned char ID_SOCKET)

.proc _ch395_write_send_buf_sn
    lda     i_o_save
    cmp     #$0D
    beq     @exit


    ldx     #CH395_WRITE_SEND_BUF_SN
    stx     CH395_COMMAND_PORT
    ldx     #$01 ; Socket 1
    stx     CH395_DATA_PORT

    ldx     #$01
    stx     CH395_DATA_PORT ; set length
    dex
    stx     CH395_DATA_PORT ; set length

    lda     i_o_save
    sta     CH395_DATA_PORT

@waiting_for_output:
    lda     #$01 ; socket 0
    jsr     _ch395_get_int_status_sn
    and     #CH395_SINT_STAT_SEND_OK
    cmp     #CH395_SINT_STAT_SEND_OK
    bne     @waiting_for_output
@exit:
    rts

.endproc

.proc _ch395_get_int_status_sn
	ldx     #CH395_GET_INT_STATUS_SN
    stx     CH395_COMMAND_PORT
    sta     CH395_DATA_PORT
    lda     CH395_DATA_PORT

    rts
.endproc
