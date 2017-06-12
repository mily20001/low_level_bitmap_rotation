.data

buff: .space 4
buff2: .space 16
size: .space 4
offset: .space 4
width:	.space 4
height:	.space 4
begin: .space 4
begin2: .space 4
inFile: .space 100
outFile: .space 100

msg1: .asciiz "Program obracajacy obrazek\n"
msg2: .asciiz "rozmiar pliku: "
msg3: .asciiz "padding: "
msg4: .asciiz "rozmiar nowego pliku: "
msg10: .asciiz "podaj sciezke pliku wejsciowego: "
msg11: .asciiz "\npodaj liczbe obrotow: "
msg12: .asciiz "\npodaj kierunek (-1/1 => pdwz/zzwz): "
msg13: .asciiz "\npodaj sciezke pliku wyjsciowego: "
fileError: .asciiz "\ni/o error"
#inFile: .asciiz "/home/milosz/Dokumenty/ARKO/nasa2.bmp"
#outFile: .asciiz "/home/milosz/Dokumenty/ARKO/out1buf.bmp"

.text
.globl main

main:
	la $a0, msg1
	li $v0, 4
	syscall
	la $a0, msg10
	li $v0, 4
	syscall
	la $a0, inFile
	li $a1, 100
	li $v0, 8
	syscall
	
	li $t8, 0
findNewLine1:
	lb $t9, inFile($t8)
	beq $t9, 10, rmNewLine1
	addi $t8, $t8, 1
	bne $t9, 0, findNewLine1
rmNewLine1:
	li $t9, 0
	sb $t9, inFile($t8)
	
	li $a0, '\n'
	li $v0, 11
	syscall
	li $a0, '"'
	li $v0, 11
	syscall
	la $a0, inFile
	li $v0, 4
	syscall
	li $a0, '"'
	li $v0, 11
	syscall
	li $a0, '\n'
	li $v0, 11
	syscall
	
	la $a0, msg11
	li $v0, 4
	syscall
	li $v0, 5
	syscall
	move $t0, $v0
	
	la $a0, msg12
	li $v0, 4
	syscall
	li $v0, 5
	syscall
	move $t1, $v0
	
	la $a0, msg13
	li $v0, 4
	syscall
	la $a0, outFile
	li $a1, 100
	li $v0, 8
	syscall
	
	li $t8, 0
findNewLine2:
	lb $t9, outFile($t8)
	beq $t9, 10, rmNewLine2
	addi $t8, $t8, 1
	bne $t9, 0, findNewLine2
rmNewLine2:
	li $t9, 0
	sb $t9, outFile($t8)
	
	li $s4, 4
	div $t0, $s4
	mfhi $s4

	beq $t1, -1, pdwz
	beq $t1, 1, preproc
	j koniec
	
	blt $s4, 0, koniec
	bgt $s4, 4, koniec
	
pdwz:
	beqz $s4, preproc
	li $t1, 4
	sub $s4, $t1, $s4
	j preproc
	
preproc:
	li $a0, '\n'
	li $v0, 11
	syscall
	move $a0, $s4
	li $v0, 1
	syscall
	
readFile:
	##########################
	# s0 - rozmiar pliku     #
	# s1 - deskryptor pilku  #
	# s2 - dlugosc obrazka   #
	# s3 - wysokosc obrazka  #
	# s5 - offset		 #
	# s7 - docelowy bufor    #
	# t7 - padding		 #
	##########################
	
	#otwarcie pliku
	la $a0, inFile
	li $a1, 0
	li $a2, 0
	li $v0, 13
	syscall
	
	move $s1, $v0
	
	bltz $s1, fileErr
	
	move $a0, $s1
	la $a1, buff
	li $a2, 2
	li $v0, 14
	syscall
	#buff powinien być równy BM, czy trzeba sprawdzać?
	
	#wczytanie rozmiaru pliku
	move $a0, $s1
	la $a1, size
	li $a2, 4
	li $v0, 14
	syscall
	
	lw $s0, size
	
	beq $s4, 0, noRotation
	
	la $a0, msg2
	li $v0, 4
	syscall
	
	lw $a0, size
	li $v0, 1
	syscall
	
	li $a0, 'B'
	li $v0, 11
	syscall
	
	# odczytanie 4 bajtow zarezerwowanych:
	move $a0, $s1		# przywrocenie deskrptora pliku dla $a0
	la $a1, buff
	li $a2, 4
	li $v0, 14
	syscall
	
	# odczytanie miejsca w ktorym zaczynaja sie piksele (offset):
	move $a0, $s1
	la $a1, offset
	li $a2, 4
	li $v0, 14
	syscall
	
	lw $s5, offset
	
	# odczytanie 4 bajtow naglowka informacyjnego:
	move $a0, $s1
	la $a1, buff
	li $a2, 4
	li $v0, 14
	syscall
	
	# odczytanie szerokosci (width) obrazka 18,19,20,21b:
	move $a0, $s1
	la $a1, width
	li $a2, 4
	li $v0, 14
	syscall
	
	lw $s2, width			# zaladowanie width do $s2
	
	# odczytanie wysokosci (height) obrazka:
	move $a0, $s1
	la $a1, height
	li $a2, 4
	li $v0, 14
	syscall
	
	lw $s3, height			# zaladowanie height do $s3
	
	# zamkniecie pliku:
	move $a0, $s1
	li $v0, 16
	syscall
	
	li $a0, ' '
	li $v0, 11
	syscall
	
	lw $a0, width
	li $v0, 1
	syscall
	
	li $a0, 'x'
	li $v0, 11
	syscall
	
	lw $a0, height
	li $v0, 1
	syscall
	
	li $a0, '\n'
	li $v0, 11
	syscall
	
	#obliczenie paddingu
	li $t7, 4
	divu $s2, $t7
	mfhi $t7
	
	la $a0, msg3
	li $v0, 4
	syscall
	
	move $a0, $t7
	li $v0, 1
	syscall
	
