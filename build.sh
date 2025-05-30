#!/bin/bash

set -e

mkdir -p build out

BOOTLOADER_FILES=$(find kernel/boot/x86_64 -name '*.s')
KERNEL_FILES=$(find kernel/ -name '*.c')

CFLAGS=$(echo '-m64 -c -std=gnu11 -ffreestanding -z max-page-size=0x1000 -mno-red-zone -mno-mmx -mno-sse2 -Wall -Wextra -pedantic')

echo 'Building bootstrap'
for bootloader_file in $BOOTLOADER_FILES
do
    out_file=$(basename $bootloader_file .s).o
    x86_64-elf-as $bootloader_file -o build/$out_file
    echo "Done $out_file"
done

echo 'Finished'
echo
echo 'Building kernel'

for kernel_file in $KERNEL_FILES
do
    out_file=$(basename $kernel_file .c).o
    x86_64-elf-gcc $CFLAGS $kernel_file -o build/$out_file
    echo "Done $out_file"
done

echo 'Finished'
echo
echo 'Linking...'

OBJ_FILES=$(find build/ -name '*.o')
x86_64-elf-ld -z max-page-size=0x1000 -T kernel/linker.ld -o out/kernel.elf $OBJ_FILES

echo 'Done linking'
echo
echo 'Testing multiboot'

if grub-file --is-x86-multiboot2 out/kernel.elf; then
    echo 'Multiboot confirmed'
else
    echo 'Output is not multiboot'
    exit 1
fi

echo 'Making ISO'

mkdir -p isodir/boot/grub
cp out/kernel.elf isodir/boot/kernel.elf
cp grub.cfg isodir/boot/grub/grub.cfg
grub-mkrescue -o kernel.iso isodir
