TITLE PROJECT


INCLUDE Irvine32.inc
INCLUDE macros.inc

BUFFER_SIZE = 50000
; anal interface
.data
buffer BYTE BUFFER_SIZE DUP(?)
var BYTE BUFFER_SIZE DUP(?)

filename    BYTE 80 DUP(0)
fileHandle  HANDLE ?

name1 BYTE "TechInitialVisual.txt",0,
		   "FoodMenuVisualAfter.txt",0, 
		   "dragon150.txt",0,
		   "CSTAPPY.txt",0


name_index BYTE 0, 22, 46, 60

.code

filesummon PROTO, fileindex:PTR BYTE, colordisplay:PTR DWORD, posX: PTR BYTE, posY: PTR BYTE, isCoordinateBased:PTR BYTE, shouldClearScreen: PTR BYTE
copySTRING PROTO, index:PTR BYTE
copyBuffer PROTO, posX:PTR BYTE, posY:PTR BYTE
bufferclean PROTO

main PROC
	mov edx,0

	invoke filesummon, 3, (black+(white*16)),0,35,0,0 ;-------FILE NAME INDEX, COLOR OF TEXT+BACKGROUND, COORDINATES FOR X, COORDINATES FOR Y, IF COORDINATES APPLY, CLEAR SCREEN?------;
	invoke filesummon, 1, (black+(red*16)),0,35,1,1
	;invoke filesummon, 1, (lightblue+(red*16)),0,0,1,0
	invoke filesummon, 1, (white+(red*16)),25,0,1,0
	;invoke filesummon, 2, (black+(white*16)),0,25,0,1


exit
main ENDP


filesummon PROC, fileindex:PTR BYTE, colordisplay:PTR DWORD, posX: PTR BYTE, posY: PTR BYTE, isCoordinateBased:PTR BYTE,shouldClearScreen: PTR BYTE
	call bufferclean
	mov dx,0
	call Gotoxy
	invoke copySTRING,[fileindex]
	mov esi, colordisplay

	mov	edx,OFFSET filename
	call	OpenInputFile
	mov	fileHandle,eax

	cmp	eax,INVALID_HANDLE_VALUE		; error opening file?
	jne	file_ok					; no: skip
	mWrite <"Cannot open file",0dh,0ah>
	jmp	quit						; and quit
file_ok:

	mov	edx,OFFSET buffer
	mov	ecx,BUFFER_SIZE
	call	ReadFromFile
	jnc	check_buffer_size			; error reading?
	mWrite "Error reading file. "		; yes: show error message
	call	WriteWindowsMsg
	jmp	close_file
	
check_buffer_size:
	cmp	eax,BUFFER_SIZE			; buffer large enough?
	jb	buf_size_ok				; yes
	mWrite <"Error: Buffer too small for the file",0dh,0ah>
	jmp	quit						; and quit
	
buf_size_ok:	
	mov	buffer[eax],0		; insert null terminator
	mWrite "File size: "
	call	WriteDec			; display file size
	call	Crlf

; Display the buffer.
	mWrite <"Buffer:",0dh,0ah,0dh,0ah>

	mov	edx,OFFSET buffer	; display the buffer
	mov  eax,[colordisplay]
    call SetTextColor

	mov al, BYTE PTR [shouldClearScreen]
	cmp al,0
	je NoClear
	
	call Clrscr

	NoClear:
	
	mov al, BYTE PTR [isCoordinateBased]
	cmp al,0
	jne IsCoordinate

	call	WriteString
	call	Crlf
	jmp close_file


	IsCoordinate:
	invoke copyBuffer,[posX],[posY]



close_file:
	mov	eax,fileHandle
	call CloseFile



quit:

	ret 
filesummon ENDP



copySTRING PROC, index:PTR BYTE
	mov edx, [index]
	PUSHAD
	mov edi, OFFSET filename
	mov ebx, OFFSET name1
	mov esi, lengthof name1-1
	mov ecx, esi
	L1:
	movzx eax, name_index[edx] ;----------------------------WHICH FILE OFFSET--------------------------------;
	neg ecx
	add eax, esi
	add eax,ecx
	mov al,name1[eax]
	mov BYTE PTR filename[esi][ecx],al
	neg ecx
	Loop L1
	POPAD
	ret
copySTRING ENDP


copyBuffer PROC, posX:PTR BYTE, posY:PTR BYTE
	
	local variable:BYTE
	mov edx,0
	mov dh, BYTE PTR [posX]
	mov dl, BYTE PTR [posY]
	call Gotoxy
	push edx

	mov ecx, BUFFER_SIZE
	lea esi, buffer
	lea edi, variable

	L1:
	mov al, [esi]
	inc esi

	cmp al, 0Ah
	je outer
	mov [edi], al
	mov edx,edi
	call writechar

Loop L1
ret

outer:
	pop edx
	mov dl, BYTE PTR [posY]
	inc dh
	push edx
	call Gotoxy

Loop L1	

ret
copyBuffer ENDP



bufferclean PROC
	mov edi, offset buffer
	mov esi, offset var

	mov ecx, lengthof buffer
	rep movsb
	
ret
bufferclean ENDP

END main
