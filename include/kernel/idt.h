#ifndef KERNEL_IDT_H
#define KERNEL_IDT_H

#include <stdint.h>

/* One IDT gate descriptor (interrupt gate, 32-bit). */
typedef struct {
    uint16_t base_low;
    uint16_t sel;
    uint8_t  always0;
    uint8_t  flags;
    uint16_t base_high;
} __attribute__((packed)) idt_entry_t;

typedef struct {
    uint16_t limit;
    uint32_t base;
} __attribute__((packed)) idt_ptr_t;

/* Register snapshot pushed by isr.asm/irq.asm stubs before calling the
 * common C dispatcher -- isr.c / irq.c build these before invoking the
 * handler registered via register_interrupt_handler(). */
typedef struct {
    uint32_t ds;
    uint32_t edi, esi, ebp, esp, ebx, edx, ecx, eax;
    uint32_t int_no, err_code;
    uint32_t eip, cs, eflags, useresp, ss;
} registers_t;

typedef void (*isr_handler_t)(registers_t *regs);

/* Implemented in idt.c: builds the 256-entry IDT (ISRs 0-31, IRQs 32-47),
 * remaps the PIC, and loads it via idt_flush() (defined in entry32.asm). */
void idt_init(void);
void idt_set_gate(uint8_t num, uint32_t base, uint16_t sel, uint8_t flags);

/* Implemented in isr.c/irq.c: lets drivers (timer, keyboard, ...) hook a
 * specific interrupt number without touching the IDT directly. */
void register_interrupt_handler(uint8_t n, isr_handler_t handler);

/* Defined in entry32.asm */
extern void idt_flush(uint32_t idt_ptr_addr);

#endif /* KERNEL_IDT_H */
