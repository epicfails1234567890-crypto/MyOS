bits 16
org 0x7c00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti

    ; Cargar el Stage 2 desde el disco (Sector 2 en adelante)
    mov ah, 0x02
    mov al, 0x10         
    mov ch, 0x00
    mov dh, 0x00
    mov cl, 0x02         
    mov bx, 0x7E00       
    int 0x13
    jc disk_error

    jmp 0x0000:stage2_start

disk_error:
    mov ah, 0x0E
    mov al, 'E'
    int 0x10
    cli
    hlt

times 510-($-start) db 0
dw 0xAA55

stage2_start:
    cli
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti

    call do_clear

main_loop:
    mov si, prompt
    call print_string
    mov di, buffer

read_loop:
    xor ax, ax
    int 0x16             
    cmp al, 0x0D         
    je parse_cmd
    cmp al, 0x08         
    je handle_bs
    
    mov bx, buffer
    add bx, 30
    cmp di, bx
    jge read_loop
    
    stosb
    mov ah, 0x0E
    int 0x10
    jmp read_loop

handle_bs:
    mov bx, buffer
    cmp di, bx
    jle read_loop
    dec di
    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp read_loop

parse_cmd:
    mov byte [di], 0     
    mov si, newline
    call print_string

    mov si, buffer
    mov di, c_clear
    call strcmp
    jc do_clear

    mov si, buffer
    mov di, c_help
    call strcmp
    jc do_help

    mov si, buffer
    mov di, c_date
    call strcmp
    jc do_date

    mov si, buffer
    mov di, c_time
    call strcmp
    jc do_time

    mov si, buffer
    mov di, c_echo
    call strncmp
    jc do_echo

    mov si, buffer
    mov di, c_calc
    call strncmp
    jc do_calc

    mov si, buffer
    mov di, c_sub
    call strncmp
    jc do_sub

    mov si, msg_unk
    call print_string
    jmp main_loop

do_clear:
    mov ax, 0x0003       
    int 0x10
    jmp main_loop

do_help:
    mov si, msg_help
    call print_string
    jmp main_loop

do_echo:
    call print_string
    mov si, newline
    call print_string
    jmp main_loop

do_calc:
    mov si, buffer
    add si, 5            ; Omitir "calc "
    call parse_two_numbers
    mov ax, [num1]
    add ax, [num2]
    call print_number
    jmp done_calc

do_sub:
    mov si, buffer
    add si, 4            ; Omitir "sub "
    call parse_two_numbers
    mov ax, [num1]
    cmp ax, [num2]
    jge .positive_sub
    
    ; Si el resultado es negativo
    push ax
    mov ah, 0x0E
    mov al, '-'
    int 0x10
    pop ax
    mov bx, [num2]
    sub bx, [num1]
    mov ax, bx
    jmp .print_sub

.positive_sub:
    sub ax, [num2]

.print_sub:
    call print_number

done_calc:
    mov si, newline
    call print_string
    jmp main_loop

parse_two_numbers:
    ; --- Leer el primer número ---
    xor ax, ax
    xor bx, bx
.read_num1:
    lodsb
    cmp al, ' '
    je .done_num1
    test al, al
    jz .done_parse
    sub al, '0'
    mov cl, al
    mov ax, bx
    mov dx, 10
    mul dx
    movzx cx, cl
    add ax, cx
    mov bx, ax
    jmp .read_num1
.done_num1:
    mov [num1], bx

    ; --- Leer el segundo número ---
    xor ax, ax
    xor bx, bx
.read_num2:
    lodsb
    cmp al, ' '
    je .done_num2
    test al, al
    jz .done_num2
    sub al, '0'
    mov cl, al
    mov ax, bx
    mov dx, 10
    mul dx
    movzx cx, cl
    add ax, cx
    mov bx, ax
    jmp .read_num2
.done_num2:
    mov [num2], bx
.done_parse:
    ret

do_date:
    mov ah, 0x04
    int 0x1a
    mov al, dh
    call p_bcd
    mov al, '/'
    int 0x10
    mov al, dl
    call p_bcd
    mov al, '/'
    int 0x10
    mov al, ch
    call p_bcd
    mov al, cl
    call p_bcd
    mov si, newline
    call print_string
    jmp main_loop

do_time:
    mov ah, 0x02
    xor dx, dx
    int 0x1a
    mov al, ch
    call p_bcd
    mov al, ':'
    int 0x10
    mov al, cl
    call p_bcd
    mov al, ':'
    int 0x10
    mov al, dh
    call p_bcd
    mov si, newline
    call print_string
    jmp main_loop

p_bcd:
    push ax
    shr al, 4
    call p_dig
    pop ax
p_dig:
    and al, 0x0F
    add al, '0'
    mov ah, 0x0E
    int 0x10
    ret

print_number:
    push ax
    push bx
    push cx
    push dx
    mov bx, 10
    xor cx, cx
.div_loop:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz .div_loop
.print_loop:
    pop dx
    mov al, dl
    add al, '0'
    mov ah, 0x0E
    int 0x10
    dec cx
    jnz .print_loop
    pop dx
    pop cx
    pop bx
    pop ax
    ret

print_string:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

strcmp:
    push si
    push di
.l:
    lodsb
    mov bl, byte [di]
    inc di
    cmp al, bl
    jne .no
    test al, al
    jz .yes
    jmp .l
.yes:
    pop di
    pop si
    stc
    ret
.no:
    pop di
    pop si
    clc
    ret

strncmp:
    push di
.l:
    mov al, byte [di]
    test al, al
    jz .yes
    mov bl, byte [si]
    cmp bl, al
    jne .no
    inc si
    inc di
    jmp .l
.yes:
    pop di
    stc
    ret
.no:
    pop di
    clc
    ret

prompt   db '>', 0
newline  db 13, 10, 0
c_clear  db 'clear', 0
c_help   db 'help', 0
c_date   db 'date', 0
c_time   db 'time', 0
c_echo   db 'echo ', 0
c_calc   db 'calc ', 0
c_sub    db 'sub ', 0
msg_unk  db 'Err', 13, 10, 0
msg_help db 'clear,help,date,time,echo,calc,sub', 13, 10, 0
buffer   times 30 db 0
num1     dw 0
num2     dw 0

times 1474560-($-start) db 0