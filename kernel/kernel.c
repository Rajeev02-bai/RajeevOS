#include <stdint.h>
 
#include "kernel/vga.h"
#include "kernel/serial.h"
#include "kernel/idt.h"
#include "kernel/timer.h"
#include "kernel/keyboard.h"
#include "kernel/pmm.h"
#include "kernel/paging.h"
#include "kernel/kheap.h"
#include "kernel/ata.h"
#include "kernel/fs.h"
#include "kernel/shell.h"
 
#define KERNEL_PHYS_END    0x400000u              /* 4MB: kernel + pmm bitmap live below this */
#define TOTAL_MEM_BYTES    (64u * 1024u * 1024u)   /* assumes `qemu-system-i386 -m 64` */
#define HEAP_START         0x400000u
#define HEAP_INITIAL_SIZE  (4u * 1024u * 1024u)    /* 4MB initial kernel heap */
#define TIMER_HZ           100u
 
static void banner(void)
{
    vga_set_color(VGA_COLOR_LIGHT_GREEN, VGA_COLOR_BLACK);
    vga_puts("MyOS booting...\n");
    vga_set_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
}
 
void kernel_main(void)
{

    serial_init();
    serial_write_string("[kernel] serial online\n");
 
    vga_init();
    vga_clear();
    banner();
 
    idt_init();
    serial_write_string("[kernel] idt installed, pic remapped\n");
 
    pmm_init(TOTAL_MEM_BYTES, KERNEL_PHYS_END);
    serial_write_string("[kernel] pmm initialized\n");
 
    paging_init(TOTAL_MEM_BYTES);
    serial_write_string("[kernel] paging enabled\n");
 
    kheap_init(HEAP_START, HEAP_INITIAL_SIZE);
    serial_write_string("[kernel] heap initialized\n");
 
    timer_init(TIMER_HZ);
    serial_write_string("[kernel] pit timer initialized\n");
 
    keyboard_init();
    serial_write_string("[kernel] keyboard initialized\n");
 
    ata_init();
    serial_write_string("[kernel] ata driver initialized\n");
 
    fs_init();
    serial_write_string("[kernel] filesystem initialized\n");
 
    __asm__ __volatile__ ("sti");
    serial_write_string("[kernel] interrupts enabled\n");
 
    shell_init();
    vga_puts("\nWelcome to MyOS. Type 'help' for a list of commands.\n");
    shell_run();
 
    for (;;) {
        __asm__ __volatile__ ("hlt");
    }
}
