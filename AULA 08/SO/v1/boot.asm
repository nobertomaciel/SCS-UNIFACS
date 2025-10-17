[org 0x7C00]
BITS 16

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov [BOOT_DRIVE], dl       ; guarda o drive de boot

    ; --- Mensagem ---
    mov si, msg
print:
    lodsb
    or al, al
    jz load_kernel
    mov ah, 0x0E
    int 0x10
    jmp print

; --- Leitura do kernel ---
load_kernel:
    mov ah, 0x02        ; BIOS read
    mov al, 1           ; 1 setor
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, [BOOT_DRIVE]
    mov bx, 0x8000
    int 0x13
    jc disk_error

    jmp 0x0000:0x8000

disk_error:
    mov si, err
err_loop:
    lodsb
    or al, al
    jz $
    mov ah, 0x0E
    int 0x10
    jmp err_loop

msg db 'Bootloader iniciado com sucesso!', 0
err db 'Erro ao carregar o kernel!', 0
BOOT_DRIVE db 0

times 510-($-$$) db 0
dw 0xAA55