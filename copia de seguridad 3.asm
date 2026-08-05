[org 0x7c00]      ; La BIOS carga los sectores de arranque en esta dirección de memoria

; --- Limpiar la pantalla ---
    mov ah, 0x00      ; Función 0x00 del BIOS: Establecer modo de video / reiniciar pantalla
    mov al, 0x03      ; Modo de video estándar: Texto 80x25 con 16 colores
    int 0x10          ; Ejecuta la interrupción de la BIOS (esto borra la pantalla y pone el cursor en 0,0)



mi_bucle:
    mov ah, 0x00        ; Función 0x00: Esperar y leer pulsación de teclado
    int 0x16            ; La BIOS se pausa aquí. La letra queda en el registro 'al'

    ; --- FILTRO DE BORRAR (Backspace = 0x08) ---
    cmp al, 0x08
    je borrar_tecla

    cmp al, 'a'
    je imprimir
    cmp al, 'A'
    je imprimir
    cmp al, 'b'
    je imprimir
    cmp al, 'B'
    je imprimir
    cmp al, 'c'
    je imprimir
    cmp al, 'C'
    je imprimir
    cmp al, 'd'
    je imprimir
    cmp al, 'D'
    je imprimir
    cmp al, 'e'
    je imprimir
    cmp al, 'E'
    je imprimir
    cmp al, 'f'
    je imprimir
    cmp al, 'F'
    je imprimir
    cmp al, 'g'
    je imprimir
    cmp al, 'G'
    je imprimir
    cmp al, 'h'
    je imprimir
    cmp al, 'H'
    je imprimir
    cmp al, 'i'
    je imprimir
    cmp al, 'I'
    je imprimir
    cmp al, 'j'
    je imprimir
    cmp al, 'J'
    je imprimir
    cmp al, 'k'
    je imprimir
    cmp al, 'K'
    je imprimir
    cmp al, 'l'
    je imprimir
    cmp al, 'L'
    je imprimir
    cmp al, 'm'
    je imprimir
    cmp al, 'M'
    je imprimir
    cmp al, 'n'
    je imprimir
    cmp al, 'N'
    je imprimir
    cmp al, 'o'
    je imprimir
    cmp al, 'O'
    je imprimir
    cmp al, 'p'
    je imprimir
    cmp al, 'P'
    je imprimir
    cmp al, 'q'
    je imprimir
    cmp al, 'Q'
    je imprimir
    cmp al, 'r'
    je imprimir
    cmp al, 'R'
    je imprimir
    cmp al, 's'
    je imprimir
    cmp al, 'S'
    je imprimir
    cmp al, 't'
    je imprimir
    cmp al, 'T'
    je imprimir
    cmp al, 'u'
    je imprimir
    cmp al, 'U'
    je imprimir
    cmp al, 'v'
    je imprimir
    cmp al, 'V'
    je imprimir
    cmp al, 'w'
    je imprimir
    cmp al, 'W'
    je imprimir
    cmp al, 'x'
    je imprimir
    cmp al, 'X'
    je imprimir
    cmp al, 'y'
    je imprimir
    cmp al, 'Y'
    je imprimir
    cmp al, 'z'
    je imprimir
    cmp al, 'Z'

    je imprimir
    cmp al, '0'
    je imprimir
    cmp al, '1'
    je imprimir
    cmp al, '2'
    je imprimir
    cmp al, '3'
    je imprimir
    je imprimir
    cmp al, '4'
    je imprimir
    cmp al, '5'
    je imprimir
    cmp al, '6'
    je imprimir
    cmp al, '7'
    je imprimir
    cmp al, '8'
    je imprimir
    cmp al, '9'
    je imprimir


    ; Si no es ninguna de las dos, ignora la tecla y vuelve a empezar el bucle
    jmp mi_bucle

imprimir:
    ; Imprimir la tecla 'a' que el usuario acaba de presionar
    mov ah, 0x0e        ; Función de la BIOS para imprimir el carácter en 'al'
    int 0x10            ; Imprime en pantalla

    jmp mi_bucle        ; Saltar de vuelta a "mi_bucle" para la siguiente tecla

borrar_tecla:
    ; Rutina clásica de retroceso en BIOS (TTY mode)
    ; Para borrar visualmente, imprimimos: Retroceso -> Espacio -> Retroceso
    
    mov ah, 0x0e
    mov al, 0x08    ; Retrocede el cursor
    int 0x10
    
    mov al, ' '     ; Imprime un espacio vacío sobre la letra anterior
    int 0x10
    
    mov al, 0x08    ; Vuelve a retroceder el cursor para dejarlo listo
    int 0x10
    
    jmp mi_bucle

    times 510-($-$$) db 0
    dw 0xaa55






sinalFinal:
    jmp sinalFinal    ; Bucle infinito para que la PC no se resetee

    ; Rellenar el resto del sector de 512 bytes con ceros y poner la firma mágica al final
    times 514-($-$$) db 0
    dw 0xaa55         ; Firma de arranque obligatoria (los famosos bytes 0x55 y 0xAA)