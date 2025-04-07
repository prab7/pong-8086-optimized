this is the next iteration of code 

.model small
.stack 64h
.186

.data
    ball_x dw 0Ah      ; y_pos init
    ball_y dw 0Ah      ; x_pos init
    ball_size dw 10   
    ball_dx dw 1            ; dx pixels
    ball_dy dw 1            ; dy pixels
    prev_ballx dw 1 dup(?)
    prev_bally dw 1 dup(?)
    color db 0bh      ; color
    

.code
.startup

    mov ax, 13h ;set video mode: 320x200 256 colors 
    int 10h

    call clear_screen

main_loop:

    call clear_ball     ;clear previous ball
    call draw_ball      ;draw new ball

    ; update the previous position
    mov ax, ball_x
    mov prev_ballx,ax
    mov ax, ball_y
    mov prev_bally,ax

    ; update ball position
    mov ax, ball_dx
    add ball_x, ax
    mov ax, ball_dy
    add ball_y, ax

    call check_collisions

    call delay      ;Artificial delay
    
    mov ah, 01h       ;wait for a key press
    int 16h
    jz main_loop      ;continue if no key pressed

    ; Exit the program
    mov ax, 03h       ; Set text mode (mode 03h)
    int 10h

    .exit


clear_screen:
    mov ax, 0A000h    ; Video memory segment
    mov es, ax
    xor di, di        
    mov cx, 320*200   
    xor al, al        ;color: black
    rep stosb         ;fill video memory with black
    ret


draw_ball:
    mov ax, 0A000h    
    mov es, ax
    mov bx, ball_y    
    mov ax, 320
    mul bx
    add ax, ball_x    
    mov di, ax        

    mov cx, ball_size 

    draw_ball_row:
        push cx
        mov cx, ball_size  
        mov al, color      
        rep stosb          
        add di, 320        
        sub di, ball_size  
        pop cx
        loop draw_ball_row
        ret

clear_ball:
    mov ax, 0A000h    
    mov es, ax
    mov bx, prev_bally
    mov ax, 320
    mul bx
    add ax, prev_ballx
    mov di, ax
    
    mov cx, ball_size

    clear_row:
        push cx
        mov cx, ball_size

        clear_pixel:
            mov dx, prev_ballx
            cmp dx, ball_x
            jne write_black     ;if prev_ballx != ball_x
            mov dx, prev_bally  
            cmp dx, ball_y
            jne write_black     ;if prev_bally != ball_y

            inc di
            loop clear_pixel    ; else skip
            
        next_jump:
        add di, 320         ; next row
        sub di, ball_size   ; set pointer at start location
        pop cx
        loop clear_row
        ret

        write_black:
            xor al,al           ;if !(prev_ballx == ball_x AND prev_bally == ball_y)
            mov es:[di],al
            inc di
            loop clear_pixel
            jmp next_jump       ;jump back to exit/loop properly


check_collisions: 
    cmp ball_x, 0
    jle reverse_x     ; If ball_x <= 0, reverse x
    mov ax, 320
    sub ax, ball_size
    cmp ball_x, ax
    jge reverse_x     ; If ball_x >= 320 - ball_size, reverse x

    cmp ball_y, 0
    jle reverse_y     ; If ball_y <= 0, reverse y
    mov ax, 200
    sub ax, ball_size
    cmp ball_y, ax
    jge reverse_y     ; If ball_y >= 200 - ball_size, reverse y
    ret

    reverse_x:
        neg ball_dx       ;reverse x
        ret

    reverse_y:
        neg ball_dy       ;reverse y
        ret

delay:
    mov cx, 01h       ;delay counter (adjust for speed)
    delay_loop:
        push cx
        mov cx, 0FFFFh
    inner_delay:
        loop inner_delay
        pop cx
        loop delay_loop
        ret

end