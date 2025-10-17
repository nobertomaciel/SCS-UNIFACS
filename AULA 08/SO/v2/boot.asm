; boot.asm - Bootloader mínimo, lê 1 setor para carregar kernel
BITS 16
ORG 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    sti

    ; mensagem inicial do bootloader
    mov si, msg
print_msg:
    lodsb
    or al, al
    jz load_kernel
    mov ah, 0x0E
    int 0x10
    jmp print_msg

; salvar drive de boot
BOOT_DRIVE db 0
mov [BOOT_DRIVE], dl

; carregar kernel
load_kernel:
    mov ah, 0x02           ; função BIOS: ler setores
    mov al, 1              ; 1 setor (512 bytes)
    mov ch, 0              ; cilindro
    mov cl, 2              ; setor inicial do kernel
    mov dh, 0              ; cabeça
    mov dl, [BOOT_DRIVE]   ; drive de boot
    mov bx, 0x8000         ; endereço de destino
    int 0x13
    jc disk_error

    jmp 0x0000:0x8000      ; pular para kernel carregado

disk_error:
    mov si, err_msg
print_err:
    lodsb
    or al, al
    jz $
    mov ah, 0x0E
    int 0x10
    jmp print_err

msg db 'Bootloader iniciado com sucesso!',13,10,0
err_msg db 'Erro ao carregar o kernel!',13,10,0

times 510-($-$$) db 0
dw 0xAA55