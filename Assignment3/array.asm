# This program manipulates an array by inserting and deleting at specified index and sorting the contents of the array.
# The program should also be able to print the current content of the array.
# The program should not terminate unless the 'quit' subroutine is called
# You can add more subroutines and variables as you wish.
# Remember to use the stack when calling subroutines.
# You can change the values and length of the beginarray as you wish for testing.
# You will submit 5 .asm files for this quesion, Q1a.asm, Q1b.asm, Q1c.asm, Q1d.asm and Q1e.asm.
# Each file will be implementing the functionalities specified in the assignment.
# Use this file to build the helper functions that you will need for the rest of the question.

#Author: Marco Caniglia
#Student ID: 260 929 489

.data

beginarray: .word 5, 3, -9, 1, 2, -999			#’beginarray' with some contents	 DO NOT CHANGE THE NAME "beginarray"
array: .space 4000					#allocated space for ‘array'
str_command:	.asciiz "\nEnter a command (i, d, s or q):" # command to execute

#all my strings
newLine: .asciiz "\n"
invalidCommand: .asciiz "Please enter a valid command"
str_index: .asciiz "\nEnter an index: "
invalidIndex: .asciiz "Invalid index."
str_value: .asciiz "Enter a value: "
str_array: .asciiz "\nThe current array is: "
test: .asciiz "\nTEST\n"

i: .asciiz "i"
d: .asciiz "d"
s: .asciiz "s"
q: .asciiz "q"

	.text
	.globl main

main:
	la $a0,beginarray		# $a0 = address to beginarray 
	jal length			#compute length of array
	addi $s0,$v0,0			# $s0 CONTAINS LENGTH -> Don't overwrite

	la $a0,beginarray		# $a0 = address to beginarray
	la $a1,array			# $a1 = address to initially empty array
	jal copyarray			#copy beginarray into array
	
	j prompt	
	
EXIT:
	li $v0,10
	syscall

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
		
copyarray:
	lw $t0,0($a0)			# $t0 = word at index $a0 in beginarray
	beq $t0,-999,done2		#if(array[i]== -999) {we reached the end of the array}
	sw $t0,0($a1)			#copy the word from beginarray to array
	addi $a0,$a0,4
	addi $a1,$a1,4
	
	j copyarray

done2:
	sw $t0,0($a1)
	jr $ra

printarray:
	lw $t1,0($t0)
	beq $t1,-999,done3
	
	li $a0, ' '
	li $v0, 11    		#print_character
	syscall
	
	#print the element array[i]
	li $v0,1
	addi $a0,$t1,0
	syscall
	
	addi $t0,$t0,4
	j printarray

done3:
	jr $ra
	
prompt:
	li $v0,4			#prompt the user to enter a command
	la $a0, str_command
	syscall
	
	li $v0,12			#read the STRING command
	syscall
	
	addi $a0,$v0,0			#add the string command to $a0
	
	la $t0,i
	lb $t0,0($t0)
	beq $a0,$t0,insert		#if the command is i, j to insert
	la $t1,d
	lb $t1,0($t1)
	beq $a0,$t1,delete		#if the command is d, j to delete
	la $t2,s
	lb $t2,0($t2)
	beq $a0,$t2,sort		#if the command is s, j to sort
	la $t3,q
	lb $t3,0($t3)
	beq $a0,$t3,quit		#if the command is s, j to quit
	
	#if the command is neither of those, then display error message & reprompt
	li $v0,4			#display error message
	la $a0, invalidCommand
	syscall
	
	j prompt
	
insert: #insert
	addi $sp,$sp,-4		
	sw $ra,0($sp)			#save the return address to main onto the stack
	la $a0, array
	jal length			#calculate the length of the array after insertion
	addi $s0,$v0,0
	lw $ra,0($sp)
	addi $sp,$sp,4		

	li $v0,4			#prompt the user to enter an index
	la $a0, str_index
	syscall
	
	li $v0,5			#read the index
	syscall
	add $t6,$v0,$0			#add the index to $t6
	
	#addi $t0,$s0,1			#legnth - 1
	bgt $t6,$t0,insertError		#if(index > array.length-1) error
	blt $t6,$0,insertError		#if(index < 0) error
	
	li $v0,4			#prompt the user to enter a value
	la $a0, str_value
	syscall
	
	li $v0,5			#read the value inputed
	syscall
	add $t4,$v0,$0			# $t4 = value the user wants to input
		
	mul $t5,$t6,4			# $t5 = index where user wants to insert * 4 = spot in the array
	la $a1,array			# $a1 = address to array
	addu $a2,$a1,$t5		# $a2 = address to index user wants to insert a value
	addi $a2,$a2,-4
	
	mul $t0,$s0,4
	addu $a3,$a1,$t0		# $a3 = address to the last element (-999) of the array

