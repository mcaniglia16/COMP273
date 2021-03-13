# Written by: Marco Caniglia
# Student ID: 260 929 489

.data

#example files:
str1:		.asciiz "test2.txt"
str3:		.asciiz "testfill.pbm"	#used as output
str_error:	.asciiz "Error: invalid file"
str_length: 	.asciiz "\nThe length of the 2D array is: "
output: 	.asciiz "P1\n50 50\n"
newLine: .asciiz "\n"

buffer:  	.space 10000		# buffers for upto 10'000 bytes
bufferInt:	.word 10000		# 2D array that is filled in fillregion
newbuff: 	.space 2501		# (increase sizes if necessary)

	.text
	.globl main

main:	la $a0,str1		#readfile takes $a0 as input
	jal readfile
	
	##################################### TESTING
	#la $a0,bufferInt
	#jal length
	#addi $s0,$v0,0			# $s0 CONTAINS LENGTH of buffer (should be 50x50=2500)
	#li $v0,4
	#la $a0, str_length
	#syscall
	### TEST print out length of beginarray
	#li $v0, 1
	#la $a0,($s0)
	#syscall	
	### TEST printarray
	#la $t0,bufferInt
	#jal printarray
	#####################################
	
	la $s1,bufferInt	#$s1 will specify the "2D array" we will be filling
	#hardcode a seed point inside of the contour of the "2" in test1.pgm
	addi $a1,$0,20		# i = row = 15
	mul  $a1,$a1,50		# i*50 to get the correct row in the 2D array
	addi $a2,$0,14		# j = col = 18
	add  $a1,$a1,$a2	#$a1=(15*50)+18 initially [hard coded]
	mul  $a1,$a1,4
	jal fillregion
	
	###################################
	#PRINTING THE FILLED ARRAY
	li $v0,4			#print array string message
	la $a0, newLine
	syscall
	li $v0,4			#print array string message
	la $a0, newLine
	#
	la $t0,bufferInt
	addi $t5,$0,0
	jal printarray
	#######################################
	
	#Subroutine to copy the ASCII value corresponding to each entry in the 2D array into newbuff
	la $a0,bufferInt
	la $a1,newbuff
	addi $a2,$0,0		#counter
	jal intToASCII
	
	################ Test to see last element of 2D array bufferInt
	#la $a0,bufferInt
	#addi $a0,$a0,2500
	#lw $t0,($a0)
	#li $v0, 1
	#addi $a0,$t0,0
	#syscall
	###############
	
	#writing newbuff to file testfill.pbm
	la $a0, str3		# writefile will take $a0 as file location
	la $a1,newbuff		# $a1 takes location of what we wish to write.
	jal writefile
exit:
	li $v0,10		# exit
	syscall

readfile:
	li $v0, 13 		# Syscall to open a file
	#$a0 already contains address to str1
	li $a1, 0		# read flag
	li $a2, 0		# ignore mode
	syscall
	
	addi $t1,$v0,0		# $t1 = file descriptor
	blt $v0,$0,error	# checking for error: if $v0 < 0 = ERROR	
	
	li $v0, 14		# read the file into buffer
	addi $a0,$t1,0		# $a0 = file descriptor
	la $a1, buffer		# load adress of the buffer
	li $a2, 10000		# max number of words (buffer size)
	syscall
	
	blt $v0,$0,error	# checking for error: if $v0 < 0 = ERROR

	li $v0, 4		# print a string 
	la $a0, buffer 		# print the buffer
	syscall

	#Convert the entries in the buffer from ASCII to decimal values
	la $a1,buffer		# load adress of the buffer which contains the 2D array of ASCIIs
	la $a2,bufferInt	# load adress of newbuff which will contain the 2D array of ints
	addi $t3,$a1,2550	# the 50 extra bits are for the newline chars
ASCIItoInt:
	beq $a1,$t3,done
	
	lb $t0,0($a1)		#get the char from buffer
	li $t1,'\n'		#load newline char in $t1
	beq $t0,$t1,ignore	#we want to ignore all the newline characters in buffer
	li $t1,'\r'		
	beq $t0,$t1,ignore	#we want to ignore all \n AND \r
	beq $t0,0,done
	
	andi $t0,$t0,0x0F	# turn the ASCII to int
	sw $t0,0($a2)
next:
	addi $a1,$a1,1		#move to next char in buffer
	addi $a2,$a2,4		#move to next word in newbuff
	j ASCIItoInt
ignore:
	addi $a1,$a1,1		#move to next char in buffer
	j ASCIItoInt
done:
	# add -999 at the end of the 2D array to know when we have reached the end
	addi $t6,$0,-999
	sw $t6,0($a2)

	# close the file
	li $v0, 16		# syscall to close the file
	addi $a0,$t1,0
	syscall
	
	jr $ra

#===========================================================================================================
fillregion:
	addi $sp,$sp,-4
	sw $ra,0($sp)		#save the $ra on the stack
	la $s0,($sp)
	
	addi $t5,$a1,0		#index of seed point in 2D array
	addi $t6,$0,0		#counter
	
	#BASE CASE
	add $t0,$s1,$t5		#get the address of pixel $t5 in 2D array
	lw $t1,0($t0)
	beq $t1,1,endOfRecursion
	
Loop:	
	# $s1 has a pointer to bufferInt array
	add $t0,$s1,$t5		#get the address of pixel $t5 in 2D array
	lw $t1,0($t0)
	beq $t1,0,white		#if $t5 pixel is white jump to white
	beq $t1,1,black		#else (if $t5 pixel is black) 	

white:	
	addi $t1,$0,1		#to paint the pixel $t5 black
	sw $t1,0($t0)		#store the 1 in the array at index t5 to PAINT the pixel
	
