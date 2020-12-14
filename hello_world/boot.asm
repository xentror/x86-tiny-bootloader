_start:
    mov ax, 0x7C0
    mov ds, ax ; put data segment at same address as cs
    mov es, ax ; put extra segment at same address as cs
    mov ax, 0x7E0 ; create stack 512 bytes after cs -- next sector
    mov ss, ax

    mov sp, 0x2000 ; instanciante stack pointer

    call clear_window
    call reset_cursor
    call write_string

    hlt

reset_cursor:
    push bp
    mov bp, sp
    pusha

    mov ah, 0x02
    mov bh, 0x0
    mov dh, 0x0
    mov dl, 0x0
    int 0x10

    popa
    mov sp, bp
    pop bp
    ret

write_string:
    push bp
    mov bp, sp
    pusha

    mov ah, 0x13
    mov al, 0x1 ; update cursor after writing
    mov bh, 0x0
    mov bl, 0x02
    mov cx, msg_end - msg
    mov dx, 0x0

    push bp
    mov bp, msg
    int 0x10
    pop bp

    popa
    mov sp, bp
    pop bp
    ret

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

msg: db "Hey You ! :)"
msg_end: db 0

times  510-($-$$) db 0
dw 0xAA55
