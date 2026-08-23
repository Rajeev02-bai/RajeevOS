#ifndef KERNEL_TIMER_H
#define KERNEL_TIMER_H

#include <stdint.h>

/* Programs PIT channel 0 to fire IRQ0 at `frequency_hz` and registers
 * the tick handler with the IDT (via register_interrupt_handler). */
void timer_init(uint32_t frequency_hz);

uint32_t timer_get_ticks(void);
void timer_wait(uint32_t ticks);          /* busy-wait N ticks */
void timer_sleep_ms(uint32_t ms);         /* convenience wrapper */

#endif /* KERNEL_TIMER_H */
