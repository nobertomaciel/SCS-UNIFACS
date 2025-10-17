; kernel.asm - Kernel mínimo
BITS 16
ORG 0x8000

start:
    mov si, msg         ; SI aponta para a mensagem

print_loop:
    lodsb               ; carrega byte de DS:SI em AL e incrementa SI
    or al, al           ; verifica se AL == 0 (fim da string)
    jz hang             ; se zero → fim da mensagem, pula para hang
    mov ah, 0x0E        ; função BIOS: imprimir caractere
    int 0x10
    jmp print_loop

hang:
    jmp hang            ; trava aqui (loop infinito)

msg db 'Kernel rodando com sucesso!', 0