prepareLoop:

	#################################
	# s0 - rozmiar pliku     	#
	# s1 - deskryptor pilku  	#
	# s2 - dlugosc obrazka   	#
	# s3 - wysokosc obrazka  	#
	# s5 - offset		 	#
	# s7 - docelowy bufor    	#
	# t1 - padding dest		#
	# t5 - liczba pikseli w obrazku	#
	# t6 - liczba B w wierszu	#
	# t7 - padding src	 	#
	#################################
	 
	mul $t5, $s2, $s3 #liczba pikseli w obrazku
	move $t2, $s2
	
	mul $t6, $s3, 3
	
	li $t1, 4
	divu $s3, $t1
	mfhi $t1
	
	add $t6, $t6, $t1
	
	li $a0, '\n'
	li $v0, 11
	syscall
	
	move $a0, $t5
	li $v0, 1
	syscall

writeHead:
	#lw $s7, begin2
	
	#zmiana s0 na rozmiar nowego pliku
	
	move $s0, $s5
	mul $t0, $s2, $t6 #liczba B z danymi obrazka
	
	addu $s0, $s0, $t0
	
	# alokacja pamieci o rozmiarze nowego pliku:
	move $a0, $s0
	li $v0, 9
	syscall
	
	move $s7, $v0		# przekazanie adresu zaalokowanej pamieci do $s7 (miejsce na docelowy obrazek)
	sw $s7, begin2
	
	#otwarcie pliku
	la $a0, inFile
	li $a1, 0
	li $a2, 0
	li $v0, 13
	syscall
	move $s1, $v0
	
	beq $s4, 2, cloneHead
	
	#czytam 2 bajty z pliku
	move $a0, $s1
	la $a1, buff2
	li $a2, 2
	li $v0, 14
	syscall
	
	lh $t0, buff2
	sh $t0, ($s7)
	addi $s7, $s7, 2
	
	move $t0, $s0
	sh $t0, ($s7)
	move $a0, $s1 #
	la $a1, buff2
	li $a2, 2
	li $v0, 14
	syscall       #
	addi $s7, $s7, 2
	
	srl $t0, $t0, 16 #przesuwam o pół słowa
	sh $t0, ($s7)
	move $a0, $s1 #
	la $a1, buff2
	li $a2, 2
	li $v0, 14
	syscall       #
	addi $s7, $s7, 2
	
	move $a0, $s1 #
	la $a1, buff2
	li $a2, 2
	li $v0, 14
	syscall       #
	lh $t0, buff2 #kopiuje zarezerwowane bajty
	sh $t0, ($s7)
	addi $s7, $s7, 2
	move $a0, $s1 #
	la $a1, buff2
	li $a2, 2
	li $v0, 14
	syscall       #
	lh $t0, buff2
	sh $t0, ($s7)
	addi $s7, $s7, 2
	
	move $a0, $s1 #
	la $a1, buff2
	li $a2, 2
	li $v0, 14
	syscall       #
	lh $t0, buff2 #kopiuje offset
	sh $t0, ($s7)
	addi $s7, $s7, 2
	move $a0, $s1 #
	la $a1, buff2
	li $a2, 2
	li $v0, 14
	syscall       #
	lh $t0, buff2
	sh $t0, ($s7)
	#addi $s1, $s1, 2
	addi $s7, $s7, 2
	
	move $a0, $s1 #
	la $a1, buff2
	li $a2, 2
	li $v0, 14
	syscall       #
	lh $t0, buff2 #kopiuje naglowek informacyjny
	sh $t0, ($s7)
	addi $s7, $s7, 2
	move $a0, $s1 #
	la $a1, buff2
	li $a2, 2
	li $v0, 14
	syscall       #
	lh $t0, buff2
	sh $t0, ($s7)
	addi $s7, $s7, 2
	
	#zapisuje nowa szerokosc
	move $t0, $s3
	sh $t0, ($s7)
	move $a0, $s1 #
	la $a1, buff2
	li $a2, 2
	li $v0, 14
	syscall       #
	addi $s7, $s7, 2
	
	srl $t0, $t0, 16 #przesuwam o pół słowa
	sh $t0, ($s7)
	move $a0, $s1 #
	la $a1, buff2
	li $a2, 2
	li $v0, 14
	syscall       #
	addi $s7, $s7, 2
	
	#zapisuje nowa wysokosc
	move $t0, $s2
	sh $t0, ($s7)
	move $a0, $s1 #
	la $a1, buff2
	li $a2, 2
	li $v0, 14
	syscall       #
	addi $s7, $s7, 2
	
	srl $t0, $t0, 16 #przesuwam o pół słowa
	sh $t0, ($s7)
	move $a0, $s1 #
	la $a1, buff2
	li $a2, 2
	li $v0, 14
	syscall       #
	addi $s7, $s7, 2


	li $a0, '\n'
	li $v0, 11
	syscall

	la $a0, msg4
	li $v0, 4
	syscall
	
	move $a0, $s0
	li $v0, 1
	syscall
	
	li $a0, 'B'
	li $v0, 11
	syscall


	lw $t2, begin2
	addu $t2, $t2, $s5 #dodaje offset
	
