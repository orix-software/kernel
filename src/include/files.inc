.include "_file.inc"

.struct _KERNEL_FILE
        f_fd        .byte
        f_flags     .byte ; Fopen, closed etc
        f_mode      .byte ; Read only or not
        f_pushback  .byte
        f_seek_file .res 4 ; 32 bits offset
        f_path      .res KERNEL_MAX_PATH_LENGTH
.endstruct
