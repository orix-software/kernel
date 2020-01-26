.include "_file.inc"

.struct _KERNEL_FILE
        f_fd        .byte
        f_flags     .byte ; Fopen, closed etc
        f_mode      .byte ; Read only or not
        f_pushback  .byte
        f_seek_file .res 4 ; 32 bits offset
        f_path      .res KERNEL_MAX_PATH_LENGTH
.endstruct


.if     KERNEL_MAX_PATH_LENGTH+_KERNEL_FILE::f_path > 255
  .error  "_KERNEL_FILE::path is too far from 0 or KERNEL_MAX_PATH_LENGTH is too long, in that case some routines won't work because it overflow 255 as XOPEN"
  .error  "We  reached this condition : KERNEL_MAX_PATH_LENGTH+_KERNEL_FILE::f_path > 255"

.endif
