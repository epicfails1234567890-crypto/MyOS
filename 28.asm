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
    mov di, c_ver
    call strcmp
    jc do_ver

    mov si, buffer
    mov di, c_reboot
    call strcmp
    jc do_reboot

    mov si, buffer
    mov di, c_colors
    call strcmp
    jc do_colors

    mov si, buffer
    mov di, c_random
    call strcmp
    jc do_random

    mov si, buffer
    mov di, c_newarr
    call strncmp
    jc do_newarr

    mov si, buffer
    mov di, c_lengtharr
    call strcmp
    jc do_lengtharr

    mov si, buffer
    mov di, c_setarr
    call strncmp
    jc do_setarr

    mov si, buffer
    mov di, c_getarr
    call strncmp
    jc do_getarr

    mov si, buffer
    mov di, c_addarr
    call strncmp
    jc do_addarr

    mov si, buffer
    mov di, c_subarr
    call strncmp
    jc do_subarr

    mov si, buffer
    mov di, c_mulvar
    call strncmp
    jc do_mulvar

    mov si, buffer
    mov di, c_divvar
    call strncmp
    jc do_divvar

    mov si, buffer
    mov di, c_modvar
    call strncmp
    jc do_modvar

    mov si, buffer
    mov di, c_set
    call strncmp
    jc do_set

    mov si, buffer
    mov di, c_get
    call strncmp
    jc do_get

    mov si, buffer
    mov di, c_add
    call strncmp
    jc do_add

    mov si, buffer
    mov di, c_sub_var
    call strncmp
    jc do_sub_var

    mov si, buffer
    mov di, c_dec
    call strncmp
    jc do_dec

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

    mov si, buffer
    mov di, c_mul
    call strncmp
    jc do_mul

    mov si, buffer
    mov di, c_div
    call strncmp
    jc do_div

    mov si, buffer
    mov di, c_mod
    call strncmp
    jc do_mod

    mov si, buffer
    mov di, c_power
    call strncmp
    jc do_power

    mov si, buffer
    mov di, c_sqrt
    call strncmp
    jc do_sqrt

    mov si, buffer
    mov di, c_log10
    call strncmp
    jc do_log10

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

do_ver:
    mov si, msg_ver
    call print_string
    jmp main_loop

do_reboot:
    int 0x19               
    jmp 0xFFFF:0x0000    

do_colors:
    mov si, msg_colors
    call print_string
    jmp main_loop

do_random:
    mov ah, 0x00
    int 0x1A
    mov ax, dx
    xor dx, dx
    mov bx, 100           
    div bx
    mov ax, dx            
    call print_number
    mov si, newline
    call print_string
    jmp main_loop

; =========================================================================
; GESTIÓN AVANZADA DE ARRAYS (Estilo Java)
; =========================================================================

do_newarr:
    mov si, buffer
.skip_cmd_na:
    lodsb
    cmp al, ' '
    jne .skip_cmd_na
.skip_sp_na:
    lodsb
    cmp al, ' '
    je .skip_sp_na
    dec si
    call parse_single_number
    mov ax, [num1]
    mov [array_size], ax  
    jmp main_loop

do_lengtharr:
    mov ax, [array_size]
    call print_number
    mov si, newline
    call print_string
    jmp main_loop

do_setarr:
    mov si, buffer
.skip_cmd_sa:
    lodsb
    cmp al, ' '
    jne .skip_cmd_sa
.skip_sp_sa:
    lodsb
    cmp al, ' '
    je .skip_sp_sa
    dec si
    call parse_two_numbers 

    mov ax, [num1]        
    cmp ax, [array_size]
    jge error_cmd         

    shl ax, 1             
    mov bx, ax
    mov si, array_vals
    add si, bx
    mov ax, [num2]
    mov [si], ax          
    jmp main_loop

do_getarr:
    mov si, buffer
.skip_cmd_ga:
    lodsb
    cmp al, ' '
    jne .skip_cmd_ga
