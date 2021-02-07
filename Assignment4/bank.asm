####################### Bank Application ##############################
# 	Written by: Marco Caniglia					#
# 	Student ID: 260 929 489						#

# This program represents a simple banking application			#
# The program should allow to make the following operations
# 	a) opening an account 						#
# 	b) finding out the balance, 
# 	c) making a deposit						#
# 	d) making a withdrawal, 
# 	e) transferring between accounts 				#
# 	f) taking a loan 
# 	g) closing an account 						#
# 	h) displaying query history.						
# The program should terminate when QUIT is entered by the user.	#
#######################################################################

.data
	bank_array: .word 0, 0, 0, 0, 0	, -999 #this array holds banking details
	#[Checking no, Savings no, Checking balance, Savings balance, Loan]
	bank_history: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -999
	buffer: .space 100
	
	################### all messages #########################
	test: .asciiz "test\n"
	error_message:	.asciiz "ERROR: invalid banking transaction, please enter a valid one.\n" 
	welcome_message: .asciiz "Welcome to Bank 273!\nPlease enter a command in the MMIO Simulator!\n"
	account_exists_message: .asciiz "Error: an account already exists, please enter a valid bank transaction\n"
	insufficientFunds_message: .asciiz "Error: your account has insufficient funds, cannot withdraw this amount\n"
	loanError_message: .asciiz "Error: your account has insuffient funds to take out such a loan\n"
	payLoan_message: .asciiz "You have payed back your loan\n"
	transferError_message: .asciiz "There was an error in your transfer, please try again\n"
	newLine: .asciiz "\n"
	closeError_message: .asciiz "There was an error with closing this account, please try again\n"
	historyError_message: .asciiz "Invalid history request, you can only request to see between 1 and 5 of your last queries\n"
	length_message: .asciiz "This command has length: \n"
	open_message: .asciiz"You successfully opened an account\n"
	deposit_message: .asciiz"You sucessfully deposited money in your account\n"
	withdraw_message: .asciiz"You have successfully withdrawn money from your account\n"
	loan_message: .asciiz"You have succesfully taken out a loan\n"
	transfer_message: .asciiz"You have succesfully transfered money\n"
	close_message: .asciiz"You successfully closed your account\n"
	balance_message: .asciiz"Your account balance is: \n"
	history_message: .asciiz"Here is the history of your last queries: \n"
	quit_message: .asciiz"You have successfully exited the bank app. Goodbye!\n"
	C: .asciiz "C" 
	H: .asciiz "H"
	S: .asciiz "S" 
	V: .asciiz "V"
	D: .asciiz "D"
	E: .asciiz "E"
	W: .asciiz "W"
	L: .asciiz "L"
	T: .asciiz "T"
	B: .asciiz "B"
	Q: .asciiz "Q"
	N: .asciiz "N"
	R: .asciiz "R"
	space: .ascii " " 

.text
	.globl main

main:
########################## Input Validation ###########################################
	la $a0, welcome_message
	li $v0,4			#print welcome message to standard IO
	syscall
	
Start:
	la $a3,buffer
Loop:
	jal read			#reading from MMIO
	add $a0,$v0,$0			#in an infinite loop
	beq $a0,32,ignore		#we want to ignore spaces
	beq $a0,8,ignore		#we want to ignore back spaces
	beq $a0,10,which_command	#when we reach a carriage return, we start validating the input passed by user
	jal write
	
	### print the contents of $a0 to std IO
	#li $v0,11
	#$a0
	#syscall
	###
	
	sw $a0,0($a3)
	addi $a3,$a3,4
ignore:
	j Loop
		
read:	#read the command from MMIO simulator
	lui $t0, 0xffff			# $t0 = 0xffff0000 (MMIO Starting address)
