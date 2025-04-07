# 8086 Assembly pong - Optimized 

A Simple, optimized Pong screensaver implementation for 8086 architecture, emulated on DOSBOX. 

## Features

- Double buffered graphics
- Optimized ball rendering
- Direct video memory access
- Efficient collision detection

## Controls

- Any key press exits the game

## Video Mode: VGA Mode 13h

```assembly
mov ax, 13h     ; Set 320x200 256-color mode
int 10h
mov ax, 0A000h  ; Video memory segment
mov es, ax
```

Mode 13h characteristics:
- Resolution: 320×200 pixels
- Color depth: 256 colors (8-bit)
- Linear framebuffer at 0xA000:0000
- Each pixel = 1 byte in memory

## Performance comparison

### BIOS int10h pixel writes v/s direct video memory writes

### without double buffer (flickering) v/s with double buffer

## Key Optimizations and Techniques:

### 1. Double Buffering
```x86
double_buffer db 320*200 dup(0)  ; Allocates space for entire screen
```
- Eliminates screen flickering by drawing to an off-screen buffer first
- **Optimization**: Complete frame is prepared in memory before being copied to video RAM

### 2. Direct Video Memory Access
```x86
mov ax, 0A000h  ; Video memory segment (0A000:0000)
mov es, ax      ; Set ES to point to video memory
```
- Direct memory writes to video memory are significantly faster thatn BIOS calls like INT 10h pixel drawing

### 3. Efficient Buffer Clearing
```x86
clear_buffer:
    mov di, offset double_buffer
    mov cx, 320*200
    xor ax, ax        ; AX = 0 (black color)
    rep stosb         ; Fill buffer quickly
```
- Uses `rep stosb` to clear the entire buffer in one operation
- Could be optimized further by using `rep stosw` (but I avoided it for now for the sake of consistency)

### 4. Drawing the Ball
```x86
draw_ball:
    ; Calculate position in buffer: y*320 + x
    mov bx, ball_y    
    mov ax, 320
    mul bx            ; AX = y * 320
    add ax, ball_x    ; AX = y*320 + x
    add ax, offset double_buffer
    mov di, ax        ; DI now points to ball position
    
    mov cx, ball_size 
    mov al, color     ; Set color once outside loop
        draw_ball_row:
        push cx
        mov cx, ball_size  
        rep stosb          
        add di, 320        
        sub di, ball_size  
        pop cx
        loop draw_ball_row
```
- **Optimizations**:
  - Pre-calculates all positions before drawing
  - Uses string operations `rep stosb` for horizontal lines

### 5. Efficient Ball Erasing
```x86
clear_ball:
    ;boring alignment code
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

    ;boring wrapping up code
```
- **Optimization**: Only erases non-overlapping previous ball pixels after each frame
- much faster then clearing the whole screen/ball each frame

### 6. Fast Screen Update
```x86
copy_to_screen:
    mov si, offset double_buffer  ; Source
    xor di, di                   ; Destination (0A000:0000)
    mov cx, 320*200              ; Entire screen
    rep movsb                    ; Bulk copy
```
- **Optimization**: Copies entire frame in one operation with `rep movsb`

### 8. Additional optimizations

- Use of `xor al, al` instead of `mov al, 0` to clear registers whenever necessary

## Build & Run

Assembled with MASM611, (other assemblers may also work)
```x86
ml pong.asm
pong
```

## Future Improvements

- **Frame rate control**
    - as of now, I am only able to acheive smooth animation using a double delay loop.
    - Unsuccessful to implement using system time, very glitchy.
