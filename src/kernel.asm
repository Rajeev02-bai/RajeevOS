; kernel.asm — placeholder, just proves the jump worked
[BITS 16]
[ORG 0x1000]
mov si, msg
call print_string
jmp $

print_string:
    mov ah, 0x0E
.next:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .next
.done:
    ret

msg: db "Kernel loaded and running!", 0
