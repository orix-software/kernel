; Number of all CURRENT malloc. If we reached this number, we won't be able to do a new malloc
.define KERNEL_MAX_NUMBER_OF_MALLOC      6
.define KERNEL_MALLOC_FREE_FRAGMENT_MAX  5
.define KERNEL_MALLOC_FREE_CHUNK_MAX     5
.define KERNEL_MALLOC_MAX_MEM_ADRESS     $B3FF ; We can't do malloc greater than this offset


.struct kernel_malloc_struct
kernel_malloc_free_chunk_begin_low        .res KERNEL_MALLOC_FREE_CHUNK_MAX
kernel_malloc_free_chunk_begin_high       .res KERNEL_MALLOC_FREE_CHUNK_MAX

kernel_malloc_free_chunk_end_low          .res KERNEL_MALLOC_FREE_CHUNK_MAX
kernel_malloc_free_chunk_end_high         .res KERNEL_MALLOC_FREE_CHUNK_MAX

kernel_malloc_busy_chunk_begin_high       .res KERNEL_MAX_NUMBER_OF_MALLOC
kernel_malloc_busy_chunk_begin_low        .res KERNEL_MAX_NUMBER_OF_MALLOC

kernel_malloc_busy_chunk_end_high         .res KERNEL_MAX_NUMBER_OF_MALLOC
kernel_malloc_busy_chunk_end_low          .res KERNEL_MAX_NUMBER_OF_MALLOC


kernel_malloc_busy_pid_list               .res KERNEL_MAX_NUMBER_OF_MALLOC ; We store the PID of the malloc
kernel_malloc_max_memory_main             .res 1  ; in KB

; size of the chunk, it is store instead of compute (it's quicker for tools or primitives,but it requires more memory)
kernel_malloc_busy_chunk_size_high         .res KERNEL_MAX_NUMBER_OF_MALLOC
kernel_malloc_busy_chunk_size_low          .res KERNEL_MAX_NUMBER_OF_MALLOC

kernel_malloc_free_chunk_size_high         .res KERNEL_MAX_NUMBER_OF_MALLOC
kernel_malloc_free_chunk_size_low          .res KERNEL_MAX_NUMBER_OF_MALLOC
kernel_malloc_type                         .res KERNEL_MAX_NUMBER_OF_MALLOC
.endstruct

.out     "=================================================================="
.out     "Memory"
.out     "=================================================================="
.out     .sprintf("KERNEL_MAX_NUMBER_OF_MALLOC (max malloc for all process) : %s", .string(KERNEL_MAX_NUMBER_OF_MALLOC))
.out     .sprintf("kernel_malloc_struct size (malloc table)                 : %s bytes", .string(.sizeof(kernel_malloc_struct)))

.if     .sizeof(kernel_malloc_struct) > 255
  .error  "kernel_malloc_struct size is greater than 255. It's impossible because code does not handle a struct greater than 255"
.endif
  
