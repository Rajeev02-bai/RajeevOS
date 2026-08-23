#ifndef KERNEL_SHELL_H
#define KERNEL_SHELL_H

/* Simple line-oriented command shell driven by keyboard_getchar() and
 * printing via vga.h. Built-ins: help, clear, echo, ls, cat, write. */
void shell_init(void);
void shell_run(void);   /* blocking read-eval-print loop, never returns */

#endif /* KERNEL_SHELL_H */