loop1:	
	lw $t1,0($t0)			# $t1 = value(0xfff0000) which is the command passed by the user
	andi $t1,$t1,0x0001		# is device ready
	beq $t1,$0,loop1		# 0 = no = check again
	lw $v0, 4($t0)			# yes: read data from 0xffff0004
	jr $ra

	########################### WRITE TO MMIO #####################################
	write: # write to display
		lui $t0, 0xffff 	# $t0 = 0xffff0000
	Loop2: 	lw $t1, 8($t0) 		# $t1 = value(0xffff0008)
		andi $t1,$t1,0x0001	# Is Device ready?
		beq $t1,$zero,Loop2	# No: check again
		sw $a0, 12($t0) 	# Yes write to device register @ (0xffff000c) 	
		jr $ra
	##############################################################################
		
which_command:
	#add a flag to the end of the string
	addi $t0,$0,-999
	sw $t0,0($a3)
	
	#find which command the user inputed
	la $a3,buffer
	lw $a1,0($a3)			#$a1 = first letter of buffer (user input)
	lw $a2,4($a3)			#$a2 = second letter of buffer (user input)
	
	la $t0,C
	lb $t0,0($t0)
	beq $t0,$a1,C_next
	
	la $t0,S
	lb $t0,0($t0)
	beq $t0,$a1,S_next
	
	la $t0,D
	lb $t0,0($t0)
	beq $t0,$a1,D_next
	
	la $t0,W
	lb $t0,0($t0)
	beq $t0,$a1,W_next
	
	la $t0,L
	lb $t0,0($t0)
	beq $t0,$a1,L_next
	
	la $t0,T
	lb $t0,0($t0)
	beq $t0,$a1,T_next
	
	la $t0,B
	lb $t0,0($t0)
	beq $t0,$a1,B_next
	
	la $t0,Q
	lb $t0,0($t0)
	beq $t0,$a1,Q_next

C_next: #CH or CL
	la $t0,H
	lb $t0,0($t0)
	beq $t0,$a2,open_account
	
	la $t0,L
	lb $t0,0($t0)
	beq $t0,$a2,close_account
	j error
S_next: #SV
	la $t0,V
	lb $t0,0($t0)
	beq $t0,$a2,open_account
	j error
D_next: #DE
	la $t0,E
	lb $t0,0($t0)
	beq $t0,$a2,deposit
	j error
W_next: #WT
	la $t0,T
	lb $t0,0($t0)
	beq $t0,$a2,withdraw
	j error
L_next:	#LN
	la $t0,N
	lb $t0,0($t0)
	beq $t0,$a2,get_loan
	j error
T_next:	#TR
	la $t0,R
	lb $t0,0($t0)
	beq $t0,$a2,transfer
	j error
B_next: #BL
	la $t0,L
	lb $t0,0($t0)
	beq $t0,$a2,get_balance
	j error
Q_next: #QH or QT
	la $t0,H
	lb $t0,0($t0)
	beq $t0,$a2,history
	
	la $t0,T
	lb $t0,0($t0)
	beq $t0,$a2,quit
error:
	li $v0,4				#print our error message
	la $a0, error_message
	syscall
	#clear the buffer
	#jump back to main loop
	j Start
##############################################################################
	
Exit: 	# main code ends here
	li $v0,10
	syscall
	
########################## Helpers ###########################################
length:
	# $a3 contains the address of the buffer
	addi $t0,$zero,0			#legnth = $t0 = 0 
	len_loop:
		lw $t1,0($a3)			#load word at index where pointer currently is in buffer
		beq $t1,-999,done1		#if(buffer[i]== -999) {we reached the end of the array}
		addi $t0,$t0,1			#length++ == $t0 ++
		addi $a3,$a3,4			#increment pointer by 4 to get to next element of buffer
		j len_loop		
done1:
	addi $v0,$t0,0
	jr $ra

ascii_to_int:
	#takes an ascii value in $t1, converts to int
	andi $t1,$t1,0x0F
	addi $v0,$t1,0
	jr $ra
	
getAccountNumber:
	# $a3 = address to buffer
	lw $t1,8($a3)
	andi $t1,$t1,0x0F		#ASCII to int
	mul $t1,$t1,10000
	addi $t0,$t1,0
	lw $t1,12($a3)
	andi $t1,$t1,0x0F
	mul $t1,$t1,1000
	add $t0,$t0,$t1
	lw $t1,16($a3)
	andi $t1,$t1,0x0F
	mul $t1,$t1,100
	add $t0,$t0,$t1
	lw $t1,20($a3)
	andi $t1,$t1,0x0F
	mul $t1,$t1,10
	add $t0,$t0,$t1
	lw $t1,24($a3)
	andi $t1,$t1,0x0F
	mul $t1,$t1,1
	add $t0,$t0,$t1
	
	addi $v0,$t0,0
	jr $ra
	
