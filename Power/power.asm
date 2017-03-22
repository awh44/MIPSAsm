# Main program that calls the subroutine sum and prints the result.

	.text             		#assembly directive that indicates what follows are instructions
	.globl  main      		#assembly directive that makes the symbol main global
main:                   	#assembly label
	sub	$sp, $sp, 8			#push stack to save registers needed by the system code that called main
	sw	$ra, 0($sp)			#save return address
	
	##########get x
	li $v0, 4				#load the argument for a string output syscall
	la $a0, prompt1			#load the prompt
	syscall					#output the prompt
	
	li $v0, 5				#load the argument for getting an int using syscall
	syscall					#get the int
	add $s0, $v0, $zero		#temporarily place x in s0
	##########
	
	##########get y
	li $v0, 4				#load the argument for a string output syscall
	la $a0, prompt2			#load the prompt
	syscall					#output the prompt
	
	li $v0, 5				#load the argument for getting an int using syscall
	syscall					#get the int
	##########

	##########load arguments
	add $a0, $s0, $zero		#place x (the base) in the first argument register
	add $a1, $v0, $zero		#place y (the power) in the second argument register
	##########

	##########call power and save the returned value
	jal	power				#call subroutine to compute x^y
	sw	$v0,4($sp)  		#result returned in $v0 and stored on the stack
	##########

	##########print the computed value
	li	$v0,4       		#the argument to a system call is placed in register $v0
							#The value 4 tells syscall to print a string
	la	$a0, result  		#pseudo-instruction to load the address of the label for the output
							#The address of the string must be placed in register $a0
	syscall           		#system call to print the string at address str

	li	$v0,1       		#The value 1 tells syscall to print an integer
	lw	$a0,4($sp)  		#Load the sum from the stack to register $a0 
	syscall           		#System call to print the integer in register $a0 (value of x^y)
	##########	
	
	lw	$ra,0($sp)			#restore return address used to jump back to system
	add	$sp,$sp,8			#pop stack to prepare for the return to the system
	jr	$ra         		#[jump register] return to the system 


	.data             		#Assembly directive indicating what follows is data
prompt1:					#label to prompt user
	.asciiz "Enter base (x). "
prompt2:					#label to prompt user
	.asciiz "Enter power (y). "
result:						#label for the final result
	.asciiz "x^y = "
	
# Function power - compute a number to some power (e.g., x^y)
# Inputs:
#   int x, y passed in registers $a0, $a1.
# Output:
#   int x^y, stored in $t0 and returned in $v0
# Temporaries:  $t0 and $t1
#   by convention, $t0 and $t1 do not have to be saved 
	.text
power:
	#none of the saved registers are affected by this function, and
	#power does not call any other functions, so $ra is not affected.
	#Therefore nothing has to be done with the stack
	
	add $t0, $zero, 1		#initialize the register for calculating the power
							#power doesn't call any other functions, so it is fine to put it in a temp register
	add $t1, $a1, $zero		#initialize the loop counter to the value of y
	
	LOOP:
	beq $t1, $zero EXIT		#if loop counter = 0, then exit function
	mul $t0, $t0, $a0		#compute the next iteration
	sub $t1, $t1, 1			#decrement the loop counter by 1
	j LOOP					#return to beginning of loop to check condition
	
	EXIT:
	add $v0, $t0, $zero		#place the calculated value of x^y in the return register
	jr	$ra         		#return to calling procedure