.skip_sp_ga:
    lodsb
    cmp al, ' '
    je .skip_sp_ga
    dec si
    call parse_single_number
    
    mov ax, [num1]        
    cmp ax, [array_size]
    jge error_cmd         

    shl ax, 1
    mov bx, ax
    mov si, array_vals
    add si, bx
    mov ax, [si]          
    
    call print_number
    mov si, newline
    call print_string
    jmp main_loop

do_addarr:
    mov si, buffer
.skip_cmd_aa:
    lodsb
    cmp al, ' '
    jne .skip_cmd_aa
.skip_sp_aa:
    lodsb
    cmp al, ' '
    je .skip_sp_aa
    dec si
    call parse_two_numbers

    mov ax, [num1]
    cmp ax, [array_size]
    jge error_cmd

    shl ax, 1
    mov bx, ax
    mov si, array_vals
    add si, bx
    mov ax, [num2]
    add [si], ax
    jmp main_loop

do_subarr:
    mov si, buffer
.skip_cmd_sua:
    lodsb
    cmp al, ' '
    jne .skip_cmd_sua
.skip_sp_sua:
    lodsb
    cmp al, ' '
    je .skip_sp_sua
    dec si
    call parse_two_numbers

    mov ax, [num1]
    cmp ax, [array_size]
    jge error_cmd

    shl ax, 1
    mov bx, ax
    mov si, array_vals
    add si, bx
    mov ax, [num2]
    sub [si], ax
    jmp main_loop

do_mulvar:
    mov si, buffer
.skip_cmd_ma:
    lodsb
    cmp al, ' '
    jne .skip_cmd_ma
.skip_sp_ma:
    lodsb
    cmp al, ' '
    je .skip_sp_ma
    dec si
    call parse_two_numbers

    mov ax, [num1]
    cmp ax, [array_size]
    jge error_cmd

    shl ax, 1
    mov bx, ax
    mov si, array_vals
    add si, bx
    mov ax, [si]
    mov cx, [num2]
    mul cx
    mov [si], ax
    jmp main_loop

do_divvar:
    mov si, buffer
    fn_da:
    lodsb
    cmp al, ' '
    jne fn_da
    fn_da2:
    lodsb
    cmp al, ' '
    je fn_da2
    dec si
    call parse_two_numbers

    mov ax, [num1]
    cmp ax, [array_size]
    jge error_cmd

    mov cx, [num2]
    test cx, cx
    jz error_cmd

    shl ax, 1
    mov bx, ax
    mov si, array_vals
    add si, bx
    mov ax, [si]
    xor dx, dx
    div cx
    mov [si], ax
    jmp main_loop

do_modvar:
    mov si, buffer
    fn_mo:
    lodsb
    cmp al, ' '
    jne fn_mo
    fn_mo2:
    lodsb
    cmp al, ' '
    je fn_mo2
    dec si
    call parse_two_numbers

    mov ax, [num1]
    cmp ax, [array_size]
    jge error_cmd

    mov cx, [num2]
    test cx, cx
    jz error_cmd

    shl ax, 1
    mov bx, ax
    mov si, array_vals
    add si, bx
    mov ax, [si]
    xor dx, dx
    div cx
    mov [si], dx
    jmp main_loop

; =========================================================================
; MAPEO DINÁMICO ESTILO EXCEL (Variables a-z / aa-zz)
; =========================================================================

get_variable_index:
    push ax
    push cx
    push dx
    push si
    mov si, buffer
.skip_cmd:
    lodsb
    cmp al, ' '
    jne .skip_cmd
.skip_spaces:
    lodsb
    cmp al, ' '
    je .skip_spaces
    dec si                  

    xor bx, bx              
.parse_letters:
    lodsb
    cmp al, ' '
    je .done_name
    cmp al, 0
    je .done_name
    
    cmp al, 'a'
    jl .err
    cmp al, 'z'
    jg .err
    
    sub al, 'a'             
    movzx ax, al
    
    push ax
    mov ax, bx
    mov cx, 26
    mul cx                  
    mov bx, ax
    pop ax
    add bx, ax              
    
    jmp .parse_letters

