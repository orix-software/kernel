; Number of all CURRENT malloc. If we reached this number, we won't be able to do a new malloc
.define KERNEL_MAX_NUMBER_OF_MALLOC      4
.define KERNEL_MALLOC_FREE_FRAGMENT_MAX  6
.define KERNEL_MALLOC_BUSY_TABLE_SIZE    6*KERNEL_NUMBER_OF_MALLOC  
.define KERNEL_MALLOC_FREE_CHUNK_MAX     6

ORIX_MALLOC_FREE_FRAGMENT_MAX = 6


ORIX_MALLOC_MAX_MEM_ADRESS = $B3FF

KERNEL_MALLOC_MAX_MEM_ADRESS = $B3FF

KERNEL_MALLOC_FREE_TABLE_SIZE  =        3*KERNEL_MALLOC_FREE_FRAGMENT_MAX ; ??? 


ORIX_MALLOC_FREE_TABLE_SIZE  = 3*ORIX_MALLOC_FREE_FRAGMENT_MAX
ORIX_MALLOC_BUSY_TABLE_SIZE  = 6*KERNEL_MAX_NUMBER_OF_MALLOC



.struct kernel_malloc_struct
kernel_malloc_free_chunk_list_low          .res KERNEL_MALLOC_FREE_CHUNK_MAX
kernel_malloc_free_chunk_list_high         .res KERNEL_MALLOC_FREE_CHUNK_MAX

kernel_malloc_busy_chunk_list_high         .res KERNEL_MAX_NUMBER_OF_MALLOC
kernel_malloc_busy_chunk_list_low          .res KERNEL_MAX_NUMBER_OF_MALLOC

kernel_malloc_busy_pid_list                     .res KERNEL_MAX_NUMBER_OF_MALLOC
kernel_malloc_max_memory_main              .res 1  ; in KB
.endstruct

.if     .sizeof(kernel_malloc_struct) > 255
  .error  "kernel_malloc_struct size is greater than 255. It's impossible because code does not handle a struct greater than 255"
.endif
  
