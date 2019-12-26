cpu 8086
org 0x7c00

mov ax, 0x9fae
mov es, ax

mov ah, 0x00 ; change mode
mov al, 0x13 ; set it to graphics mode
int 0x10

mov ax, 0xa000
mov es, ax

call draw_dot

game_loop:
    
    call check_for_key_press
    call check_if_touching_dot
    call update_snake_tail
    call check_bounds

    mov bx, word[snake_head]
    mov ax, bx
  
    cmp byte[es:bx], 0x9
    jne .draw_snake_head
    
    jmp game_over

    .draw_snake_head:
    
    mov byte[es:bx], 0xe

    call len_array_push
    call waitd 

    jmp game_loop 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    

update_snake_tail:

    call get_tail_from_array 
    mov bx, ax
    mov byte[es:bx], 0x0

    ret

waitd:

    push dx
    push ax 

    .wait:
        mov ah,0x00
        int 0x1a                ; BIOS clock read
        cmp dx,[old_time]       ; Wait for time change
        je .wait
        ;jl _wait
        ;add dx, 0x2             ; slow down loop for visual effect.
        mov [old_time],dx 

    pop ax
    pop dx 

    ret

check_for_key_press:

    mov ah, 0x01
    int 0x16
    jz .continue

    mov ah, 0x00
    int 0x16 ; get keystroke
    
    cmp al, 0x73 ; Check for 's' key
    jne .check_w 
    cmp byte[snake_dir], 1
    je .continue 
    mov byte[snake_dir], 2
    jmp .continue

    .check_w:
    cmp al, 0x77 ; Check for 'w' key
    jne .check_a 
    cmp byte[snake_dir], 2
    je .continue 
    mov byte[snake_dir], 1
    jmp .continue

    .check_a:
    cmp al, 0x61 ; Check for 'a' key
    jne .check_d 
    cmp byte[snake_dir], 4
    je .continue 
     mov byte[snake_dir], 3

    jmp .continue

    .check_d:
    cmp al, 0x64 ; Check for 'd' key
    jne .continue 
    cmp byte[snake_dir], 3
    je .continue 
    mov byte[snake_dir], 4

    .continue:

    ret

len_array_push:

    push es
    push ax
    push bx

    mov ax, 0x7e1
    mov es, ax 

    mov ax, bx
    mov bx, word[len_array_idx]
    mov [es:bx], ax

    add word[len_array_idx], 2 

    pop bx
    pop ax
    pop es

    ret 

get_tail_from_array:

    push es
    push bx

    mov ax, 0x7e1
    mov es, ax 

    mov ax, word[len_array_idx]
    sub ax, word[snake_len]   
    sub ax, word[snake_len] 

   ; mov ah, 0x0 
    mov bx, ax
    mov ax, [es:bx] ; Return is AX

    pop bx
    pop es

    ret

check_bounds:

    push ax 
    push bx

    cmp byte[snake_dir], 1
    je .check_up
    
    cmp byte[snake_dir], 3
    je .check_left

    cmp byte[snake_dir], 4
    je .check_right
  
    .check_down:
        cmp word[snake_row], 200    
        jb .check_down1

        mov word[snake_row], 0
        jmp .done

    .check_down1:
        add word[snake_row], 1
        jmp .done

    .check_up:
        cmp word[snake_row], 0    
        jne .check_up1

        mov word[snake_row], 200
        jmp .done
    
    .check_up1:
        sub word[snake_row], 1
        jmp .done ; add word[snake_head], 320
    
    .check_left:
        cmp word[snake_col], 0
        jne .check_left1
        
        mov word[snake_col], 319 
        jmp .done

    .check_left1:
        sub word[snake_col], 1
        jmp .done

    .check_right:
        cmp word[snake_col], 319 
        jne .check_right1
        
        mov word[snake_col], 0
        jmp .done

    .check_right1:
        add word[snake_col], 1 
    
    .done:
        mov ax, 320

        mul word[snake_row]
        add ax, word[snake_col] 

        mov bx, word[snake_head] ;Change snake head color
        mov byte[es:bx], 0x9     ;to body color 

        mov word[snake_head], ax

        pop bx
        pop ax
        
    ret

check_if_touching_dot:

    mov ax, word[snake_dot] ; Check if touching dot 
    cmp word[snake_head], ax
    jne .done 
    
    add word[snake_len], 20; Increment snake length 

    call draw_dot

    .done:    

    ret 

draw_dot:

    push ax

    .draw_it:
        mov ah, 0x0
        int 0x1a

        mov dh, 0x0
        mov ax, dx
        mov dx, 250
        mul dx ; 255 * 250 = 63750
        
        mov bx, ax 

        cmp byte[es:bx], 0x0
        jne .draw_it

    mov word[snake_dot], bx 

    mov byte[es:bx], 0x05

    pop ax

    ret 

game_over:

    mov ah , 0x0
    mov al, 0x1
    mov cx, 0x2607 
    int 0x10

    mov bx,0xB800
    mov es,bx
    
    xor bx, bx
    mov bx, 750 
    
    xor si, si
    mov si, 0 
 
    .loop:

        mov al, byte[msg + si] 
        mov byte[es:bx], al 
        mov byte[es:bx+ 1], 0x2 
    
        add si, 1
        add bx, 2

        cmp byte[msg + si], 0
        jne .loop
     
    mov  dl, 180           
    mov  dh, 200           
    mov  ah, 2             
    mov  bh, 0             
    int  10h               
    
    ret
 
old_time: dw 0x0
len_array_idx: dw 0x0
snake_head: dw 0x0;63868 

snake_col: dw 72 
snake_row: dw 10

snake_dir: db 4
snake_dot: dw 0x0 
snake_tail: dw 0x0 

snake_len: dw 0x40
snake_curlen: dw 0x00

msg: db "You win!", 0

times 510 - ($-$$) db 0x0
db 0x55, 0xaa 
