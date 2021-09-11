CH395_COMMAND_PORT            := $381
CH395_DATA_PORT               := $380
CH395_WRITE_SEND_BUF_SN       = $39



; void ch395_write_send_buf_sn(unsigned char *msg, unsigned int length,unsigned char ID_SOCKET)

.proc _ch395_write_send_buf_sn

    ldx     #CH395_WRITE_SEND_BUF_SN
    stx     CH395_COMMAND_PORT
    ldx     #$01 ; Socket 1
    stx     CH395_DATA_PORT


    ldx     #$01
    stx     CH395_DATA_PORT ; set length
    dex
    stx     CH395_DATA_PORT ; set length
    
    sta     $bb80+120
    sta     CH395_DATA_PORT 

    rts

.endproc