getSecondAccountNumber:
	# $a3 = address to buffer
	lw $t1,28($a3)
	andi $t1,$t1,0x0F		#ASCII to int
	mul $t1,$t1,10000
	addi $t0,$t1,0
	lw $t1,32($a3)
	andi $t1,$t1,0x0F
	mul $t1,$t1,1000
	add $t0,$t0,$t1
	lw $t1,36($a3)
	andi $t1,$t1,0x0F
	mul $t1,$t1,100
	add $t0,$t0,$t1
	lw $t1,40($a3)
	andi $t1,$t1,0x0F
	mul $t1,$t1,10
	add $t0,$t0,$t1
	lw $t1,44($a3)
	andi $t1,$t1,0x0F
	mul $t1,$t1,1
	add $t0,$t0,$t1
	
	addi $v0,$t0,0
	jr $ra
	
printBankInfo:
	la $a1,bank_array

	li $a0, '['
	li $v0, 11    			#print_character
	syscall
	printLoop:
		lw $t1,0($a1)
		beq $t1,-999,donezo
		
		li $v0,1
		addi $a0,$t1,0		#print the element bank_array[i]
		syscall
		lw $t1,4($a1)
		beq $t1,-999,donezo
		li $a0, ','
		li $v0, 11    		#print_character
		syscall
		li $a0, ' '
		li $v0, 11    		#print_character
		syscall
		
		addi $a1,$a1,4
		j printLoop
	donezo:
	li $a0, ']'
	li $v0, 11    			#print_character
	syscall
	li $a0,'\n'
	syscall
	
	j Start
	
########################## BANK OPERATIONS ###########################################
open_account:
# 2 types of account: CH (checking) or SV (savings)
# Command format
# 1) CH Account_Number Opening_Balance
# 2) SV Account_Number Opening_Balance

	# if $a1 == C -> Checking
	# if $a2 = S -> Savings
	
	la $a3,buffer				#calculate the length of the buffer
	jal length				#buffer needs a minimum of 2 (command) + 5 (account number) + 1(balance) = 8 elements
	blt $v0,8,error				#if the buffer has less than 8 elements, than it is an INVALID banking transaction
	
	#GET ACCOUNT NUMBER (put in $t0)
	la $a3,buffer
	jal getAccountNumber
	addi $t0,$v0,0				# Account number is now in $t0
	
	#GET OPENING BALANCE (put in $t1)
	addi $a3,$a3,28
	addi $t1,$0,0				#balance
	balanceLoop:
		lw $t2,0($a3)
		beq $t2,-999,balance
		andi $t2,$t2,0x0F		# $t2 ascii -> int
		add $t1,$t1,$t2
		mul $t1,$t1,10
		addi $a3,$a3,4
		j balanceLoop
	balance:
		div $t1,$t1,10
	
	la $t3,S
	lb $t3,0($t3)
	beq $t3,$a1,Savings			# if $a1 = S jump to savings
	
	#else, open a checking account IF no such account already exists.
	# $t0 = account number
	# $t1 = balance
	la $a1,bank_array
	lw $a2,0($a1)
	bne $a2,0,existsError
	
	#if no account exists, create the account and deposit the money
	sw $t0,0($a1)				#store checking account number
	sw $t1,8($a1)				#store checking balance
		
	la $a0, open_message			#print open account message
	li $v0, 4
	syscall
	j printBankInfo
	
	Savings:
		la $a1,bank_array
		lw $a2,4($a1)
		bne $a2,0,existsError
		
		sw $t0,4($a1)			#store savings account number
		sw $t1,12($a1)			#store saving balance
		la $a0, open_message		#print open account message
		li $v0, 4
		syscall
		j printBankInfo
	
	existsError:
		la $a0, account_exists_message
		li $v0, 4
		syscall
		j Start
