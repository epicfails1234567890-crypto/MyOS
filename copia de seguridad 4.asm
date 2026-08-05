[org 0x7c00]      ; La BIOS carga los sectores de arranque en esta dirección de memoria

; --- Limpiar la pantalla ---
    mov ah, 0x00      ; Función 0x00 del BIOS: Establecer modo de video / reiniciar pantalla
    mov al, 0x03      ; Modo de video estándar: Texto 80x25 con 16 colores
    int 0x10          ; Ejecuta la interrupción de la BIOS (esto borra la pantalla y pone el cursor en 0,0)



[org 0x7c00]

mi_bucle:
    mov ah, 0x00
    int 0x16            ; Esperar tecla

    ; Comprobar si es Backspace (borrar)
    cmp al, 0x08
    je borrar_tecla

    ; --- Bucle FOR para recorrer el array del abecedario ---
    mov cx, 62          ; Inicializar contador del bucle (52 letras: 26 minúsculas + 26 mayúsculas)
    mov di, abecedario    ; Apuntar DI al inicio del array

buscar_letra:
    mov bl, [di]        ; Cargar la letra actual del array
    cmp al, bl          ; ¿Coincide con la tecla presionada?
    je imprimir         ; Si coincide, salta a imprimir
    inc di              ; Siguiente elemento del array
    dec cx              ; Decrementar contador
    jnz buscar_letra    ; Si no llega a cero, repetir bucle

    jmp mi_bucle        ; Si no es ninguna letra ni borrar, ignorar y volver a esperar

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

; Array con el abecedario completo
abecedario db "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"

    times 510-($-$$) db 0
    dw 0xaa55




sinalFinal:
    jmp sinalFinal    ; Bucle infinito para que la PC no se resetee

    ; Rellenar el resto del sector de 512 bytes con ceros y poner la firma mágica al final
    times 514-($-$$) db 0
    dw 0xaa55         ; Firma de arranque obligatoria (los famosos bytes 0x55 y 0xAA)