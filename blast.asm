; another attempt to terminate program with Esc that hooks
; keyboard interrupt
[org 0x100]
jmp start
;==============================================================================================================================
message:db 'AABBCCDDEE'
message1:db '          '                        ; THIS IS FOR SLIDER
oldisr: dd 0
pos: dw 0x1622
;==============================================================================================================================
message2:db '  ########  '
bricks:dw 7                                    ; THIS IS FOR BRICKS 
brickline:dw 0
brickcounter:dw 1
totalbrick:dw 21
;===============================================================================================================================
ballpos:dw 0x0B24
ball:db 'O'
ballspace:db ' '
updownflag:dw 0                                     ;THIS IS FOR BALL MOVEMENT
lives:dw 3
decincflag:dw 0
;===============================================================================================================================
tickcount:dw 0                                   ; this for timer
seccount:dw 0
mincount:dw 0
tickcount1:dw 0
bouflg:dw 0
;===============================================================================================================================
scrmsg: db 'Score :'
timemsg: db 'Time :'                             ; this for result screen
colne :db ':'
heart:db 'lives :'
overmsg:db 'GAME OVER, YOU LOSE'
winmsg:db 'YOU WIN THE GAME'
winb:db 'YOU WIN THE GAME AND GOT BOUNS'
;================================================================================================================================

clrscr: 
push es
push ax
push cx
push di
mov ax, 0xb800
mov es, ax ; point es to video base
xor di, di ; point di to top left column
mov ax, 0x0720 ; space char in normal attribute
mov cx, 2000 ; number of screen locations
cld ; auto increment mode
rep stosw ; clear the whole screen
pop di
pop cx
pop ax
pop es
ret

Bricksprint: 
push ax
push es

mov dh,2
mov dl,0
mov bl,1
next1:
mov word[bricks],7 
mov bl,1                            
next:

mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, bl ; normal attrib
mov dx, dx ; row 10 column 3
mov cx, 12 ; length of string
push cs
pop es ; segment of string
mov bp, message2 ; offset of string
int 0x10

add dl,11
add bl,1
sub word[bricks],1
cmp word[bricks],0
jne next

add dh,2
mov dl,0
add word[brickline],2
cmp word[brickline],6
jne next1

pop es
pop ax
ret ; return from interrup


boundry:
push ax
push cx
push si 
push di

mov ax,0xb800
mov es,ax
mov cx,80
mov di,0
mov si,3680
nextchr:
mov word[es:di],0x01DB
mov word[es:si],0x01DB

add si,2
add di,2
loop nextchr

mov cx,25
mov di,0
mov si,158

nextchr1:
mov word[es:di],0x01DB
mov word[es:si],0x01DB

add si,160
add di,160
loop nextchr1

pop di
pop si
pop cx
pop ax
ret

;=====================================================================================================================================

kbisr: 
push ax
push es


mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, 66 ; normal attrib
mov dx, [cs:pos] ; row 10 column 3
mov cx, 10 ; length of string
push cs
pop es ; segment of string
mov bp, message ; offset of string
int 0x10


                             
in al, 0x60                             
cmp al, 0x4d
jne lb1 

cmp dl,0x46
je exit11

mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, 7 ; normal attrib
mov dx, [cs:pos] ; row 10 column 3
mov cx, 10 ; length of string
push cs
pop es ; segment of string
mov bp, message1 ; offset of string
int 0x10

exit11:
cmp dl,0x46
je exit
add dl,1
mov [cs:pos],dx
mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, 66 ; normal attrib
mov dx, [cs:pos] ; row 10 column 3
mov cx, 10 ; length of string
push cs
pop es ; segment of string
mov bp, message ; offset of string
int 0x10
jmp exit

lb1:

in al, 0x60                             
cmp al, 0x4b
jne lb4 
cmp dl,0x01
je exit
mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, 7 ; normal attrib
mov dx, [cs:pos] ; row 10 column 3
mov cx, 10 ; length of string
push cs
pop es ; segment of string
mov bp, message1 ; offset of string
int 0x10

cmp dl,0x01
je exit
sub dl,1
mov [cs:pos],dx

mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, 66 ; normal attrib
mov dx, [cs:pos] ; row 10 column 3
mov cx, 10 ; length of string
push cs
pop es ; segment of string
mov bp, message ; offset of string
int 0x10
jmp exit


lb4:
pop es
pop ax
jmp far [cs:oldisr] ; call the original ISR

exit: 
mov al, 0x20
out 0x20, al ; send EOI to PIC
pop es
pop ax
iret ; return from interrup