.done_name:
    pop si
    pop dx
    pop cx
    pop ax
    clc
    ret

.err:
    pop si
    pop dx
    pop cx
    pop ax
    stc
    ret

do_set:
    call get_variable_index
    jc error_cmd
    push bx                

.skip_to_val:
    lodsb
    cmp al, ' '
    je .skip_spaces_val
    cmp al, 0
    je pop_err
    jmp .skip_to_val
.skip_spaces_val:
    lodsb
    cmp al, ' '
    je .skip_spaces_val
    dec si

    call parse_single_number
    pop bx                   
    
    mov ax, [num1]
    push bx
    shl bx, 1               
    mov si, alphabet_vals
    add si, bx
    mov [si], ax            
    pop bx
    jmp main_loop

pop_err:
    pop bx
error_cmd:
    mov si, msg_unk
    call print_string
    jmp main_loop

do_get:
    call get_variable_index
    jc error_cmd
    
    shl bx, 1
    mov si, alphabet_vals
    add si, bx
    mov ax, [si]
    
    call print_number
    mov si, newline
    call print_string
    jmp main_loop

do_add:
    call get_variable_index
    jc error_cmd
    push bx

.skip_to_val_add:
    lodsb
    cmp al, ' '
    je .skip_spaces_add
    cmp al, 0
    je pop_err
    jmp .skip_to_val_add
.skip_spaces_add:
    lodsb
    cmp al, ' '
    je .skip_spaces_add
    dec si

    call parse_single_number
    pop bx
    
    mov ax, [num1]
    shl bx, 1
    mov si, alphabet_vals
    add si, bx
    add [si], ax
    jmp main_loop

do_sub_var:
    call get_variable_index
    jc error_cmd
    push bx

.skip_to_val_sub:
    lodsb
    cmp al, ' '
    je .skip_spaces_sub
    cmp al, 0
    je pop_err
    jmp .skip_to_val_sub
.skip_spaces_sub:
    lodsb
    cmp al, ' '
    je .skip_spaces_sub
    dec si

    call parse_single_number
    pop bx
    
    mov ax, [num1]
    shl bx, 1
    mov si, alphabet_vals
    add si, bx
    sub [si], ax
    jmp main_loop

do_dec:
    call get_variable_index
    jc error_cmd
    
    shl bx, 1
    mov si, alphabet_vals
    add si, bx
    dec word [si]
    jmp main_loop

; =========================================================================

do_echo:
    call print_string
    mov si, newline
    call print_string
    jmp main_loop

do_calc:
    mov si, buffer
    add si, 5              
    call parse_two_numbers
    mov ax, [num1]
    add ax, [num2]
    call print_number
    jmp done_calc

do_sub:
    mov si, buffer
    add si, 4              
    call parse_two_numbers
    mov ax, [num1]
    cmp ax, [num2]
    jge .positive_sub
    
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
    jmp done_calc

do_mul:
    mov si, buffer
    add si, 4              
    call parse_two_numbers
    mov ax, [num1]
    mov bx, [num2]
    mul bx                 
    call print_number
    jmp done_calc

do_div:
    mov si, buffer
    add si, 4              
    call parse_two_numbers
    mov bx, [num2]
    test bx, bx            
    jz .div_error
    mov ax, [num1]
    xor dx, dx             
    div bx                 
    call print_number
    jmp done_calc

.div_error:
    mov si, msg_unk
    call print_string
    jmp main_loop

do_mod:
    mov si, buffer
    add si, 4              
    call parse_two_numbers
    mov bx, [num2]
    test bx, bx            
    jz .mod_error
    mov ax, [num1]
    xor dx, dx             
    div bx                 
    mov ax, dx             
    call print_number
    jmp done_calc

.mod_error:
    mov si, msg_unk
    call print_string
    jmp main_loop

do_power:
    mov si, buffer
    add si, 6              
    call parse_two_numbers
    mov cx, [num2]         
    mov ax, [num1]         
    
    cmp cx, 0
    jne .check_exp1
    mov ax, 1              
    jmp .print_pow

