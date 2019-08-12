.export XGETCWD_ROUTINE

.proc XGETCWD_ROUTINE
    ldx     ORIX_CURRENT_PROCESS_FOREGROUND

            
    lda     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_low,x
    sta     RESB


    lda     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_high,x
    sta     RESB+1


    lda     #kernel_one_process_struct::cwd_str
    clc
    adc     RESB
    bcc     @S1 
    inc     RESB+1
@S1:
    ; A contains the compute

    ldy     RESB+1
    

    rts
.endproc
