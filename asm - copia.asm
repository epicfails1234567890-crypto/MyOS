[org 0x7C00]
[bits 16]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; --- 1. Configurar la Paginación para Modo Largo ---
    mov edi, 0x1000
    mov cr3, edi
    xor eax, eax
    mov ecx, 4096
    rep stosd
    mov edi, cr3

    mov dword [edi], 0x2003
    add edi, 0x1000
    mov dword [edi], 0x3003
    add edi, 0x1000
    mov dword [edi], 0x00000083

    ; --- 2. Activar PAE ---
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; --- 3. Activar el Modo Largo en el registro MSR (EFER) ---
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; --- 4. Activar Paginación y Modo Protegido ---
    mov eax, cr0
    or eax, (1 << 31) | 1
    mov cr0, eax

    lgdt [gdt_descriptor]
    jmp 0x08:init_64bits

[bits 64]
init_64bits:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov rsp, 0x90000

    ; --- AQUÍ LLAMAS A LA FUNCIÓN ---
    call imprimir_a_64

    hlt

; ==========================================
; ZONA DE DATOS Y ESTRUCTURAS (Al final)
; ==========================================












































imprimir_a_64:
    .esperar_tecla:
    ; 1. Leer el estado del controlador de teclado PS/2
    in al, 0x64
    test al, 0x01         ; ¿Hay datos listos para leer en el búfer?
    jz .esperar_tecla     ; Si no hay nada, seguir esperando

    ; 2. Leer el scancode de la tecla presionada
    in al, 0x60
    
    ; El scancode de la 'a' en un teclado estándar es 0x1E (make code)
    cmp al, 0x1E          
    jne .esperar_tecla    ; Si no es la 'a', volver a esperar otra tecla

    ; 3. Si ES la 'a', la imprimimos en pantalla
    mov rdi, 0xB8000      ; Dirección de video VGA
    mov al, 'a'           ; El carácter a mostrar
    mov ah, 0x0A          ; Color verde claro sobre fondo negro
    stosw                 ; Escribe en pantalla
    
    ret                   ; Vuelve al punto donde se llamó con call















































mi_texto: db 'Hola desde 64 bits!', 0

; --- GDT de 64 bits ---
gdt_start:
    dq 0x0000000000000000
gdt_code:
    dq 0x00AF9A000000FFFF
gdt_data:
    dq 0x00CF92000000FFFF
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

; --- Relleno obligatorio y firma de sector de arranque ---
times 510-($-$$) db 0
dw 0xAA55