section .text

%define pixels   ebp+8
%define output   ebp+12
%define width    ebp+16
%define height   ebp+20
%define rotation ebp+24

%define size      ebp-4
%define pos       ebp-8
%define dst_pos   ebp-12
%define dst_x     ebp-16
%define dst_y     ebp-20
%define dst_width ebp-24

%macro clean_reg 0
    xor eax, eax
    xor edx, edx
    xor ecx, ecx
    xor ebx, ebx
%endmacro

%macro calc_dst_pos 4
    ;%1 - x addr
    ;%2 - y addr
    ;%3 - dest addr
    ;%4 line width addr
    clean_reg

    mov ax, [%4]
    mov cx, [%2]
    mul cx
    mov [%3], ax
    mov [%3+2], dx
    mov ebx, [%3]
    add ebx, [%1]
    mov eax, 3
    mul ebx
    mov [%3], eax ;ignoring higher part

%endmacro

%macro  move_from_xy_to_xy 0  ;moves one pixel (3 subpixels)
    calc_dst_pos dst_x, dst_y, dst_pos, dst_width

    clean_reg

    mov ebx, [pos]
    mov eax, 3
    mul ebx

    mov ebx, [pixels]
    add eax, ebx
    mov bx, [eax]
    mov cl, [eax+2]

    mov eax, [output]
    add eax, [dst_pos]
    mov [eax], bx
    mov [eax+2], cl
%endmacro


global f
f:
    push ebp
    mov ebp,esp
    sub esp, 24

    xor eax, eax
    mov [size], eax
    mov [pos], eax
    mov [dst_pos], eax
    mov [dst_x], eax
    mov [dst_y], eax
    mov [dst_width], eax

    cmp [rotation], dword 0
    je set_width_rot02
    cmp [rotation], dword 2
    je set_width_rot02

set_width_rot13:
    mov eax, [height]
    jmp set_width

set_width_rot02:
    mov eax, [width]

set_width:
    mov [dst_width], eax

    xor eax, eax
    xor edx, edx
    xor ecx, ecx
    xor ebx, ebx

;obliczenie liczby pikseli
    mov ax, [width]
    mov cx, [height]
    mul cx
    mov [size], ax
    mov [size+2], dx

    clean_reg

    cmp [rotation], dword 1
    je pre_rot1
    cmp [rotation], dword 2
    je pre_rot2
    cmp [rotation], dword 3
    je pre_rot3

    jmp loop

pre_rot1:
    mov eax, [width]
    dec eax
    mov [dst_y], eax
    jmp loop

pre_rot2:
    mov eax, [width]
    dec eax
    mov [dst_x], eax

    mov eax, [height]
    dec eax
    mov [dst_y], eax

    jmp loop

pre_rot3:
    mov eax, [height]
    dec eax
    mov [dst_x], eax

loop:
    mov eax, [pos]
    cmp eax, [size]
    je end

    move_from_xy_to_xy

    cmp [rotation], dword 1
    je step_rot1
    cmp [rotation], dword 2
    je step_rot2
    cmp [rotation], dword 3
    je step_rot3

step_rot0:
    inc dword [dst_x]
    mov eax, [dst_x]
    cmp eax, [width]
    jne not_dst_line_end
    jmp goto_next_dst_line_rot0

step_rot1:
    dec dword [dst_y]
    cmp [dst_y], dword -1
    jne not_dst_line_end
    jmp goto_next_dst_line_rot1

step_rot2:
    dec dword [dst_x]
    cmp [dst_x], dword -1
    jne not_dst_line_end
    jmp goto_next_dst_line_rot2

step_rot3:
    inc dword [dst_y]
    mov eax, [dst_y]
    cmp eax, [width]
    jne not_dst_line_end
    jmp goto_next_dst_line_rot3

goto_next_dst_line_rot0:
    inc dword [dst_y]
    mov [dst_x], dword 0
    jmp not_dst_line_end

goto_next_dst_line_rot1:
    inc dword [dst_x]
    mov eax, [width]
    dec eax
    mov [dst_y], eax
    jmp not_dst_line_end

goto_next_dst_line_rot2:
    dec dword [dst_y]
    mov eax, [width]
    dec eax
    mov [dst_x], eax
    jmp not_dst_line_end

goto_next_dst_line_rot3:
    dec dword [dst_x]
    mov [dst_y], dword 0
    jmp not_dst_line_end

not_dst_line_end:
    inc dword [pos]
    jmp loop

end:
    mov esp,ebp
    pop ebp
    ret