deposit:
# Command format: DE Account_Number Amount
	la $a3,buffer				#calculate the length of the buffer
	jal length				#buffer needs a minimum of 2 (command) + 5 (account number) + 1(balance) = 8 elements
	blt $v0,8,error				#if the buffer has less than 8 elements, than it is an INVALID banking transaction
		
	#GET ACCOUNT NUMBER (put in $t0)
	la $a3,buffer
	jal getAccountNumber
	addi $t0,$v0,0				# Account number is now in $t0
	
	#GET DEPOSIT AMOUNT (put in $t1)
	addi $a3,$a3,28
	addi $t1,$0,0				#balance
	balanceLoop2:
		lw $t2,0($a3)
		beq $t2,-999,balance2
		andi $t2,$t2,0x0F		# $t2 ascii -> int
		add $t1,$t1,$t2
		mul $t1,$t1,10
		addi $a3,$a3,4
		j balanceLoop2
	balance2:
		div $t1,$t1,10			# deposit amount is now in $t1
	
	la $a1,bank_array
	lw $a2,0($a1)				#checking account
	beq $t0,$a2,checkingDeposit
	lw $a2,4($a1)				#savings account
	beq $t0,$a2,savingsDeposit
	j error
	
	checkingDeposit:	
		lw $a2,8($a1)			# $t1 = deposit amount + $a2 = checking account balance
		add $t1,$t1,$a2
		sw $t1,8($a1)
		la $a0, deposit_message		#print deposit message
		li $v0, 4
		syscall
		j printBankInfo
	savingsDeposit:
		lw $a2,12($a1)			# $t0 = deposit amount + $a2 = savings account balance
		add $t1,$t1,$a2
		sw $t1,12($a1)
		la $a0, deposit_message		#print deposit message
		li $v0, 4
		syscall
		j printBankInfo
	
withdraw:
# Command format: WT Account_Number Amount
	la $a3,buffer					#calculate the length of the buffer
	jal length					#buffer needs a minimum of 2 (command) + 5 (account number) + 1(balance) = 8 elements
	blt $v0,8,error					#if the buffer has less than 8 elements, than it is an INVALID banking transaction
		
	#GET ACCOUNT NUMBER (put in $t0)
	la $a3,buffer
	jal getAccountNumber
	addi $t0,$v0,0					# Account number is now in $t0
	
	#GET WITHDRAWAL AMOUNT (put in $t1)
	addi $a3,$a3,28
	addi $t1,$0,0					#withdrawal amount
	balanceLoop3:
		lw $t2,0($a3)
		beq $t2,-999,balance3
		andi $t2,$t2,0x0F			# $t2 ascii -> int
		add $t1,$t1,$t2
		mul $t1,$t1,10
		addi $a3,$a3,4
		j balanceLoop3
	balance3:
		div $t1,$t1,10				# withdrawal amount is now in $t1
		
		div $t7,$t1,100
		mul $t7,$t7,5				# 5% of the withdrawal amount
				
		add $t1,$t1,$t7 			# $t1 = withdrawal amount + 5% fee
		
	la $a1,bank_array				# $t0 = account number
	lw $a2,0($a1)					#checking account
	beq $t0,$a2,checkingWithdrawal
	lw $a2,4($a1)					#savings account
	beq $t0,$a2,savingsWithdrawal
	j error
	
	checkingWithdrawal:
		#check if withdraw amount is less than balance -> if not j Error
		lw $a3,8($a1)				#checking balance
		blt $a3,$t1,insufficientFunds		#if $a3 < $t1 (account balanc < withdraw amount) -> ERROR
		#else, $a3 - $t1 -> store in bank_array
		sub $a3,$a3,$t1
		sw $a3,8($a1)
		
		la $a0, withdraw_message
		li $v0, 4
		syscall
		j printBankInfo
	savingsWithdrawal:
		#check if withdraw amount is less than balance -> if not j Error
		lw $a3,12($a1)				#savings balance
		blt $a3,$t1,insufficientFunds		#if $a3 < $t1 (account balanc < withdraw amount) -> ERROR
		#else, $a3 - $t1 -> store in bank_array
		sub $a3,$a3,$t1
		sw $a3,12($a1)
		
		la $a0, withdraw_message
		li $v0, 4
		syscall
		j printBankInfo
	
	insufficientFunds:
		la $a0, insufficientFunds_message
		li $v0, 4
		syscall
		j Start
	