writeRestHead:
	beq $s7, $t2, preLoop
	move $a0, $s1 #
	la $a1, buff2
	li $a2, 1
	li $v0, 14
	syscall       #
	
	lb $t0, buff2
	sb $t0, ($s7)
	
	addi $s7, $s7, 1
	
	j writeRestHead
	
cloneHead:

	move $a0, $s1
	la $a1, ($s7)
	move $a2, $s5
	li $v0, 14
	syscall
	
preLoop:
	# t6 - dlugosc wiersza w B po obróceniu + padding
	
	#################################
	# s0 - rozmiar pliku     	#
	# s1 - deskryptor pilku  	#
	# s2 - dlugosc obrazka   	#
	# s3 - wysokosc obrazka  	#
	# s5 - offset		 	#
	# s6 - x - nr kolumny (src)	#
	# s7 - docelowy bufor    	#
	# t1 - padding dest		#
	# t3 - y - nr wiersza (src)	#
	# t4 - licznik pikseli		#
	# t5 - liczba pikseli w obrazku	#
	# t6 - liczba B w wierszu	#
	# t7 - padding src	 	#
	# t8 - docelowy x		#
	# t9 - docelowy y		#
	#################################
	
	li $t4, 0 #licznik pikseli
	lw $s7, begin2
	add $s7, $s7, $s5 #przesuwamy wskaznik o offset
	
	beq $s4, 1, prep90
	beq $s4, 2, prep180
	beq $s4, 3, prep270

prep90:
	li $s6, 1 #licznik pikseli w wierszu
	li $t3, 0
	li $t8, 0
	#move $t8, $s2
	#subi $t8, $t8, 1
	
	#li $t9, 0
	move $t9, $s2
	subi $t9, $t9, 1
	
	j loop
	
prep180:
	mul $t6, $s2, 3 #musze na nowo obliczyc t6
	add $t6, $t6, $t7
	
	li $s6, 1 #licznik pikseli w wierszu
	li $t3, 0
	#li $t8, 0
	move $t8, $s2
	subi $t8, $t8, 1
	
	#li $t9, 0
	move $t9, $s3
	subi $t9, $t9, 1
	
	j loop
	
prep270:
	li $s6, 1 #licznik pikseli w wierszu
	li $t3, 0
	#li $t8, 0
	move $t8, $s3
	subi $t8, $t8, 1
	
	li $t9, 0
	#move $t9, $s2
	#subi $t9, $t9, 1
	
	j loop
	
loop:
	beq $t4, $t5, loopend

	#czytam 3 bajty z pliku
	move $a0, $s1
	la $a1, buff2
	li $a2, 3
	li $v0, 14
	syscall
	
	lbu $t0, buff2 #laduje pierwszy bajt piksela 
	
	lw $s7, begin2
	add $s7, $s7, $s5 #przesuwamy wskaznik o offset
	
	mul $t1, $t6, $t9 #przeliczam nową pozycję piksela
	add $s7, $s7, $t1
	mul $t1, $t8, 3
	add $s7, $s7, $t1
	
	sb $t0, ($s7)
	addi $s7, $s7, 1
	
	j skipDebug

	li $a0, '\n'
	li $v0, 11
	syscall
	move $a0, $s6
	subi $a0, $a0, 1
	li $v0, 1
	syscall
	li $a0, ','
	li $v0, 11
	syscall
	move $a0, $t3
	li $v0, 1
	syscall
	li $a0, '|'
	li $v0, 11
	syscall
	move $a0, $t8
	li $v0, 1
	syscall
	li $a0, ','
	li $v0, 11
	syscall
	move $a0, $t9
	li $v0, 1
	syscall
	
