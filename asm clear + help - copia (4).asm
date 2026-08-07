[org 0x7c00]          ; Dirección de carga estándar de la BIOS para el MBR
[bits 16]             ; Modo real de 16 bits

start:
    xor ax, ax        ; AX = 0
    mov ds, ax        ; Data Segment a 0
    mov es, ax        ; Extra Segment a 0
    mov ss, ax        ; Stack Segment a 0
    mov sp, 0x7c00    ; Stack debajo del bootloader

    call limpiar_pantalla
    call mostrar_banner

ciclo_principal:
    mov si, prompt
    call imprimir_cadena

    call leer_entrada

    ; Comparar con "help"
    mov si, buffer
    mov di, cmd_help
    call comparar_cadenas
    jc accion_help

    ; Comparar con "ayuda"
    mov si, buffer
    mov di, cmd_ayuda
    call comparar_cadenas
    jc accion_help

    ; Comparar con "clear"
    mov si, buffer
    mov di, cmd_clear
    call comparar_cadenas
    jc accion_clear

    ; Si no es ninguno, error
    mov si, msg_error
    call imprimir_cadena
    jmp ciclo_principal

; --- Acciones ---
accion_help:
    mov si, msg_help_txt
    call imprimir_cadena
    jmp ciclo_principal

accion_clear:
    call limpiar_pantalla
    jmp ciclo_principal

; --- Rutinas de Pantalla y Teclado ---
limpiar_pantalla:
    mov ah, 0x00
    mov al, 0x03      ; Modo texto 80x25 (limpia la pantalla al cambiar)
    int 0x10
    ret

mostrar_banner:
    mov si, msg_banner
    call imprimir_cadena
    ret

imprimir_cadena:
    lodsb             ; Cargar byte desde SI a AL
    or al, al         ; ¿Es el fin de cadena (0)?
    jz .fin
    mov ah, 0x0e      ; Función teletipo de BIOS
    int 0x10
    jmp imprimir_cadena
.fin:
    ret

leer_entrada:
    mov di, buffer
.bucle_tecla:
    mov ah, 0x00
    int 0x16          ; Esperar pulsación de tecla
    
    cmp al, 0x0d      ; ¿Enter presionado?
    je .fin_lectura

    cmp al, 0x08      ; ¿Retroceso (Backspace)?
    je .retroceso

    cmp di, buffer + 30 ; Límite del buffer
    jge .bucle_tecla

    stosb             ; Guardar caracter en buffer
    mov ah, 0x0e
    int 0x10          ; Mostrar eco en pantalla
    jmp .bucle_tecla

.retroceso:
    cmp di, buffer
    jle .bucle_tecla
    dec di
    mov byte [di], 0
    mov ah, 0x0e
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp .bucle_tecla

.fin_lectura:
    mov byte [di], 0  ; Fin de cadena nulo
    mov si, msg_nl
    call imprimir_cadena
    ret

comparar_cadenas:
    push si
    push di
.bucle_comp:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .no_coincide
    cmp al, 0
    je .coincide
    inc si
    inc di
    jmp .bucle_comp

.coincide:
    pop di
    pop si
    stc               ; Carry Flag activo = Coincidencia exacta
    ret

.no_coincide:
    pop di
    pop si
    clc               ; Carry Flag inactivo = No coincide
    ret

; --- Datos ---
msg_banner   db '=== MINI OS ASM (16-bit) ===', 13, 10
             db 'Escribe "help" o "clear"', 13, 10, 13, 10, 0
prompt       db 'root#> ', 0
msg_nl       db 13, 10, 0

cmd_help     db 'help', 0
cmd_ayuda    db 'ayuda', 0
cmd_clear    db 'clear', 0

msg_help_txt db 'Comandos disponibles:', 13, 10
             db '  help  - Muestra este menu', 13, 10
             db '  clear - Limpia la pantalla', 13, 10, 0

msg_error    db 'Comando no reconocido. Usa "help".', 13, 10, 0

buffer       times 32 db 0

; --- Relleno y Firma MBR obligatorios ---
times 510-($-$$) db 0   ; Rellenar con ceros hasta el byte 510
dw 0xaa55             ; Firma de arranque MBR (últimos 2 bytes)