get_loan:
# Command format: LN Amount	
	la $a3,buffer					#calculate the length of the buffer
	jal length					#buffer needs a minimum of 2 (command) + 1(loan amount minimum) = 3 elements
	blt $v0,3,error					#if the buffer has less than 3 elements, than it is an INVALID banking transaction
	
	#GET LOAN AMOUNT (put in $t1)
	la $a3,buffer
	addi $a3,$a3,8
	addi $t1,$0,0					#Loan amount
	loanLoop:
		lw $t2,0($a3)
		beq $t2,-999,loanAmount
		andi $t2,$t2,0x0F			# $t2 ascii -> int
		add $t1,$t1,$t2
		mul $t1,$t1,10
		addi $a3,$a3,4
		j loanLoop
	loanAmount:
		div $t1,$t1,10				# loan amount is now in $t1
		
	# the loan can only be taken out if user has more than 10,000 in both accounts
	# the loan cannot exceed 50% of total account balance
	la $a1,bank_array				# $t0 = account number
	lw $a2,8($a1)					# checking balance in $a2
	lw $a3,12($a1)					# savings balance in $a3
	add $t2,$a2,$a3					# TOTAL balance is now in $t2
	blt $t2,10000,loanError
	
	div $t3,$t2,100
	mul $t3,$t3,50					# 50% of total account balance
	bgt $t1,$t3,loanError				# loan cannot exceed 50% of total account balance
	
	#if it never branched: take out the loan
	sw $t1,16($a1)					# write the loan in bank_array
	la $a0, loan_message
	li $v0, 4
	syscall
	j printBankInfo
	
	loanError:
		la $a0, loanError_message
		li $v0, 4
		syscall
		j Start
	
