.model small
.stack 64

.data
time_aux db 0 ; check time change
BALLX dw 0Ah  ; x_pos
BALLY dw 0Ah  ; y_pos
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

        mov ax,speedX
        add BALLX,ax
        mov ax,speedY
        add BALLY,ax

        call clear_screen
        call draw_ball

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
    
    clear_screen:
        mov ax,13h ;Set video mode ;320x200, 256 colors
        int 10h

        mov ah,0Bh ;set background color
        xor bx,bx  ;black
        int 10h
        ret
end