shift:
lw $t0,0($a3)			# $t0 = element at index i (initially i = address of array + length)
addi $a0,$a3,4			#increment address by 4 to get element i+1
sw $t0,0($a0)			#store the word at the next space in memory
addi $a3,$a3,-4			#decrement counter to go push the previous element up 1 spot in the array
bne $a3,$a2,shift
	
	#after all the elements are shifted we will have a duplicate, overwrite the 
	# element at index i with the value the user inputed which is stored in $t4
	addu $a1,$a1,$t5
	sw $t4,0($a1)
	
	li $v0,4			#print array string message
	la $a0, str_array
	syscall
	
	addi $sp,$sp,-4		
	sw $ra,0($sp)			#save the return address to main onto the stack
	la $t0, array
	jal printarray			#print the array after the insertion
	lw $ra,0($sp)
	addi $sp,$sp,4	
	
	j prompt
	
insertError:
	li $v0,4			#display error message if index doesnt work
	la $a0, invalidIndex
	syscall
	
	j insert

delete: #delete
	addi $sp,$sp,-4		
	sw $ra,0($sp)			#save the return address to main onto the stack
	la $a0, array
	jal length			#calculate the length of the array after insertion -> if we want to keep inserting
	addi $s0,$v0,0
	lw $ra,0($sp)
	addi $sp,$sp,4	
	
	li $v0,4			#prompt the user to enter an index
	la $a0, str_index
	syscall
	
	li $v0,5			#read the index
	syscall
	add $t6,$v0,$0			#add the index to $t6
	
	addi $t0,$s0,-1			# $t0 = legnth - 1
	bgt $t6,$t0,deleteError		#if(index > array.length-1) error
	blt $t6,$0,deleteError		#if(index < 0) error
	
	#to delete the element, we need to shift every element in the array that are
	#to the right of the deleted element to the left by 1 space
	la $a0,array
	mul $t0,$t6,4			#multiply the index inputed by 4
	addu $a1,$a0,$t0		# add this ^ to the address pointing to array to get the address of the element we want to delete
	
delShift: 
addi $a1,$a1,4
lw $t0,0($a1)	
addi $a1,$a1,-4
sw $t0,0($a1)
addi $a1,$a1,4
lw $t1,0($a1)	
bne $t1,-999,delShift
	
	li $v0,4			#print array string message
	la $a0, str_array
	syscall
	
	addi $sp,$sp,-4		
	sw $ra,0($sp)			#save the return address to main onto the stack
	la $t0, array			
	jal printarray			#print the array after the insertion
	lw $ra,0($sp)
	addi $sp,$sp,4
		
	j prompt
	
deleteError:
	li $v0,4			#display error message if index doesnt work
	la $a0, invalidIndex
	syscall
	
	j delete
	
sort: 	#bubble sort -> I used bubble sort pseudo code from COMP 250 to implement this
	la $a0, array
	addi $sp,$sp,-4		
	sw $ra,0($sp)			#save the return address to main onto the stack
	jal length			#calculate the length of the array after insertion -> if we want to keep inserting
	addi $s0,$v0,0
	lw $ra,0($sp)
	addi $sp,$sp,4
	
	la $a0, array	
	mul $t1,$s0,4			# $t1 = (lengthArray * 4) 
	add $t1,$a0,$t1		 	# $t1 = address of last element in array
	addi $t1,$t1,-4
	
while:	#while(sorted==false)&&($a0!=$t1))
	addi $t6,$0,1			#boolean SORTED=false: Sorted=0 (FALSE)/Sorted=1 (TRUE)
					#initially, set Sorted to 1, at each iteration if something is swapped 
					#set it to 0
	la $a0, array
for:	#iterates over the array to check if a swap is needed
	lw $t2,0($a0)			#element 1
	lw $t3,4($a0)			#element 2
	
	ble $t2,$t3,next		#if(element1<element2) do nothing (go to next element)
	#if $t2>$t3 we need to swap
	sw $t3,0($a0)			
	sw $t2, 4($a0)
	addi $t6,$0,0			#since we had to swap, the array is NOT sorted=> Sorted=0
next:
	addi $a0,$a0,4			#increment address by 4 to move to the next element
	#check if we reached end of array
	bne $a0,$t1,for			#if we are NOT at the end of the array keep going through the inner for loop
	#check if the boolean Sorted was set to 0. 
	#if it was never set to 0 that means the array is sorted!
	bne $t6,1,while			#if $t6=0, array is not sorted -> keep sorting
	
end: 
	li $v0,4			#print array string message
	la $a0, str_array
	syscall
	
	addi $sp,$sp,-4		
	sw $ra,0($sp)
	la $t0, array
	jal printarray			#print the sorted array
	lw $ra,0($sp)
	addi $sp,$sp,4
	
	j prompt
	
quit:	#quit
	j EXIT