transfer:
# Command format: TR  Account_Num_From A ccount_Num_To  Amount
	la $a3,buffer					#calculate the length of the buffer
	jal length					#buffer needs a minimum of 2 (command) + 5 (account 1 number) +5 (account 2 number) + 1(balance) = 13 elements
	blt $v0,13,payLoan				#if the buffer has less than 13 elements, than it is an INVALID banking transaction
		
	#GET ACCOUNT 1 NUMBER (put in $t5)
	la $a3,buffer
	jal getAccountNumber
	addi $t5,$v0,0					# Account "FROM" number is now in $t5
	#GET ACCOUNT 2 NUMBER (put in $t6)
	la $a3,buffer
	jal getSecondAccountNumber
	addi $t6,$v0,0					# Account2 "TO" is now in $t6
	#GET TRANFER AMOUNT (put in $t4)
	la $a3,buffer
	addi $a3,$a3,48
	addi $t1,$0,0					#Loan amount
	transferLoop:
		lw $t2,0($a3)
		beq $t2,-999,transferAmount
		andi $t2,$t2,0x0F			# $t2 ascii -> int
		add $t1,$t1,$t2
		mul $t1,$t1,10
		addi $a3,$a3,4
		j transferLoop
	transferAmount:
		div $t4,$t1,10				# Transfer amount is now in $t4
	
	la $a1,bank_array
	lw $t0,0($a1)
	beq $t0,$t5,fromCH
	lw $t0,4($a1)
	beq $t0,$t5,fromSV
	j transferError
	
	fromCH:
		#Check that destination account is valid and is SV
		lw $t0,4($a1)
		bne $t0,$t6,transferError
		
		lw $t0,8($a1)				# get checking balance
		blt $t0,$t4,transferError		# if checking balance < transfer amount -> Error
		#else: transfer the funds from CH to SV
		sub $t0,$t0,$t4
		sw $t0,8($a1)				# checking balance = check balance - transfer amount
		lw $t0,12($a1)
		add $t0,$t0,$t4				# saving balance = saving balance + transfer amount
		sw $t0,12($a1)
		la $a0, transfer_message		# print transfer message
		li $v0, 4
		syscall
		j printBankInfo
	fromSV:
		#Check that destination account is valid and is CH
		lw $t0,0($a1)
		bne $t0,$t6,transferError
	
		lw $t0,12($a1)				# get savings balance ($t0)
		blt $t0,$t4,transferError		# if savings balance < transfer amount -> Error
		#else: transfer the funds from SV to CH
		sub $t0,$t0,$t4
		sw $t0,12($a1)				# checking balance = check balance - transfer amount
		lw $t0,8($a1)
		add $t0,$t0,$t4				# saving balance = saving balance + transfer amount
		sw $t0,8($a1)
		la $a0, transfer_message		# print transfer message
		li $v0, 4
		syscall
		j printBankInfo		
		
	payLoan:
		blt $v0,8,error				#if the buffer has less than 8 elements (2 for TR + 5 for acct number + 1 min for amount) -> Error
		#GET ACCOUNT NUMBER (put in $t5)
		la $a3,buffer
		jal getAccountNumber
		addi $t5,$v0,0				# Account "FROM" number is now in $t5
		
		#GET TRANFER AMOUNT (put in $t4)
		la $a3,buffer
		addi $a3,$a3,28
		addi $t1,$0,0				#Loan amount
		transferLoop2:
			lw $t2,0($a3)
			beq $t2,-999,transferAmount2
			andi $t2,$t2,0x0F		# $t2 ascii -> int
			add $t1,$t1,$t2
			mul $t1,$t1,10
			addi $a3,$a3,4
			j transferLoop2
		transferAmount2:
			div $t4,$t1,10			# Transfer amount is now in $t4
		
		la $a1,bank_array
		lw $t0,0($a1)				# load checking account number
		beq $t0,$t5,loanFromCH			# if equal -> pay loan from CH account
		lw $t0,4($a1)				# load savings acct number
		beq $t0,$t5,loanFromSV			# if equal -> pay loan from SV account
		j transferError
				loanFromCH:
					lw $t0,8($a1)			# get savings balance ($t0)
					lw $t1,16($a1)
					blt $t0,$t4,transferError	# if savings balance < transfer amount -> Error
					bgt $t4,$t1,transferError	# check that the transfer amount is not greater than the loan amount
					#else: transfer the funds from CH to Loan
					sub $t0,$t0,$t4
					sw $t0,8($a1)			# checking balance = check balance - transfer amount
					lw $t0,16($a1)
					sub $t0,$t0,$t4			# saving balance = saving balance + transfer amount
					sw $t0,16($a1)
					la $a0, payLoan_message		# print transfer message
					li $v0, 4
					syscall
					j printBankInfo
				loanFromSV:
					lw $t0,12($a1)			# get savings balance ($t0)
					lw $t1,16($a1)			# check that the transfer amount is not greater than the loan amount
					blt $t0,$t4,transferError	# if savings balance < transfer amount -> Error
					bgt $t4,$t1,transferError
					#else: transfer the funds from CH to Loan
					sub $t0,$t0,$t4
					sw $t0,12($a1)			# checking balance = check balance - transfer amount
					lw $t0,16($a1)
					sub $t0,$t0,$t4			# saving balance = saving balance + transfer amount
					sw $t0,16($a1)
					la $a0, payLoan_message		# print transfer message
					li $v0, 4
					syscall
					j printBankInfo
				
	transferError:
		la $a0, transferError_message
		li $v0, 4
		syscall
		j Start