;==================================================================================================================================

brickbroke:
push bp
mov bp,sp
push ax
push bx
push cx
push dx
push si 
push di

mov ax,0xb800
mov es,ax

mov si,si
;add si,2
mov cx,9
looop:
cmp byte[es:si],0x23
jne breakloop
add si,2
jmp looop

breakloop:

mov word[es:si],0x0720
sub si,2
loop breakloop


pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop bp
ret 


sound:
mov ax,1111
out 42h,al
mov al,ah
out 42h,al

mov al,61h
mov al,11b
out 61h,al

ret


soundoff:

mov al,61h
out 61h,al

ret

;==================================================================================================================================
move:
push ax
push bx
push cx
push dx
push si
push di

mov ax,3860
push ax
push word[brickcounter]
call printnum



mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, 7 ; normal attrib
mov dx, [cs:ballpos] ; row 10 column 3
mov cx, 1 ; length of string
push cs
pop es ; segment of string
mov bp, ballspace ; offset of string
int 0x10

cmp word[updownflag],0
je strightdown
cmp word[updownflag],1
je up
cmp word[updownflag],2
je lu
cmp word[updownflag],3
je ru
cmp word[updownflag],4
je llu
cmp word[updownflag],5
je rru
cmp word[updownflag],6
je rrd
cmp word[updownflag],7
je lld
cmp word[updownflag],8
je ld
cmp word[updownflag],9
je rd


strightdown:

add dh,1
mov [ballpos],dx

mov ax,0xb800
mov es,ax
mov ax,0
mov bx,0
mov al,80
mul dh
mov bl,dl
add ax,bx
shl ax,1
mov si,ax


jmp contin1
ru:
jmp rightup

up:
jmp uper

llu:
jmp leftleftup

lu:
jmp leftup

rru:
jmp rightrightup

rrd:
jmp rightrightdown

lld:
jmp leftleftdown

ld:
jmp leftdown

rd:
jmp rightdown

contin1:

cmp byte[es:si],0x43
jne skip1

mov word[updownflag],1
jmp uper

skip1:
cmp byte[es:si],0x42
jne skip2
mov word[updownflag],2
jmp leftup

skip2:
cmp byte[es:si],0x44
jne skip3
mov word[updownflag],3
jmp rightup

skip3:
cmp byte[es:si],0x41
jne skip4
mov word[updownflag],4
jmp leftleftup

skip4:
cmp byte[es:si],0x45
jne skip5
mov word[updownflag],5
jmp rightrightup

skip5:

cmp dh,23
jae skip6
jne skip7
skip6:
sub word[lives],1
mov word[ballpos], 0x0B24

skip7:
mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, 7 ; normal attrib
mov dx, [cs:ballpos] ; row 10 column 3
mov cx, 1 ; length of string
push cs
pop es ; segment of string
mov bp, ball ; offset of string
int 0x10
jmp exit12

uper:


sub dh,1
mov [ballpos],dx
;....................................

mov ax,0xb800
mov es,ax
mov ax,0
mov bx,0
mov al,80
mul dh
mov bl,dl
add ax,bx
shl ax,1
mov si,ax
cmp byte[es:si],0x23
jne step1
call brickbroke
call sound
mov cx,0xffff
s1:
loop s1
call soundoff
add word[brickcounter],1
sub word[totalbrick],1
mov word[updownflag],0
jmp strightdown

step1:
cmp dh,0
jle lb11
jne lb12
lb11:
mov word[updownflag],0
jmp strightdown

lb12:

mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, 7 ; normal attrib
mov dx, [cs:ballpos] ; row 10 column 3
mov cx, 1 ; length of string
push cs
pop es ; segment of string
mov bp, ball ; offset of string
int 0x10
jmp exit12


leftup:

sub dh,1
sub dl,1
mov [ballpos],dx

mov ax,0xb800
mov es,ax
mov ax,0
mov bx,0
mov al,80
mul dh
mov bl,dl
add ax,bx
shl ax,1
mov si,ax
cmp byte[es:si],0x23
jne step2
call brickbroke
call sound
mov cx,0xffff
s2:
loop s2
call soundoff
add word[brickcounter],1
sub word[totalbrick],1
mov word[updownflag],8
jmp leftdown

step2:

cmp dl,0
jle chng4
jne lfu1

chng4:
mov word[updownflag],3
jmp rightup

lfu1:

cmp dh,1
jle lb7
jne lb8
lb7:
mov word[updownflag],8
jmp leftdown