skipDebug:
	
	lbu $t0, buff2+1
	
	sb $t0, ($s7)
	addi $s7, $s7, 1
	
	lbu $t0, buff2+2
	
	sb $t0, ($s7)
	addi $s7, $s7, 1
	
	addi $t4, $t4, 1
	
	beq $s6, $s2, pad
	
	#addi $t4, $t4, 1
	addi $s6, $s6, 1		# zwiekszenie liczby pikseli 
	
	#addi $t9, $t9, 1 #zwiekszenie docelowego y o 1
	
	beq $s4, 1, step90
	beq $s4, 2, step180
	beq $s4, 3, step270
	
step90:
	subi $t9, $t9, 1
	j loop
	
step180: 
	subi $t8, $t8, 1
	j loop
	
step270:
	addi $t9, $t9, 1
	j loop
	
pad:	
	move $a0, $s1 #przesuwam wskaznik na pliku o offset
	la $a1, buff2
	move $a2, $t7
	li $v0, 14
	syscall
	
	#addu $s7, $s7, $t7
	li $s6, 1
	addiu $t3, $t3, 1 #zwiekszam nr wiersza o 1
	
	beq $s4, 1, pad90
	beq $s4, 2, pad180
	beq $s4, 3, pad270

	#subi $t8, $t8, 1 #zmniejszam nr docelowej kolumny o 1 (x)
pad90:
	addi $t8, $t8, 1 #zwiekszam nr docelowej kolumny o 1 (x)
	
	#li $t9, 0 #resetuję docelowy wiersz (y)
	move $t9, $s2
	subi $t9, $t9, 1
	
	j loop
	
pad180:
	addi $t9, $t9, -1
	
	move $t8, $s2
	subi $t8, $t8, 1
	
	j loop
	
pad270:
	li $t9, 0
	subi $t8, $t8, 1
	
	j loop
	
loopend:

	#zamykam plik
	move $a0, $s1
	li $v0, 16
	syscall

saveFile:
	# zapisujemy wynik pracy w pliku "out.bmp"
	la $a0, outFile
	li $a1, 1
	li $a2, 0
	li $v0, 13
	syscall
	
	move $t0, $v0
	
	bltz $t0, fileErr
	lw $s1, begin2
	
	move $a0, $t0
	la $a1, ($s1)
	la $a2, ($s0)
	li $v0, 15
	syscall
	
	move $a0, $t0
	li $v0, 16
	syscall
	
	j koniec
	
noRotation:
	
	li $t2, 16 #rozmiar chunka
	
	div $s0, $t2
	
	mflo $t0
	mfhi $t1
	
	move $a0, $s1
	li $v0, 16
	syscall
	
	la $a0, inFile
	li $a1, 0
	li $a2, 0
	li $v0, 13
	syscall
	
	move $s1, $v0
	
	#otwarcie pliku wyjsciowego
	la $a0, outFile
	li $a1, 1
	li $a2, 0
	li $v0, 13
	syscall
	
	move $s2, $v0 #fd wyjscia
	
	bltz $s2, fileErr
	
copyChunks:
	beqz $t0, copyRest
	move $a0, $s1
	la $a1, buff
	move $a2, $t2
	li $v0, 14
	syscall
	
	move $a0, $s2
	la $a1, buff
	move $a2, $t2
	li $v0, 15
	syscall
	
	addiu $t0, $t0, -1
	
	j copyChunks
	
copyRest:
	beqz $t1, closeFiles
	move $a0, $s1
	la $a1, buff
	li $a2, 1
	li $v0, 14
	syscall
	
	move $a0, $s2
	la $a1, buff
	li $a2, 1
	li $v0, 15
	syscall
	
	addiu $t1, $t1, -1
	
	j copyRest

closeFiles:
	move $a0, $s1
	li $v0, 16
	syscall
	
	move $a0, $s2
	li $v0, 16
	syscall
	
	j koniec
	
fileErr:
	la $a0, fileError
	li $v0, 4
	syscall
	li $a0, '\n'
	li $v0, 11
	syscall
	la $a0, inFile
	li $v0, 4
	syscall
	li $a0, '\n'
	li $v0, 11
	syscall

koniec:
	
	li $v0, 10
	syscall
