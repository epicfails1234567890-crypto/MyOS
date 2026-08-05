[org 0x7c00]      ; La BIOS carga los sectores de arranque en esta dirección de memoria

    ; --- Limpiar la pantalla ---
    mov ah, 0x00      ; Función 0x00 del BIOS: Establecer modo de video / reiniciar pantalla
    mov al, 0x03      ; Modo de video estándar: Texto 80x25 con 16 colores
    int 0x10          ; Ejecuta la interrupción de la BIOS (borra pantalla y pone cursor en 0,0)

mi_bucle:
    mov ah, 0x09        ; Función para escribir carácter y atributo
    mov al, 'a'         ; El carácter que quieres imprimir
    mov bh, 0x00        ; Página de video (0)
    mov bl, 0x02        ; Atributo de color: 0 (fondo negro) | 2 (texto verde)
    mov cx, 0x01        ; Número de veces que se imprime el carácter
    int 0x10

    mov ah, 0x00
    int 0x16            ; Esperar tecla

    ; Comprobar si es Backspace (borrar)
    cmp al, 0x08
    je borrar_tecla

    ; --- Bucle para recorrer el array del abecedario y números ---
    mov cx, 63          ; Contador: 62 elementos (52 letras + 10 números)
    mov di, abecedario  ; Apuntar DI al inicio del array

buscar_letra:
    mov bl, [di]        ; Cargar la letra actual del array
    cmp al, bl          ; ¿Coincide con la tecla presionada?
    je imprimir         ; Si coincide, salta a imprimir
    inc di              ; Siguiente elemento del array
    dec cx              ; Decrementar contador
    jnz buscar_letra    ; Si no llega a cero, repetir bucle

    jmp mi_bucle        ; Si no es una tecla válida, ignorar y volver a esperar

imprimir:
    mov ah, 0x0e
    int 0x10
    jmp mi_bucle

borrar_tecla:
    mov ah, 0x0e
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp mi_bucle

; Array con el abecedario completo y números
abecedario db "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 "

    ; Rellenar el sector exactamente hasta los 510 bytes y poner la firma de arranque
    times 510-($-$$) db 0
    dw 0xaa55
