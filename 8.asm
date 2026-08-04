; NOTEPAD OS - CORRECTO MANEJO DE CURSOR, VIDEO Y SCROLL (mejorado)
[org 0x7c00]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0x7c00
    sti

    ; Modo texto 80x25
    mov ax, 3
    int 0x10

    mov ax, 0xB800
    mov es, ax
    xor di, di          ; DI = offset en bytes (fila * 160 + col * 2)

main_loop:
    call update_hw_cursor
    xor ah, ah
    int 0x16

    cmp al, 24          ; Ctrl + X para salir
    je halt_sys

    cmp ah, 0x4B        ; Flecha Izquierda
    je move_left

    cmp ah, 0x4D        ; Flecha Derecha
    je move_right

    cmp ah, 0x48        ; Flecha Arriba
    je move_up

    cmp ah, 0x50        ; Flecha Abajo
    je move_down

    cmp al, 8           ; Backspace
    je do_backspace

    cmp al, 13          ; Enter
    je do_enter

    cmp al, 32
    jl main_loop
    cmp al, 126
    jg main_loop

    ; Escribir caracter y atributo en la memoria de video (word write)
    mov ah, 0x07        ; atributo
    mov [es:di], ax     ; mov word [es:di], ax  (NASM admite esta forma)
    add di, 2
    cmp di, 4000
    jge .need_scroll
    jmp main_loop

.need_scroll:
    call scroll_up
    jmp main_loop

move_left:
    cmp di, 0
    jbe main_loop
    sub di, 2
    jmp main_loop

move_right:
    cmp di, 3998
    jge main_loop
    add di, 2
    jmp main_loop

move_up:
    cmp di, 160
    jb main_loop
    sub di, 160
    jmp main_loop

move_down:
    cmp di, 3840
    jae main_loop
    add di, 160
    jmp main_loop

do_backspace:
    cmp di, 0
    je main_loop
    ; si estamos al inicio de línea, saltar a la línea anterior (si existe)
    mov ax, di
    mov bx, 160
    xor dx, dx
    div bx          ; AX = fila, DX = col_bytes/2 (col)
    cmp dx, 0
    jne .del_char
    ; DX==0 => inicio de línea, mover a fila-1, columna final
    cmp ax, 0
    je main_loop
    dec ax
    mul bx          ; AX = (fila-1) * 160
    add ax, 158     ; columna final: 79*2 = 158
    mov di, ax
    jmp .write_space
.del_char:
    sub di, 2
.write_space:
    mov al, ' '
    mov ah, 0x07
    mov [es:di], ax
    jmp main_loop

do_enter:
    mov ax, di
    mov bx, 160
    xor dx, dx
    div bx           ; AX = fila, remainder DX = col/2
    inc ax
    mul bx           ; AX = (fila+1) * 160
    mov di, ax
    cmp di, 4000
    jl main_loop
    ; necesitamos scrollar
    call scroll_up
    jmp main_loop

; desplaza toda la pantalla 1 línea hacia arriba y limpia la última
scroll_up:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds

    ; mover 3840 bytes (1920 words) desde offset 160 -> offset 0
    mov ax, 0xB800
    mov ds, ax
    mov si, 160
    xor di, di
    mov cx, 1920
    cld
    rep movsw

    ; limpiar última línea (80 words) con ' ' + attr 0x07
    mov ax, 0x0720    ; AH=0x07 (atributo), AL=' ' (0x20)
    mov cx, 80
    mov di, 3840
    rep stosw

    ; dejar el cursor en el inicio de la última línea (offset 3840)
    mov di, 3840

    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

update_hw_cursor:
    push ax
    push bx
    push dx

    mov ax, di
    shr ax, 1           ; Convertir offset de bytes a posición de celda (0 - 1999)
    mov bx, ax          ; Guardar posición en BX

    ; Enviar parte baja del cursor
    mov dx, 0x03D4
    mov al, 0x0F
    out dx, al
    inc dx
    mov al, bl
    out dx, al

    ; Enviar parte alta del cursor
    dec dx
    mov al, 0x0E
    out dx, al
    inc dx
    mov al, bh
    out dx, al

    pop dx
    pop bx
    pop ax
    ret

halt_sys:
    cli
    hlt

times 510-($-$$) db 0
dw 0xAA55