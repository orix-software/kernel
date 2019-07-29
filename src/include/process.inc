.define ORIX_MAX_PROCESS                   4
.define KERNEL_MAX_PROCESS	               ORIX_MAX_PROCESS
.define KERNEL_NUMBER_OF_CHILD_PER_PROCESS 1

.struct kernel_process_struct
child_pid                       .res KERNEL_MAX_PROCESS*KERNEL_NUMBER_OF_CHILD_PER_PROCESS
kernel_one_process_struct_ptr   .res KERNEL_MAX_PROCESS*2
.endstruct

.struct kernel_one_process_struct
cwd_str             .res KERNEL_MAX_PATH_LENGTH
child_pid           .res KERNEL_NUMBER_OF_CHILD_PER_PROCESS
.endstruct 