lb8:
mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, 7 ; normal attrib
mov dx, [cs:ballpos] ; row 10 column 3
mov cx, 1 ; length of string
push cs
pop es ; segment of string
mov bp, ball ; offset of string
int 0x10
jmp exit12


leftleftup:


sub dh,1
sub dl,3
mov [ballpos],dx

mov ax,0xb800
mov es,ax
mov ax,0
mov bx,0
mov al,80
mul dh
mov bl,dl
add ax,bx
shl ax,1
mov si,ax
cmp byte[es:si],0x23
jne step3
call brickbroke
call sound
mov cx,0xffff
s3:
loop s3
call soundoff
add word[brickcounter],1
sub word[totalbrick],1
mov word[updownflag],7
jmp leftleftdown

step3:

cmp dl,0
jle chng
jne llfu1

chng:
mov word[updownflag],5
jmp rightrightup

llfu1:
cmp dh,1
jle lb5
jne lb6
lb5:
mov word[updownflag],7
jmp leftleftdown

lb6:

mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, 7 ; normal attrib
mov dx, [cs:ballpos] ; row 10 column 3
mov cx, 1 ; length of string
push cs
pop es ; segment of string
mov bp, ball ; offset of string
int 0x10
jmp exit12


rightup:

sub dh,1
add dl,1
mov [ballpos],dx

mov ax,0xb800
mov es,ax
mov ax,0
mov bx,0
mov al,80
mul dh
mov bl,dl
add ax,bx
shl ax,1
mov si,ax
cmp byte[es:si],0x23
jne step4
call brickbroke
call sound
mov cx,0xffff
s4:
loop s4
call soundoff
add word[brickcounter],1
sub word[totalbrick],1
mov word[updownflag],9
jmp rightdown

step4:

cmp dl,79
jge chng2
jne riu2

chng2:
mov word[updownflag],2
jmp leftup

riu2:

cmp dh,0
jle lb9
jne lb10
lb9:
mov word[updownflag],9
jmp rightdown

lb10:

mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, 7 ; normal attrib
mov dx, [cs:ballpos] ; row 10 column 3
mov cx, 1 ; length of string
push cs
pop es ; segment of string
mov bp, ball ; offset of string
int 0x10
jmp exit12

rightrightup:

sub dh,1
add dl,3
mov [ballpos],dx

mov ax,0xb800
mov es,ax
mov ax,0
mov bx,0
mov al,80
mul dh
mov bl,dl
add ax,bx
shl ax,1
mov si,ax
cmp byte[es:si],0x23
jne step5
call brickbroke
call sound
mov cx,0xffff
s5:
loop s5
call soundoff
add word[brickcounter],1
sub word[totalbrick],1
mov word[updownflag],6
jmp rightrightdown

step5:

cmp dl,79
jge chng1
jne rriu1

chng1:
mov word[updownflag],4
jmp leftleftup

rriu1:

cmp dh,0
jle lb2
jne lb3
lb2:
mov word[updownflag],6
jmp rightrightdown

lb3:

mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, 7 ; normal attrib
mov dx, [cs:ballpos] ; row 10 column 3
mov cx, 1 ; length of string
push cs
pop es ; segment of string
mov bp, ball ; offset of string
int 0x10
jmp exit12



rightrightdown:

add dh,1
add dl,3
mov [ballpos],dx

mov ax,0xb800
mov es,ax
mov ax,0
mov bx,0
mov al,80
mul dh
mov bl,dl
add ax,bx
shl ax,1
mov si,ax
cmp byte[es:si],0x23
jne step6
call brickbroke
call sound
mov cx,0xffff
s6:
loop s6
call soundoff
add word[brickcounter],1
sub word[totalbrick],1
mov word[updownflag],5
jmp rightrightup

step6:

cmp dl,79
jge chng5
jne rrid1

chng5:
mov word[updownflag],7
jmp leftleftdown

rrid1:

cmp dh,22
jne next2

mov ax,0xb800
mov es,ax
mov ax,0
mov bx,0
mov al,80
mul dh
mov bl,dl
add ax,bx
shl ax,1
mov si,ax
jmp contin1

next2:

cmp dh,23
jae skip8
jne skip9
skip8:
sub word[lives],1
mov word[ballpos], 0x0B24

skip9:



mov ax,0xb800
mov es,ax
mov ax,0
mov bx,0
mov al,80
mul dh
mov bl,dl
add ax,bx
shl ax,1
mov si,ax

mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, 7 ; normal attrib
mov dx, [cs:ballpos] ; row 10 column 3
mov cx, 1 ; length of string
push cs
pop es ; segment of string
mov bp, ball ; offset of string
int 0x10
jmp exit12

leftleftdown:
add dh,1
sub dl,3
mov [ballpos],dx

mov ax,0xb800
mov es,ax
mov ax,0
mov bx,0
mov al,80
mul dh
mov bl,dl
add ax,bx
shl ax,1
mov si,ax
cmp byte[es:si],0x23
jne step7
call brickbroke
call sound
mov cx,0xffff
s7:
loop s7
call soundoff
add word[brickcounter],1
sub word[totalbrick],1
mov word[updownflag],4
jmp leftleftup

step7:

cmp dl,1
jle chng6
jne llfd1
chng6:
mov word[updownflag],6
jmp rightrightdown

llfd1:

cmp dh,22
jne next3

mov ax,0xb800
mov es,ax
mov ax,0
mov bx,0
mov al,80
mul dh
mov bl,dl
add ax,bx
shl ax,1
mov si,ax
jmp contin1

next3:

cmp dh,23
jae skip10
jne skip11
skip10:
sub word[lives],1
mov word[ballpos], 0x0B24

skip11:


mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, 7 ; normal attrib
mov dx, [cs:ballpos] ; row 10 column 3
mov cx, 1 ; length of string
push cs
pop es ; segment of string
mov bp, ball ; offset of string
int 0x10
jmp exit12


leftdown:
add dh,1
sub dl,1
mov [ballpos],dx

mov ax,0xb800
mov es,ax
mov ax,0
mov bx,0
mov al,80
mul dh
mov bl,dl
add ax,bx
shl ax,1
mov si,ax
cmp byte[es:si],0x23
jne step8
call brickbroke
call sound
mov cx,0xffff
s8:
loop s8
call soundoff
add word[brickcounter],1
sub word[totalbrick],1
mov word[updownflag],2
jmp leftup

step8:

cmp dl,1
jle chng7
jne lfd1
chng7:
mov word[updownflag],9
jmp rightdown

lfd1:
cmp dh,22
jne next4

mov ax,0xb800
mov es,ax
mov ax,0
mov bx,0
mov al,80
mul dh
mov bl,dl
add ax,bx
shl ax,1
mov si,ax
jmp contin1

next4:


cmp dh,23
jae skip12
jne skip13
skip12:
sub word[lives],1
mov word[ballpos], 0x0B24

skip13:

mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, 7 ; normal attrib
mov dx, [cs:ballpos] ; row 10 column 3
mov cx, 1 ; length of string
push cs
pop es ; segment of string
mov bp, ball ; offset of string
int 0x10
jmp exit12


rightdown:

add dh,1
add dl,1
mov [ballpos],dx

mov ax,0xb800
mov es,ax
mov ax,0
mov bx,0
mov al,80
mul dh
mov bl,dl
add ax,bx
shl ax,1
mov si,ax
cmp byte[es:si],0x23
jne step9
call brickbroke
call sound
mov cx,0xffff
s9:
loop s9
call soundoff
add word[brickcounter],1
sub word[totalbrick],1
mov word[updownflag],3
jmp rightup

step9:

cmp dl,79
jge chng8
jne rid1

chng8:
mov word[updownflag],8
jmp leftdown

rid1:
cmp dh,22
jne next5

mov ax,0xb800
mov es,ax
mov ax,0
mov bx,0
mov al,80
mul dh
mov bl,dl
add ax,bx
shl ax,1
mov si,ax
jmp contin1

next5:

cmp dh,23
jae skip14
jne skip15
skip14:
sub word[lives],1
mov word[ballpos], 0x0B24

skip15:
mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, 7 ; normal attrib
mov dx, [cs:ballpos] ; row 10 column 3
mov cx, 1 ; length of string
push cs
pop es ; segment of string
mov bp, ball ; offset of string
int 0x10
jmp exit12

exit12:

pop di
pop si
pop dx
pop cx
pop bx
pop ax
ret

