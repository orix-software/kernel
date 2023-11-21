.include "_file.inc"

.struct _KERNEL_FILE
        ;f_fd        .byte
        f_flags     .byte ; Fopen, closed etc
        f_mode      .byte ; Read only or not
        f_pushback  .byte
        f_path      .res KERNEL_MAX_PATH_LENGTH
        ; When f_path is after f_seek_file here , XOPEN is broken ... BUG, FIXME
        f_seek_file .res 4 ; 32 bits offset
.endstruct


.out     "=================================================================="
.out     "File memory"
.out     "=================================================================="
.out     .sprintf("_KERNEL_FILE size (One fp struct) : $%X bytes",  .sizeof(_KERNEL_FILE))

.struct _EXT_FILE
        f_flags     .byte ; Fopen, closed etc
        f_mode      .byte ; Read only or not
        f_pushback  .byte
;        f_path      .res KERNEL_MAX_PATH_LENGTH
.endstruct

.if     KERNEL_MAX_PATH_LENGTH+_KERNEL_FILE::f_path > 255
  .error  "_KERNEL_FILE::path is too far from 0 or KERNEL_MAX_PATH_LENGTH is too long, in that case some routines won't work because it overflow 255 as XOPEN"
  .error  "We  reached this condition : KERNEL_MAX_PATH_LENGTH+_KERNEL_FILE::f_path > 255"
.endif

.struct _READDIR_STRUCT
; Entrée du catalogue:
;   Offset              Description
;   00-07               Filename
;   08-0A               Extension
;   0B                  File attributes
;                           0x01: Read only
;                           0x02: Hidden
;                           0x04: System
;                           0x08: Volume label
;                           0x10: Subdirectory
;                           0x20: Archive
;                           0x40: Device (internal use only)
;                           0x80: Unused
;   0C                  Reserved
;   0D                  Create time: fine resolution (10ms) 0 -> 199
;   0E-0F               Create time: Hour, minute, second
;                            bits
;                           15-11: Hour  (0-23)
;                           10- 5: Minutes (0-59)
;                            4- 0: Seconds/2 (0-29)
;   10-11               Create time:Year, month, day
;                            bits
;                           15- 9: Year (0->1980, 127->2107)
;                            8- 5: Month (1->Jan, 12->Dec)
;                            4- 0: Day (1-31)
;   12-13               Last access date
;   14-15               EA index
;   16-17               Last modified time
;   18-19               Last modified date
;   1A-1B               First cluster
;   1C-1F               File size
        filename    .res 12
        attributes  .res 1
        garbage     .res 19
.endstruct

.define KERNEL_FIRST_FD 3