black:	
	#move to neighbor
	beq $t6,0,neighbor1
	beq $t6,1,neighbor2
	beq $t6,2,neighbor3
	beq $t6,3,neighbor4
	beq $t6,4,neighbor5
	beq $t6,5,neighbor6
	beq $t6,6,neighbor7
	beq $t6,7,neighbor8
	
	neighbor1: #i+1
		addi $t7,$t5,4	
		j L
	neighbor2: #i+50+1
		addi $t7,$t5,204
		j L
	neighbor3: #i+50
		addi $t7,$t5,200
		j L
	neighbor4: #i+50-1
		addi $t7,$t5,196
		j L
	neighbor5: #i-1
		addi $t7,$t5,-4
		j L
	neighbor6: #i-50-1
		addi $t7,$t5,-204
		j L
	neighbor7: #i-50
		addi $t7,$t5,-200
		j L
	neighbor8: #i-50+1
		addi $t7,$t5,-196
		
L: 	#check if neighbor is white
	add $t0,$s1,$t7			#get the address of pixel $t7 in 2D array
	lw $t1,0($t0)			#get the pixel at $t7 (neighbor of $t5)
	beq $t1,0,whiteNeighbor		#if $t7 pixel is white jump to whiteNeighbor
	beq $t1,1,blackNeighbor		#if $t7 pixel is white jump to whiteNeighbor
whiteNeighbor:
	addi $sp,$sp,-4
	sw $t5,($sp)			#store index in stack
	addi $sp,$sp,-4
	sw $t6,($sp)			#store its counter in stack
	
	addi $t5,$t7,0
	addi $t6,$0,0
	j Loop
	
blackNeighbor:
	addi $t6,$t6,1			#increment the counter by 1 (determines which neighbor will be visited next)
	bgt $t6,7,stepBack		#if counter $t6 > 7, we have visited every neighbor, go back to the previous pixel
	j Loop
stepBack:	
	beq $s0,$sp,endOfRecursion	#if the stack is empty, end the recursion ($s0 -> la $s0,($sp) at the beginning of fillregion)
	lw $t6,($sp)			#get the counter $t6 of the previous pixel from the stack
	addi $sp,$sp,4
	lw $t5,($sp)			#get the index $t5 of the previous pixel from the stack
	addi $sp,$sp,4
	j Loop

endOfRecursion:
	lw  $ra,0($sp)		#get the ra from the stack
	addi $sp,$sp,4
	jr $ra			#end subroutine
#===========================================================================================================
#Copy the ASCII values corresponding to each entry in 2D array into newbuff
# $a0 = pointer to 2D array of ints
# $a1 = pointer to newbuff
# 0 -> ASCII 48
# 1 -> ASCII 49
intToASCII:
	lw  $t0,0($a0)
	beq $a2,2535,donezo
	beq $t0,0,ASCII0
	beq $t0,1,ASCII1
ASCII0:
	addi $t0,$0,48
	sb $t0,0($a1)
	j nextInt
ASCII1:
	addi $t0,$0,49
	sb $t0,0($a1)
nextInt:
	addi $a2,$a2,1
	addi $a0,$a0,4
	addi $a1,$a1,1
	j intToASCII
donezo:
	jr $ra

#===========================================================================================================
# $a0 = pointer to str3 "testfill.pbm"
# $a1 = pointer to newbuff
writefile:
	li $v0, 13 		# syscall to open a file
	#$a0 already contains address to str3
	li $a1, 1		# write flag
	li $a2, 0		# Ignore mode
	syscall
	
	addi $t1,$v0,0		# $t1 = file descriptor
	blt $v0,$0,error	# checking for error: if $v0 < 0 = ERROR
	
	# write following contents into the file: 
	#P1 
	#50 50
	li   $v0, 15		# syscall for write to file
 	addi $a0,$t1,0		# $a0 = file descriptor 
  	la   $a1, output	# want to write string "output" to file
  	li   $a2, 9		# length of the string "output"
  	syscall			# write to file
  	
  	blt $v0,$0,error	# checking for error: if $v0 < 0 = ERROR
	
	# write out contents read into buffer
	li   $v0, 15		# syscall for write to file
 	addi $a0,$t1,0		# $a0 = file descriptor 
  	la   $a1, newbuff	# write the contents of buffer
  	li   $a2, 2501		# length of the buffer
  	syscall			# write to file
  	
  	blt $v0,$0,error	# checking for error: if $v0 < 0 = ERROR

	# close the file
	li $v0, 16		# syscall for close file
	addi $a0,$t1,0
	syscall

	jr $ra

error:
	li $v0, 4		# Print open error message
	la $a0, str_error
	syscall	
	j exit	
	
	
#===========================================================================================================
# Helpers to print the filled 2D array
length:
	addi $t0,$zero,0		#legnth = $t0 = 0 
loop:
	lw $t1,0($a0)			#load word at index where pointer currently is in array
	beq $t1,-999,done1		#if(array[i]== -999) {we reached the end of the array}
	addi $t0,$t0,1			#length++ == $t0 ++
	addi $a0,$a0,4			#increment pointer by 4 to get to next element of array
	j loop
done1:
	addi $v0,$t0,0
	jr $ra
printarray:
	beq $t5,50,newLines
	
	lw $t1,0($t0)
	beq $t1,-999,done3
	
	#print the element array[i]
	li $v0,1
	addi $a0,$t1,0
	syscall
	
	addi $t5,$t5,1
	addi $t0,$t0,4
	j printarray
newLines:
	addi $t5,$0,0
	
	li $v0,4			#print array string message
	la $a0, newLine
	syscall
	
	j printarray
done3:
	jr $ra
	
