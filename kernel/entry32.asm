; ============================================================================
; entry32.asm - 32-bit protected-mode kernel entry point
;
; This is where stage2.asm jumps once the kernel image has been copied to
; 0x100000 (1MB). It should be the ENTRY point in linker.ld, e.g.:
;
;     ENTRY(_start)
;     SECTIONS { . = 0x100000; ... }
;
; Sets up a dedicated kernel stack (separate from stage2's temporary one)
; and calls into kernel_main() in kernel.c. Also exposes small helpers for
; enabling/disabling interrupts and loading the IDT, used by idt.c.
; ============================================================================
 
BITS 32
 
extern kernel_main
 
section .text
 
global _start
_start:
    cli
    mov esp, stack_top
    mov ebp, esp
 
    call kernel_main
 
.hang:
    cli
    hlt
    jmp .hang
 
; ----------------------------------------------------------------------------
; global idt_flush(uint32_t idt_ptr) - loads the IDT register.
; Called from idt.c after building the IDT and idt_ptr_t.
; ----------------------------------------------------------------------------
global idt_flush
idt_flush:
    mov eax, [esp + 4]
    lidt [eax]
    ret
 
section .bss
align 16
stack_bottom:
    resb 16384              ; 16 KiB kernel stack
stack_top:
 
