#ifndef KERNEL_KEYBOARD_H
#define KERNEL_KEYBOARD_H

/* Registers an IRQ1 handler that translates PS/2 scancodes (set 1) to
 * ASCII and pushes them into an internal ring buffer. */
void keyboard_init(void);

int  keyboard_has_char(void);   /* 1 if a character is buffered */
char keyboard_getchar(void);    /* blocking: spins (with hlt) until a key arrives */

#endif /* KERNEL_KEYBOARD_H */
