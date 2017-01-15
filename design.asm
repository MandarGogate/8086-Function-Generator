#make_bin#

#load_segment=ffffh#
#load_offset=0000h#

#cs=0000h#
#ip=0000h#

#ds=0000h#
#es=0000h#

#ss=0000h#
#sp=fffeh#

#ax=0000h#
#bx=0000h#
#cx=0000h#
#dx=0000h#
#si=0000h#
#di=0000h#
#bp=0000h#
    jmp     st1   
    db    1021 dup(0)
;main program          
    st1:      cli
;data allocations
    onek    db      0
    tenk    dw      0
    sine    db      0
    tria    db      0
    square  db      0
    hundred db      0
    ten     db      0
    count   dw      0
    list    db      13 dup(0)
;intialize ds, es,ss to start of ram
    mov     ax,0200h
    mov     ds,ax
    mov     es,ax
    mov     ss,ax
    mov     sp,0fffeh    
    mov     ax,0
    mov     tenk,ax
    mov     onek,al
    mov     tenk,ax
    mov     hundred,al
    mov     ten,al
    mov     sine,al
    mov     tria,al
    mov     square,al
    ;table for generating sine
    lea     di,list
    mov     [di],128
    mov     [di+1],144
    mov     [di+2],160    
    mov     [di+3],176    
    mov     [di+4],191
    mov     [di+5],205
    mov     [di+6],218
    mov     [di+7],228
    mov     [di+8],238
    mov     [di+9],245
    mov     [di+10],251
    mov     [di+11],254
    mov     [di+12],255
;intialise 8255
    mov     al,10001010b
    out     06h,al    
;keypad interfacing    
x:	mov     al,00h
    out     04h,al
x1: in      al,04h
    and     al,070h
    cmp     al,70h
    jnz     x1
x2: in      al,04h
    and     al,070h
    cmp     al,70h
    je      x2  
    mov     al,06h
    mov     bl,al
    out     04h,al
    in      al,04h
    and     al,070h
    cmp     al,70h
    jnz     x3
    mov     al,05h
    mov     bl,al
    out     04h,al
    in      al,04h
    and     al,070h
    cmp     al,70h
    jnz     x3
    mov     al,03h
    mov     bl,al
    out     04h,al
    in      al,04h
    and     al,070h
    cmp     al,70h
    jz      x2
x3: or      al,bl
    cmp     al,66h ;sine
    jz      sin
    cmp     al,56h ; tri
    jz      tri
    cmp     al,36h;square
    jz      squ
    cmp     al,65h;10k
    jz      tk
    cmp     al,55h;1k
    jz      ok
    cmp     al,35h;100
    jz      hun
    cmp     al,33h;10
    jz      te
    cmp     al,63h;generate
    jz      end
;incrementing counts    
tk: ;inc     tenk 
    jmp     x      
ok: inc     onek 
    jmp     x  
hun:inc hundred
    jmp     x 
te: inc ten
    jmp     x 
squ:inc square
    jmp     x
tri:inc tria 
    jmp     x
sin:inc sine
    jmp     x
end: 
    ;calculating count for 8254
    ;mov   ax,1000
    ;mul   tenk
    ;mov   bx,ax
    mov     bx,0
    mov     al,100
    mul     onek
    add     bx,ax
    mov     al,10
    mul     hundred
    add     bx,ax
    mov     al,ten
    mov     ah,00
    add     bx,ax
    ;bx  =  req freq/10
    mov     dx,0
    mov     ax,2710h
    div     bx
    shr     bx,1
    cmp     bx,dx
    jae  i
    inc  ax
    i:mov count,ax
    ;storing count
	mov     al,00h
    out     04h,al
    ;checking for generate to release    
k1: in      al,04h
    and     al,070h
    cmp     al,70h
    jnz     k1
    ;bx = actual count * sampling rate
    ;selecting wave form
    mov     al,sine
    cmp     al,00
    ja      sg
    mov     al,tria
    cmp     al,00
    ja      tg
    jmp     sqg              
sg: mov     dx,0
    mov     ax,count
    mov     bx,50
    div     bx
    shr     bx,1
    cmp     bx,dx
    ja      q1
    inc     ax
