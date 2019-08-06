.define ORIX_MAX_PROCESS                   4
.define KERNEL_MAX_PROCESS	               ORIX_MAX_PROCESS ; max 84 because kernel_process_struct is handle with 8 bits offsets
.define KERNEL_NUMBER_OF_CHILD_PER_PROCESS 1
.define KERNEL_MAX_LENGTH_COMMAND          8

; This struct is always present in memory and is allocated by tag. It's the main table for process list
.struct kernel_process_struct
kernel_pid_list                      .res KERNEL_MAX_PROCESS
kernel_one_process_struct_ptr_low    .res KERNEL_MAX_PROCESS
kernel_one_process_struct_ptr_high   .res KERNEL_MAX_PROCESS
kernel_next_process_pid              .res 1
kernel_init_string                   .res .strlen("init")+1
kernel_cwd_str                       .res .strlen("/")+1
.endstruct

.if     .sizeof(kernel_process_struct) > 255
  .error  "kernel_process_struct size is greater than 255. It's impossible because code does not handle a struct greater than 255"
.endif

; This struct is used with a malloc. Each proces has this struct, and the pointer of this struct is in kernel_process_struct struct 
.struct kernel_one_process_struct
process_name        .res KERNEL_MAX_LENGTH_COMMAND+1
cwd_str             .res KERNEL_MAX_PATH_LENGTH
child_pid           .res KERNEL_NUMBER_OF_CHILD_PER_PROCESS
.endstruct 

.if     .sizeof(kernel_one_process_struct) > 255
  .error  "kernel_one_process_struct size is greater than 255. It's impossible because code does not handle a struct greater than 255"
.endif

