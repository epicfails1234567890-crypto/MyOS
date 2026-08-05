[org 0x7c00]

start:
    ; Inicializar segmentos y pila
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00      ; Pila justo debajo del bootloader

    ; Limpiar pantalla
    mov ah, 0x00
    mov al, 0x03
    int 0x10

mi_bucle:
    ; Esperar tecla (AH=0, AL = ASCII)
    mov ah, 0x00
    int 0x16

    ; Comprobar si es Backspace (borrar)
    cmp al, 0x08
    je borrar_tecla

    ; --- Bucle para recorrer el array del abecedario y números ---
    mov cx, 63          ; 26 minúsculas + 26 mayúsculas + 10 dígitos + espacio = 63
    mov di, abecedario  ; Apuntar DI al inicio del array

buscar_letra:
    mov bl, [di]        ; Cargar la letra actual del array
    cmp al, bl          ; ¿Coincide con la tecla presionada?
    je imprimir         ; Si coincide, saltar a imprimir
    inc di              ; Siguiente elemento
    dec cx              ; Decrementar contador
    jnz buscar_letra    ; Repetir si no se ha recorrido todo

    jmp mi_bucle        ; Si no es válida, volver a esperar

imprimir:
    ; Imprimir el carácter en verde (atributo 0x02)
    mov ah, 0x09        ; Función escribir carácter con atributo
    mov bh, 0x00        ; Página de video 0
    mov bl, 0x02        ; Atributo: verde sobre negro
    mov cx, 0x01        ; Un solo carácter
    int 0x10

    ; Avanzar el cursor una posición a la derecha
    mov ah, 0x03        ; Obtener posición actual del cursor
    int 0x10            ; Devuelve DH=fil, DL=columna
    inc dl              ; Incrementar columna
    mov ah, 0x02        ; Establecer posición del cursor
    int 0x10

    jmp mi_bucle

borrar_tecla:
    ; Borrar el carácter anterior (también en verde para que coincida)
    ; Primero retroceder el cursor una posición
    mov ah, 0x03        ; Obtener posición actual
    int 0x10
    cmp dl, 0           ; Si estamos al principio de la línea, no hacemos nada
    je mi_bucle
    dec dl              ; Retroceder columna
    mov ah, 0x02        ; Establecer nueva posición
    int 0x10

    ; Escribir un espacio en verde en esa posición
    mov ah, 0x09
    mov al, ' '
    mov bh, 0x00
    mov bl, 0x02        ; Verde
    mov cx, 0x01
    int 0x10

    ; El cursor ya quedó en la posición correcta (donde escribimos el espacio)
    ; así que no necesitamos moverlo de nuevo
    jmp mi_bucle

; Array con todos los caracteres aceptados
abecedario db "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 "

    ; Rellenar y firma de arranque
    times 510-($-$$) db 0
    dw 0xaa55