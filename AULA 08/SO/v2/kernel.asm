; kernel.asm - Kernel mínimo, cabendo em 1 setor
BITS 16
ORG 0x8000

KERNEL_START:
    mov si, welcome_msg
    call print_string

    mov si, prompt
    call print_string

main_loop:
    call read_line
    mov si, buffer
    call interpret_command
    jmp main_loop

; ---------------------------------------------------
; print_string: imprime string terminada em 0
; ---------------------------------------------------
print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

; ---------------------------------------------------
; read_line: lê até Enter, suporta backspace
; ---------------------------------------------------
read_line:
    mov di, buffer
.read:
    mov ah, 0
    int 0x16
    cmp al, 13
    je .enter
    cmp al, 8
    je .backspace
    mov ah, 0x0E
    int 0x10
    stosb
    jmp .read
.backspace:
    cmp di, buffer
    jbe .read
    dec di
    mov ah, 0x0E
    mov al, 8
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 8
    int 0x10
    jmp .read
.enter:
    mov al, 0
    stosb
    mov ah, 0x0E
    mov al, 13
    int 0x10
    mov al, 10
    int 0x10
    ret

; ---------------------------------------------------
; interpret_command: apenas HELP e CLEAR
; ---------------------------------------------------
interpret_command:
    mov si, buffer
    mov di, cmd_help
    call strcmp
    jz .cmd_help

    mov si, buffer
    mov di, cmd_clear
    call strcmp
    jz .cmd_clear

    mov si, unknown
    call print_string
    mov si, prompt
    call print_string
    ret

.cmd_help:
    mov si, help_text
    call print_string
    mov si, prompt
    call print_string
    ret

.cmd_clear:
    mov ax, 0x0600
    mov bh, 0x07
    mov cx, 0
    mov dx, 0x184F
    int 0x10
    mov si, prompt
    call print_string
    ret

; ---------------------------------------------------
; strcmp: compara strings em SI e DI, ZF=1 se iguais
; ---------------------------------------------------
strcmp:
.loop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .ne
    cmp al, 0
    je .eq
    inc si
    inc di
    jmp .loop
.eq:
    xor ax, ax
    ret
.ne:
    or ax, 1
    ret

; ---------------------------------------------------
; Dados
; ---------------------------------------------------
welcome_msg db 'Mini SO - Iniciando...',13,10
            db 'Bem-vindo!',13,10,0
prompt      db 'SO>',0
unknown     db 'Comando nao reconhecido',13,10,0
help_text   db 'Comandos disponiveis: HELP, CLEAR',13,10,0
cmd_help    db 'HELP',0
cmd_clear   db 'CLEAR',0
buffer      times 128 db 0

; Preenche até 512 bytes (1 setor)
times 512-($-$$) db 0