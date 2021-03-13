# Written by: Marco Caniglia
# Student ID: 260 929 489

.data
#Example files
str1:		.asciiz "test1.txt"
str2:		.asciiz "test2.txt"
outputFile:	.asciiz "test1.pbm"
outputFile2:	.asciiz "test2.pbm"

str_openError:	.asciiz "Error: The file could not be opened"
str_readError:	.asciiz "Error: The file could not be read"
str_writeError:	.asciiz "Error: The file could not writen into"
output: 	.asciiz "P1\n50 50\n"


buffer:  	.space 4096		# buffer for upto 4096 bytes (increase size if necessary)

	.text
	.globl main

main:	la $a0,str1		#readfile takes $a0 as input
	jal readfile

	la $a0, outputFile	#writefile takes $a0 as file location
	la $a1,buffer		#$a1 takes location of what we wish to write.
	jal writefile

exit:
	li $v0,10
	syscall

readfile:
	li $v0, 13 		# Syscall to open a file
	#$a0 already contains address to str1
	li $a1, 0		# read flag
	li $a2, 0		# ignore mode
	syscall
	
	addi $t1,$v0,0		# $t1 = file descriptor
	blt $v0,$0,openError	# checking for error: if $v0 < 0 = ERROR	
	
	li $v0, 14		# read the file into buffer
	addi $a0,$t1,0		# $a0 = file descriptor
	la $a1, buffer		# load adress of the buffer
	li $a2, 4096		# max number of words (buffer size)
	syscall
	
	blt $v0,$0,readError	# checking for error: if $v0 < 0 = ERROR

	li $v0, 4		# print a string 
	la $a0, buffer 		# print the buffer
	syscall
	
	# close the file
	li $v0, 16		# syscall to close the file
	addi $a0,$t1,0
	syscall
	
	jr $ra	

writefile:
	li $v0, 13 		# syscall to open a file
	#$a0 already contains address to str3
	li $a1, 1		# write flag
	li $a2, 0		# Ignore mode
	syscall
	
	addi $t1,$v0,0		# $t1 = file descriptor
	blt $v0,$0,openError	# checking for error: if $v0 < 0 = ERROR
		
	# write following contents into the file: 
	#P1 
	#50 50
	li   $v0, 15		# syscall for write to file
 	addi $a0,$t1,0		# $a0 = file descriptor 
  	la   $a1, output	# want to write string "output" to file
  	li   $a2, 9		# length of the string "output"
  	syscall			# write to file
  	
  	blt $v0,$0,writeError	# checking for error: if $v0 < 0 = ERROR
	
	# write out contents read into buffer
	li   $v0, 15		# syscall for write to file
 	addi $a0,$t1,0		# $a0 = file descriptor 
  	la   $a1, buffer	# write the contents of buffer
  	li   $a2, 4096		# length of the buffer
  	syscall			# write to file
  	
  	blt $v0,$0,writeError	# checking for error: if $v0 < 0 = ERROR

	# close the file
	li $v0, 16		# syscall for close file
	addi $a0,$t1,0
	syscall

	jr $ra

openError:	
	li $v0, 4		# Print open error message
	la $a0, str_openError
	syscall	
	j exit	
	
readError:	
	li $v0, 4		# Print write error message 
	la $a0, str_readError
	syscall	
	j exit			
	
writeError:	
	li $v0, 4		# Print write error message 
	la $a0, str_writeError
	syscall	
	j exit		
	
