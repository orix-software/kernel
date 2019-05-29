.define ORIX_MAX_PROCESS                   4
.define KERNEL_NUMBER_OF_CHILD_PER_PROCESS 1

.struct kernel_process_struct
child_pid           .res ORIX_MAX_PROCESS*KERNEL_NUMBER_OF_CHILD_PER_PROCESS
list_name_ptr_pid   .res ORIX_MAX_PROCESS*2
.endstruct

