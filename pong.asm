.model small
.stack 64

.data
time_aux db 0 ; check time change
BALLX dw 0Ah  ; x_pos
BALLY dw 0Ah  ; y_pos
PREV_BALLX dw 0Ah  ; previous x_pos
PREV_BALLY dw 0Ah  ; previous y_pos
BALL_SIZE dw 05h
speedX dw 05h
speedY dw 02h

.code
.startup
    main:
        call clear_screen

        check_time:
            mov ah,01h ;wait for a key press
            int 16h
            jnz exit

            mov ah,2ch ;get system time
            int 21h

            cmp dl,time_aux
            JE check_time
            mov time_aux,dl ;update time

        call clear_ball  ; Clear the ball at its previous position

        ; Update the ball's position
        mov ax,speedX
        add BALLX,ax
        mov ax,speedY
        add BALLY,ax

        call draw_ball  ; Draw the ball at its new position

        ; Update the previous position
        mov ax, BALLX
        mov PREV_BALLX, ax
        mov ax, BALLY
        mov PREV_BALLY, ax

        jmp check_time

    exit:
        mov ax,3 ;return to text mode 
        int 10h
.exit
        
    draw_ball:
        mov cx, BALLX ;x_pos init
        mov dx, BALLY ;y_pos init
        
        horizontal:
            mov ax,0C0Fh ;write graphics pixel, white
            mov bh,00h ;page number
            int 10h
            inc cx
            mov ax,cx       ; cx - ballx >= ball_size ? next line : next column
            sub ax, BALLX
            cmp ax, BALL_SIZE
            jnge horizontal

        vertical:
            mov cx, BALLX ; cx back to init
            inc dx        ; advance one line
            mov ax,dx     ; dx - ballx >= ball_size ? exit : next line
            sub ax, BALLY
            cmp ax, BALL_SIZE
            jnge horizontal
        ret
    
    clear_ball:
        mov cx, PREV_BALLX ;x_pos init
        mov dx, PREV_BALLY ;y_pos init
        
        clear_horizontal:
            mov ax,0C00h ;write graphics pixel, black
            mov bh,00h ;page number
            int 10h
            inc cx
            mov ax,cx       ; cx - prev_ballx >= ball_size ? next line : next column
            sub ax, PREV_BALLX
            cmp ax, BALL_SIZE
            jnge clear_horizontal

        clear_vertical:
            mov cx, PREV_BALLX ; cx back to init
            inc dx        ; advance one line
            mov ax,dx     ; dx - prev_bally >= ball_size ? exit : next line
            sub ax, PREV_BALLY
            cmp ax, BALL_SIZE
            jnge clear_horizontal
        ret

    clear_screen:
        mov ax,13h ;Set video mode ;320x200, 256 colors
        int 10h

        mov ah,0Bh ;set background color
        xor bx,bx  ;black
        int 10h
        ret
end