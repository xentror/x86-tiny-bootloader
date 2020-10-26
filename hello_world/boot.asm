_start:
    mov ax, 0x7C0
    mov ds, ax
    mov ax, 0x7E0
    mov ss, ax

    mov sp, 0x2000

    call  clear_window
    hlt

clear_window:
    push bp
    mov bp, sp
    pusha

    mov ah, 0x07
    xor al, al
    mov bh, 0x07
    mov ch, 0x0
    mov cl, 0x0
    mov dh, 0x18
    mov dl, 0x4f
    int 0x10

    popa
    mov sp, bp
    pop bp
    ret

times  510-($-$$) db 0
dw 0xAA55
