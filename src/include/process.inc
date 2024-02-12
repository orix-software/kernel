.define KERNEL_MAX_PROCESS	                       4  ; max 84 because kernel_process_struct is handle with 8 bits offsets
.define KERNEL_NUMBER_OF_CHILD_PER_PROCESS         1
.define KERNEL_MAX_LENGTH_COMMAND                  8
.define KERNEL_MAX_FP_PER_PROCESS                  2  ; Can't be greater than KERNEL_MAX_FP
.define KERNEL_MAX_FP                              2  ; Max filepointers availables
.define KERNEL_USERZP_SAVE_LENGTH                  16 ; Each process has userzp variable, this value says that the kernel needs to save this size
.define KERNEL_LENGTH_MAX_CMDLINE                  37

.define KERNEL_ERRNO_OK                            0
; ERRNO KERNEL are set in errno.inc of cc65 from 1 to 18
.define KERNEL_ERRNO_REACH_MAX_FP_FOR_A_PROCESS    20
.define KERNEL_ERRNO_XFREE_NO_CHUNK_FOUND          21
.define KERNEL_ERRNO_MAX_PROCESS_REACHED           22

.define KERNEL_PROCESS_STRUCT_MALLOC_TYPE          $10
.define KERNEL_UNKNOWN_MALLOC_TYPE                 $11
.define KERNEL_BINARY_MALLOC_TYPE                  $12
.define KERNEL_PROCESS_MALLOC_TYPE                 $13
.define KERNEL_XMAINARG_MALLOC_TYPE                $14
.define KERNEL_FP_MALLOC_TYPE                      $15

; This struct is always present in memory and is allocated by tag. It's the main table for process list

; kernel_pid_list contains the id of the process it means that if the current process is 5,

; Init struct
.struct kernel_process_struct
  ; don't move kernel_pid_list in an other line because it breaks ps and lsmem
  kernel_pid_list                      .res KERNEL_MAX_PROCESS ; list of PID when the byte is equal to 0, it means that this is free, it store the index
  kernel_current_process               .res 1                  ; id of the current pid (French, contient l'index et non pas la valeur, l'index sur la table kernel_pid_list)
  kernel_one_process_struct_ptr_low    .res KERNEL_MAX_PROCESS
  kernel_one_process_struct_ptr_high   .res KERNEL_MAX_PROCESS
  ;kernel_init_string                   .res .strlen("init")+1
  kernel_cwd_str                       .res .strlen("/")+1
  fp_ptr                               .res KERNEL_MAX_FP_PER_PROCESS*2 ; fp for init for instance, only shell could be in it
  ; kernel_fd contains ...
  kernel_fd                            .res KERNEL_MAX_FP ; Va contenir l'id du process qui possède ce FD
  kernel_fd_opened                     .res 1 ; the id of the current fd opened
  ;kernel_process_addr                  .res KERNEL_MAX_PROCESS*2
  ;kernel_next_fd                       .res 1
  ;kernel_max_process_value             .res 1
.endstruct

.out     .sprintf("KERNEL_MAX_PROCESS (Max process in the system)           : %s", .string(KERNEL_MAX_PROCESS))
.out     .sprintf("KERNEL_MAX_FP_PER_PROCESS  (Max file pointer per process): %s", .string(KERNEL_MAX_FP_PER_PROCESS))
.out     .sprintf("KERNEL_USERZP_SAVE_LENGTH                                : %s bytes", .string(KERNEL_USERZP_SAVE_LENGTH))
.out     .sprintf("KERNEL_LENGTH_MAX_CMDLINE                                : %s", .string(KERNEL_LENGTH_MAX_CMDLINE))

.out     .sprintf("kernel_process_struct size (struct init process)         : $%X bytes", .sizeof(kernel_process_struct))

.if     .sizeof(kernel_process_struct) > 255
  .error  "kernel_process_struct size is greater than 255. It's impossible because code does not handle a struct greater than 255"
.endif

; This struct is used with a malloc. Each proces has this struct, and the pointer of this struct is in kernel_process_struct struct
.struct kernel_one_process_struct
  process_name               .res KERNEL_MAX_LENGTH_COMMAND+1 ; don't move it in the struct, because code handle process_name when it's at the first position. If it moves, the code will generate bugs
  cwd_str                    .res KERNEL_MAX_PATH_LENGTH
 ; child_pid                  .res KERNEL_NUMBER_OF_CHILD_PER_PROCESS
  fp_ptr                     .res KERNEL_MAX_FP_PER_PROCESS*2
  zp_save_userzp             .res KERNEL_USERZP_SAVE_LENGTH
  cmdline                    .res KERNEL_LENGTH_MAX_CMDLINE
  ppid                       .res 1
  kernel_process_addr        .res 2 ; Adress of the program
  ;bank_id                    .res 1
  ;is_rom_command             .res 1 ; 0 is file in memory, else it's ROM (1)
 ; twilighte_register_command .res 1
  .ifdef WITH_KERNEL_PROCESS_UID
 ; uid                        .res 1
  .endif
  .ifdef WITH_KERNEL_PROCESS_GID
  ;gid                        .res 1
  .endif
.endstruct

.out     .sprintf("kernel_one_process_struct size (struct for one process)  : $%X bytes", .sizeof(kernel_one_process_struct))

.if     .sizeof(kernel_one_process_struct) > 255
  .error  "kernel_one_process_struct size is greater than 255. It's impossible because code does not handle a struct greater than 255"
.endif

.out   .sprintf("With all the parameter all process could use %s bytes in memory, if it's allocated", .string(.sizeof(kernel_one_process_struct)*KERNEL_MAX_PROCESS+.sizeof(kernel_process_struct)))
