.section .multiboot
.code32
.align 8
    .set MAGIC2, 0xe85250d6
    .set ARCH2, 0
    .set CHECKSUM2, (-(MAGIC2 + ARCH2 + (mboot2_end - mboot2_start)) & 0xffffffff)

mboot2_start:
    .long MAGIC2
    .long ARCH2
    .long mboot2_end - mboot2_start
    .long CHECKSUM2
    .word 0
    .word 0
    .long 8
mboot2_end:

.section .bss
.align 16
stack_bottom:
.skip 16384
stack_top:

.section .text
.code32
.extern kernel_main
.global _start
.type _start, @function
_start:
    mov $stack_top, %esp
    call kernel_main
    cli
1:  hlt
    jmp 1b

.size _start, . - _start