.check_exp1:
    cmp cx, 1
    je .print_pow          

    mov bx, ax             
    dec cx                 

.pow_loop:
    push cx
    mul bx                 
    pop cx
    dec cx
    jnz .pow_loop

.print_pow:
    call print_number
    jmp done_calc

do_sqrt:
    mov si, buffer
    add si, 5              
    call parse_single_number
    mov ax, [num1]
    
    xor cx, cx             
.sqrt_loop:
    mov bx, cx
    inc bx
    mov ax, bx
    mul bx                 
    test dx, dx            
    jz .sqrt_done
    cmp ax, [num1]
    ja .sqrt_done
    inc cx
    jmp .sqrt_loop

.sqrt_done:
    mov ax, cx
    call print_number
    jmp done_calc

do_log10:
    mov si, buffer
    add si, 6              
    call parse_single_number
    mov ax, [num1]
    
    test ax, ax            
    jz .log_error          
    
    xor cx, cx             
    mov bx, 10             

.log_loop:
    xor dx, dx             
    div bx                 
    test ax, ax            
    jz .log_done           
    inc cx                 
    jmp .log_loop

.log_done:
    mov ax, cx             
    call print_number
    jmp done_calc

.log_error:
    mov si, msg_unk
    call print_string
    jmp main_loop

done_calc:
    mov si, newline
    call print_string
    jmp main_loop

parse_single_number:
    xor ax, ax
    xor bx, bx
.read_num:
    lodsb
    cmp al, ' '
    je .done_num
    test al, al
    jz .done_num
    sub al, '0'
    mov cl, al
    mov ax, bx
    mov dx, 10
    mul dx
    movzx cx, cl
    add ax, cx
    mov bx, ax
    jmp .read_num
.done_num:
    mov [num1], bx
    ret

parse_two_numbers:
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

    xor ax, ax
    xor bx, bx
.read_num2:
    lodsb
    cmp al, ' '
    je .read_num2       
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
    jmp .read_num2
.done_parse:
    mov [num2], bx
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

prompt       db '>', 0
newline      db 13, 10, 0
c_clear      db 'clear', 0
c_help       db 'help', 0
c_date       db 'date', 0
c_time       db 'time', 0
c_ver        db 'ver', 0
c_reboot     db 'reboot', 0
c_colors     db 'colors', 0
c_random     db 'random', 0
c_newarr     db 'newarr ', 0
c_lengtharr  db 'lengtharr', 0
c_setarr     db 'setarr ', 0
c_getarr     db 'getarr ', 0
c_addarr     db 'addarr ', 0
c_subarr     db 'subarr ', 0
c_mulvar     db 'mulvar ', 0
c_divvar     db 'divvar ', 0
c_modvar     db 'modvar ', 0
c_set        db 'set ', 0
c_get        db 'get ', 0
c_add        db 'add ', 0
c_sub_var    db 'sub ', 0
c_dec        db 'dec ', 0
c_echo       db 'echo ', 0
c_calc       db 'calc ', 0
c_sub        db 'sub ', 0
c_mul        db 'mul ', 0
c_div        db 'div ', 0
c_mod        db 'mod ', 0
c_power      db 'power ', 0
c_sqrt       db 'sqrt ', 0
c_log10      db 'log10 ', 0
msg_unk      db 'Err', 13, 10, 0
msg_ver      db 'CustomOS v1.5 - 16-bit x86', 13, 10, 0
msg_colors   db 'Tip: Use standard BIOS text mode capabilities.', 13, 10, 0
msg_help     db 'clear,help,date,time,ver,reboot,colors,random,newarr,lengtharr,setarr,getarr,addarr,subarr,mulvar,divvar,modvar,set,get,add,sub,dec,echo,calc,sub,mul,div,mod,power,sqrt,log10', 13, 10, 0
buffer       times 30 db 0
num1         dw 0
num2         dw 0

; Espacio para variables estilo Excel
alphabet_vals times 1404 db 0

; Espacio para el Array
array_size   dw 0
array_vals   times 200 db 0

times 1474560-($-start) db 0