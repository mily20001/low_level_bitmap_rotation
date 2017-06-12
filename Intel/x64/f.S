section .text

%define pixels   rdi
%define output   rsi
%define width    r10
%define height   r9
%define rotation r8

%define size      r11d
%define pos       r12d
%define dst_pos   r13d
%define dst_x     r14w
%define dst_y     r15w
%define dst_width rbp-8

%macro clean_reg 0
    xor rax, rax
    xor rdx, rdx
    xor rcx, rcx
    xor rbx, rbx
%endmacro

%macro calc_dst_pos 4
    ;%1 - x addr
    ;%2 - y addr
    ;%3 - dest addr
    ;%4 line width addr
    clean_reg

    mov ax, [%4]
    mov cx, %2
    mul ecx
    mov %3, eax
    mov edx, %3
    mov bx, %1
    add ebx, eax
    mov eax, 3
    mul ebx
    mov %3, eax ;ignoring higher part

%endmacro

%macro  move_from_xy_to_xy 0  ;moves one pixel (3 subpixels)
    calc_dst_pos dst_x, dst_y, dst_pos, dst_width

    clean_reg

    mov ebx, pos
    mov rax, 3
    mul ebx
    
    add rax, pixels
    mov bx, [rax]
    mov cl, [rax+2]

    mov rax, output
    mov edx, dst_pos
    add rax, rdx
    mov [rax], bx
    mov [rax+2], cl
%endmacro


global f
f:	
	push rbp
	mov rbp,rsp
	sub esp, 8

	mov r9, rcx
	mov r10, rdx

	mov pos, dword 0
	mov dst_x, word 0
	mov dst_y, word 0

    cmp rotation, qword 0
    je set_width_rot02
    cmp rotation, qword 2
    je set_width_rot02

set_width_rot13:
    mov rax, height
    jmp set_width

set_width_rot02:
    mov rax, width

set_width:
    mov [dst_width], rax

    xor rax, rax
    xor rdx, rdx
    xor rcx, rcx
    xor rbx, rbx

;obliczenie liczby pikseli
    mov rax, width
    mov rcx, height
    mul ecx
    mov size, eax

    clean_reg

    cmp rotation, qword 1
    je pre_rot1
    cmp rotation, qword 2
    je pre_rot2
    cmp rotation, qword 3
    je pre_rot3

    jmp loop

pre_rot1:
    mov rax, width
    dec ax
    mov dst_y, ax
    jmp loop

pre_rot2:
    mov rax, width
    dec ax
    mov dst_x, ax

    mov rax, height
    dec ax
    mov dst_y, ax

    jmp loop

pre_rot3:
    mov rax, height
    dec ax
    mov dst_x, ax

loop:
    mov eax, pos
    cmp eax, size
    je end

    move_from_xy_to_xy

    cmp rotation, qword 1
    je step_rot1
    cmp rotation, qword 2
    je step_rot2
    cmp rotation, qword 3
    je step_rot3

step_rot0:
    inc dst_x
    xor rax, rax
    mov ax, dst_x
    cmp rax, width
    jne not_dst_line_end
    jmp goto_next_dst_line_rot0

step_rot1:
    dec dst_y
    cmp dst_y, word -1
    jne not_dst_line_end
    jmp goto_next_dst_line_rot1

step_rot2:
    dec dst_x
    cmp dst_x, word -1
    jne not_dst_line_end
    jmp goto_next_dst_line_rot2

step_rot3:
    inc dst_y
    xor rax, rax
    mov ax, dst_y
    cmp rax, width
    jne not_dst_line_end
    jmp goto_next_dst_line_rot3

goto_next_dst_line_rot0:
    inc dst_y
    mov dst_x, word 0
    jmp not_dst_line_end

goto_next_dst_line_rot1:
    inc dst_x
    mov rax, width
    dec ax
    mov dst_y, ax
    jmp not_dst_line_end

goto_next_dst_line_rot2:
    dec dst_y
    mov rax, width
    dec ax
    mov dst_x, ax
    jmp not_dst_line_end

goto_next_dst_line_rot3:
    dec dst_x
    mov dst_y, word 0

not_dst_line_end:
    inc pos
    jmp loop

end:
	mov rsp,rbp
	pop rbp
	ret