close_account:
# Command format: CL Account_Number
	la $a3,buffer					#calculate the length of the buffer
	jal length					#buffer needs a exactly 2 (command) + 5 (account number) = 7 elements
	bne $v0,7,CloseError				#if the buffer does NOT have 7 elements, then it is an INVALID banking transaction
		
	#GET ACCOUNT NUMBER (put in $t5)
	la $a3,buffer
	jal getAccountNumber
	addi $t5,$v0,0			
	
	la $a1,bank_array
	lw $t0,0($a1)
	beq $t0,$t5,closeCH
	lw $t0,4($a1)
	beq $t0,$t5,closeSV
	j CloseError
	
	closeCH:
		lw $t4,8($a1)			#put the checking balance in $t4
		sw $0,8($a1)			#remove all the funds from checking balance
		sw $0,0($a1)
		lw $t0,4($a1)			#load saving account number
		bne $t0,0,remainingToSV
		la $a0, close_message
		li $v0, 4
		syscall
		j printBankInfo
		remainingToSV:
			lw $t1,12($a1)		# $t1 = saving balance
			add $t1,$t1,$t4		# $t1 = checking balance + saving balance
			sw $t1,12($a1)		# store $t1 in saving balance
			la $a0, close_message
			li $v0, 4
			syscall
			j printBankInfo
	closeSV:
		lw $t4,12($a1)			#put the saving balance in $t4
		sw $0,12($a1)			#remove all the funds from checking balance
		sw $0,4($a1)
		lw $t0,0($a1)			#load checking account number
		bne $t0,0,remainingToCH
		la $a0, close_message
		li $v0, 4
		syscall
		j printBankInfo
		remainingToCH:
			lw $t1,8($a1)		# $t1 = checking balance
			add $t1,$t1,$t4		# $t1 = checking balance + saving balance
			sw $t1,8($a1)		# store $t1 in saving balance
			la $a0, close_message
			li $v0, 4
			syscall
			j printBankInfo
	CloseError:
		la $a0, closeError_message
		li $v0, 4
		syscall
		j Start

get_balance:
# Command format: BL Account_Number
	la $a3,buffer					#calculate the length of the buffer
	jal length					#buffer needs a exactly 2 (command) + 5 (account number) = 7 elements
	bne $v0,7,error				#if the buffer does NOT have 7 elements, then it is an INVALID banking transaction
		
	#GET ACCOUNT NUMBER (put in $t5)
	la $a3,buffer
	jal getAccountNumber
	addi $t5,$v0,0		
	
	la $a1,bank_array
	lw $t0,0($a1)
	beq $t0,$t5,CHbalance
	lw $t0,4($a1)
	beq $t0,$t5,SVbalance
	j error
	
	CHbalance:
		la $a0, balance_message
		li $v0, 4
		syscall
		li $v0, 11
		la $a0,'$'
		syscall
		lw $t0,8($a1)
		li $v0,1
		addi $a0,$t0,0
		syscall
		li $v0, 11
		la $a0,'\n'
		syscall
		j Start
		
	SVbalance:
		la $a0, balance_message
		li $v0, 4
		syscall
		li $v0, 11
		la $a0,'$'
		syscall
		lw $t0,12($a1)
		li $v0,1
		addi $a0,$t0,0
		syscall
		li $v0, 11
		la $a0,'\n'
		syscall
		j Start
history:
# Command format: QH Number_of_Queries
	la $a3,buffer			#calculate the length of the buffer
	jal length			#buffer needs a exactly 2 (command) + 1 (n number of last commands) = 3 elements
	bne $v0,3,error			#if the buffer does NOT have 3 elements, then it is an INVALID banking transaction
	
	la $a3,buffer
	lw $t0,8($a3)			# $t0 = n (number of command)  0< n <= 5
	
	bgt $t0,5,historyError
	ble $t0,0,historyError
	
	beq $t0,1,history1
	beq $t0,2,history2
	beq $t0,3,history3
	beq $t0,4,history4
	beq $t0,5,history5
	j historyError
	
	history1:
		la $a0, history_message
		li $v0, 4
		syscall
		j Start
	history2:
		la $a0, history_message
		li $v0, 4
		syscall
		j Start
	history3:
		la $a0, history_message
		li $v0, 4
		syscall
		j Start
	history4:
		la $a0, history_message
		li $v0, 4
		syscall
		j Start
	history5:
		la $a0, history_message
		li $v0, 4
		syscall
		j Start
		
	historyError:
		la $a0, historyError_message
		li $v0, 4
		syscall
	
	j Start
	
quit:
# Command format: QT
	la $a0, quit_message
	li $v0, 4
	syscall
	j Exit