q1: mov     bx,ax
    mov     al,00110110b
	out     0eh,al
	mov     al,bl
	out     08h,al
	mov     al,bh
    out     08h,al
    jmp     sineg
tg: mov     dx,0
    mov     ax,count
    mov     bx,30
    div     bx
    shr     bx,1
    cmp     bx,dx
    ja      qr1
    inc     ax 
qr1:mov     bx,ax
    mov     al,00110110b
	out     0eh,al
	mov     al,bl
	out     08h,al
	mov     al,bh
    out     08h,al
    jmp     triag
sineg:
l5: in      al,04h
    and     al,070h
    cmp     al,70h
    jne     key
    lea     si,list
    mov     cl,13
l1:
    mov     al,[si]
    out     00,al               
p1: in      al,02h
    cmp     al,0
    jne     p1
p2: in      al,02h
    cmp     al,80h
    jne     p2 
J1: add     si,1
    loop    l1
    dec     si     
    mov     cl,12
l2: sub     si,1
    mov     al,[si]
    out     00,al              
p3: in      al,02h
    cmp     al,0
    jne     p3
p4: in      al,02h
    cmp     al,80h
    jne     p4
J2: loop    l2
    lea     si,list
    mov     cl,12
    inc     si
l3: mov     al,[si]
    not     al
    out     00,al   
p5: in      al,02h
    cmp     al,0
    jne     p5
p6: in      al,02h
    cmp     al,80h
    jne     p6
J3: add     si,1
    loop    l3
    mov     cl,13
l4:
    sub     si,1
    mov     al,[si]
    not     al
    out     00,al 
p7: in      al,02h
    cmp     al,0
    jne     p7
p8: in      al,02h
    cmp     al,80h
    jne     p8
    loop    l4
    jmp     l5

triag:
    mov al,00h
g1:
    out     00,al
    mov     bl,al
    e1:     in al,02h
    cmp     al,0
    jne     e1
    e2:     in al,02h
    cmp     al,80h
    jne     e2
    in      al,04h
    and     al,070h
    cmp     al,70h
    jne      key
    mov     al,bl
    add     al,17
    cmp     al,0ffh
    jnz     g1       
g2:
    out     00,al
    mov     bl,al
e3: in      al,02h
    cmp     al,0
    jne     e3
e4: in      al,02h
    cmp     al,80h
    jne     e4                 
    in      al,04h
    and     al,070h
    cmp     al,70h
    jne      key
    mov     al,bl 
    sub     al,17
    cmp     al,00h
    jnz     g2
    jmp     g1
    
sqg:mov     bx,count
    shr     bx,1
    dec     bx
    mov     al,00110100b
	out     0eh,al
	mov     al,bl
	out     08h,al
	mov     al,bh
    out     08h,al
    mov     al,80h
    out     00,al
s:  mov     al,00h
    out     00,al
    in      al,04h
    and     al,070h
    cmp     al,70h
    jne      key
    call    delay
    in      al,04h
    and     al,070h
    cmp     al,70h
    jne      key 
    mov     al,0ffh
    out     00,al
    mov     al,0ffh
    out     00,al
    in      al,04h
    and     al,070h
    cmp     al,70h
    jne      key 
    call    delay
    in      al,04h
    and     al,070h
    cmp     al,70h
    jne      key
    mov     al,0ffh
    out     00,al           
    jmp     s
;checking for which waveform key is pressed
key:mov     al,06h
    mov     bl,al
    out     04h,al
    in      al,04h
    and     al,070h
    cmp     al,70h
    jnz     k3
    mov     al,05h
    mov     bl,al
    out     04h,al
    in      al,04h
    and     al,070h
    cmp     al,70h
    jnz     k3
    mov     al,03h
    mov     bl,al
    out     04h,al
    in      al,04h
    and     al,070h
    cmp     al,70h
    je      key
k3: or      al,bl
    cmp     al,66h ;sine
    jz      sg
    cmp     al,56h ; tri
    jz      tg
    cmp     al,36h;square
    jz      sqg
    jmp     key
;delay procedure
delay proc
v1: in      al,02h
    cmp     al,0
    jne     v1
v2: in      al,02h
    cmp     al,80h
    jne     v2
ret
endp
keycheck proc
    in      al,04h
    and     al,070h
    cmp     al,70h
    jne      key 
ret
endp    