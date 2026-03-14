ENTRY(_start)

MEMORY
{
    FLASH (rx) : ORIGIN = 0x00000000, LENGTH = 256K
    SRAM (rwx) : ORIGIN = 0x20000000, LENGTH = 64K
}

SECTIONS
{
    .text : {
        KEEP(*(.vectors))    /* Force the vector table to address 0x0 */
        *(.text*)            /* All other code */
        *(.rodata*)          /* Constant strings */
    } > FLASH

    .data : { *(.data*) } > SRAM AT > FLASH
    .bss : { *(.bss*) } > SRAM
}
