; ============================================================================
; switch_pm.asm - Flat GDT and the real-mode -> protected-mode transition.
;
; This file is %included directly into stage2.asm (not assembled on its
; own). It expects to be included while still in BITS 16 real-mode code,
; and it switches to BITS 32 internally. After switch_to_pm runs, execution
; continues at the label BEGIN_PM, which must be defined by whatever file
; includes this one (stage2.asm defines it after the %include).
; ============================================================================
 
; ---------------------------------------------------------------------------
; Flat GDT: one null descriptor, one 4GB code segment, one 4GB data segment.
; ---------------------------------------------------------------------------
gdt_start:
 
gdt_null:
    dq 0x0
 
gdt_code:                      ; 0x08
    dw 0xFFFF                  ; limit (low)
    dw 0x0                     ; base (low)
    db 0x0                     ; base (mid)
    db 10011010b               ; access: present, ring0, code, executable, readable
    db 11001111b               ; flags: 4K granularity, 32-bit + limit (high)
    db 0x0                     ; base (high)
 
gdt_data:                      ; 0x10
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10010010b               ; access: present, ring0, data, writable
    db 11001111b
    db 0x0
 
gdt_end:
 
gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; GDT size, always one less than actual size
    dd gdt_start                ; GDT linear address
 
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start
 
; ---------------------------------------------------------------------------
; switch_to_pm - enables the A20-independent protected mode bit in CR0,
; loads the GDT, and far-jumps into 32-bit code to flush the prefetch queue.
; ---------------------------------------------------------------------------
switch_to_pm:
    cli
    lgdt [gdt_descriptor]
 
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
 
    jmp CODE_SEG:init_pm        ; far jump -> flushes CPU pipeline, loads CS
 
BITS 32
init_pm:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
 
    mov ebp, 0x90000            ; temporary protected-mode stack, well below 1MB
    mov esp, ebp
 
    jmp BEGIN_PM                ; hand control back to stage2.asm
 
