; .model small
; .186
; .stack
; .data
; .code
;     .startup
;         mov ax,13h ;Set video mode ;320x200, 256 colors
;         int 10h
        
;         cwd             ; "clear" DX for perfect alignment
;         mov al,13h
;             X: int 10h		; set video mode AND draw pixel
;             inc cx			; increment column
;             mov ax,cx		; get column in AH
;             xor al,ah		; the famous XOR pattern
;             mov ah,0Ch		; set subfunction "set pixel" for int 0x10
;             and al,32+8		; a more interesting variation of it
;             jmp short X	
;     .exit
; end

.model small
.186
.stack 100h
.data
.code
    .startup
        mov ax, 13h     ; Set video mode: 320x200, 256 colors
        int 10h

        cwd
            X:

            push ax
            mov ah, 01h     ; BIOS function to wait for a key press
            int 16h         ; Call BIOS interrupt
            jnz exit
            pop ax
            
            int 10h		; set video mode AND draw pixel
            inc cx			; increment column
            mov ax,cx		; get column in AH
            xor al,ah		; the famous XOR pattern
            mov ah,0Ch		; set subfunction "set pixel" for int 0x10
            and al,32+8		; a more interesting variation of it
            jmp X

        mov ah, 00h     ; BIOS function to wait for a key press
        int 16h         ; Call BIOS interrupt

        exit:
        mov ax, 03h
        int 10h

    .exit
end