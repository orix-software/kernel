ORIX_NUMBER_OF_MALLOC  = 3

KERNEL_NUMBER_OF_MALLOC = 3

ORIX_MALLOC_FREE_FRAGMENT_MAX = 6

KERNEL_MALLOC_FREE_FRAGMENT_MAX = 6

ORIX_MALLOC_MAX_MEM_ADRESS = $B3FF

KERNEL_MALLOC_MAX_MEM_ADRESS = $B3FF

KERNEL_MALLOC_FREE_TABLE_SIZE  = 3*KERNEL_MALLOC_FREE_FRAGMENT_MAX ; ??? 
KERNEL_MALLOC_BUSY_TABLE_SIZE  = 6*KERNEL_NUMBER_OF_MALLOC        ; ???

ORIX_MALLOC_FREE_TABLE_SIZE  = 3*ORIX_MALLOC_FREE_FRAGMENT_MAX
ORIX_MALLOC_BUSY_TABLE_SIZE  = 6*ORIX_NUMBER_OF_MALLOC