printnum: 
push bp
mov bp, sp
push es
push ax
push bx
push cx
push dx
push di
mov ax, 0xb800
mov es, ax                  ; point es to video base
mov ax, [bp+4]               ; load number in ax
mov bx, 10                ; use base 10 for division
mov cx, 0                 ; initialize count of digits
nextdigit: 
mov dx, 0                ; zero upper half of dividend
div bx                       ; divide by 10
add dl, 0x30                  ; convert digit into ascii value
push dx                       ; save ascii value on stack
inc cx                   ; increment count of values
cmp ax, 0                 ; is the quotient zero
jnz nextdigit                   ; if no divide it again
mov di, [bp+6]                    ; point di to top left column
nextpos: 
pop dx ; remove a digit from the stack
mov dh, 0x07 ; use normal attribute
mov [es:di], dx ; print char on screen
add di,2 ; move to next screen location
loop nextpos ; repeat for all digits on stack
pop di
pop dx
pop cx
pop bx
pop ax
pop es
pop bp
ret 4


;===================================================================================================================================
timer:

push ax
call boundry  

mov ax,3914
push ax
push word[cs:lives]
call printnum

cmp word[cs:lives],0
jle skip16
jne skip17

skip16:

mov dh,12
mov dl,30
mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, 07 ; normal attrib
mov dx, dx ; row 10 column 3
mov cx, 19 ; length of string
push cs
pop es ; segment of string
mov bp, overmsg ; offset of string
int 0x10

jmp skip

skip17:


cmp word[cs:totalbrick],0
ja skip19

cmp word[cs:bouflg],1
je skippp

cmp word[cs:mincount],4
jle ddd
jne skip20

ddd:
mov dh,12
mov dl,30
mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, 07 ; normal attrib
mov dx, dx ; row 10 column 3
mov cx, 29 ; length of string
push cs
pop es ; segment of string
mov bp, winb ; offset of string
int 0x10
add word[cs:bouflg],1
mov ax,3860
push ax
add word[cs:brickcounter],10
push word[cs:brickcounter]
call printnum
skippp:
jmp skip

skip20

mov dh,12
mov dl,30
mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, 07 ; normal attrib
mov dx, dx ; row 10 column 3
mov cx, 16 ; length of string
push cs
pop es ; segment of string
mov bp, winmsg ; offset of string
int 0x10

jmp skip

skip19:



add word[cs:tickcount1],1
cmp word[cs:tickcount1],18
jae down2
jne down1

down2:

add word[cs:seccount],1
mov ax,3982
push ax
push word[cs:seccount]
call printnum
mov word[cs:tickcount1],0

mov ax,3974
push ax
push word[cs:mincount]
call printnum

cmp word[cs:seccount],60
jae down3
jne down1

down3:
add word[cs:mincount],1

mov word[cs:seccount],0

down1:
cmp word[cs:tickcount],4
jne skipcount
jae fun

fun:
call move
mov word[cs:tickcount],0

skipcount:
add word[tickcount],1


skip:
	
mov al,0x20
out 0x20,al

pop ax
iret


start: 

call clrscr
call Bricksprint

mov dh,24
mov dl,2
mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, 07 ; normal attrib
mov dx, dx ; row 10 column 3
mov cx, 7 ; length of string
push cs
pop es ; segment of string
mov bp, scrmsg ; offset of string
int 0x10

mov dh,24
mov dl,30
mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, 07 ; normal attrib
mov dx, dx ; row 10 column 3
mov cx, 7 ; length of string
push cs
pop es ; segment of string
mov bp, heart ; offset of string
int 0x10


mov dh,24
mov dl,60
mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, 07 ; normal attrib
mov dx, dx ; row 10 column 3
mov cx, 6 ; length of string
push cs
pop es ; segment of string
mov bp, timemsg ; offset of string
int 0x10

mov dh,24
mov dl,69
mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, 07 ; normal attrib
mov dx, dx ; row 10 column 3
mov cx, 1 ; length of string
push cs
pop es ; segment of string
mov bp, colne ; offset of string
int 0x10


xor ax, ax
mov es, ax ; point es to IVT base
mov ax, [es:9*4]
mov [oldisr], ax ; save offset of old routine
mov ax, [es:9*4+2]
mov [oldisr+2], ax ; save segment of old routine
cli ; disable interrupts
mov word [es:9*4], kbisr ; store offset at n*4
mov [es:9*4+2], cs ; store segment at n*4+2

mov word [es:8*4], timer ; store offset at n*4
mov [es:8*4+2], cs ; store segment at n*4+2
sti ; enable interrupts

l1: 
mov ah, 0 ; service 0 – get keystroke
int 0x16 ; call BIOS keyboard service
cmp al, 27 ; is the Esc key pressed
jne l1 ; if no, check for next key

mov dx, start ; end of resident portion
add dx, 15 ; round up to next para
mov cl, 4
shr dx, cl ; number of paras
mov ax, 0x3100 ; terminate and stay resident
int 0x21