	.text
	.globl main
main:
		sub $sp, $sp, 4					#make room,
		sw  $ra, 0($sp)					#and save the return address, because a function will be called later
		
	#####load addresses of array and min/max variables
		la  $s0, A
		la  $s1, min
		la  $s2, max
	##########
	
	#####prepare parameters
		add $a0, $s0, $zero				#load the address of A into the first parameter
		add $a1, $zero, 10				#load number of elements into second parameter
		add $a2, $s1, $zero				#load the address of min into third parameter
		add $a3, $s2, $zero				#load the address of max into third parameter
	##########
	
		jal MinMaxIt
	
	#####output the computed results to console
		li  $v0, 4						#indicate to syscall it's a string output to console
		la  $a0, minmax_label			#load the address of the string to be output
		syscall							#output it
		
		li  $v0, 1						#indicate to syscall an int is to be output to console
		lw  $a0, 0($s1)					#load the int
		syscall							#output it
		
		li  $v0, 4						#indicate to syscall it's a string output to console
		la  $a0, comma					#load the address of the string to be output
		syscall							#output it
		
		li  $v0, 1						#indicate to syscall an int is to be output to console
		lw  $a0, 0($s2)					#load the int
		syscall							#output it
	##########
	
		lw  $ra, 0($sp)
		add $sp, $sp, 4
		jr  $ra

	.data             					#Assembly directive indicating what follows is data
A:
	.word  1,2,3,4,5,6,7,8,9,10
min:
	.word 0
max:
	.word 0
minmax_label:							#labels the output of the minmax algorithm
	.asciiz "MinMaxIt = "
comma:
	.asciiz ", "						#used to seperate values in the output

	
# Function MinMaxIt - finds the value of the minimum and maximum elements in an array iteratively
# Inputs:
#   int * A in $a0		- pointer to first element of array
#	int n in $a1		- size of array
#	int * _min in $a2	- pointer to location the min will be stored
#	int * _max in $a3	- pointer to location the max will be stored
# Output:
#   The locations pointed to by _min and _max will have the values of the min and max of the array
# Temporaries:
#	$t0, $t1, $t2, $t3, $t4, and $t5 - do not have to be saved, by convention
# s registers unused and function does not call other functions, so stack not used
	.text
MinMaxIt:
		
	#####initialize the min and max
		lw  $t0, 0($a0)			#$t0 = min - set to first element of array
		lw  $t1, 0($a0)			#$t1 = max - set to first element of array
	##########
		
		add $t3, $a0, 4						#initialize $t3 ("p") to the address of second array element
		
	#####calculate the last address + 4 for use in loop condition
		mul $t2, $a1, 4						#"convert" number of elements to number of bytes
		add $t2, $t2, $a0					#start at the first element and add num of calculated bytes
	###########
	
	LOOP:
		slt $t4, $t3, $t2					#if the array address is less than last array address + 4
		beq $t4, $zero, EXIT				#then don't exit the loop
		lw  $t5, 0($t3)						#get the value of next array element, put it in $t5
		slt $t4, $t5, $t0					#place result of $t5 (*p) < $t0 (min) in $t4
		beq $t4, $zero, MAXTEST				#if $t5 is not less than $t0, skip to the max test
		add $t0, $t5, $zero					#otherwise, store $t5 in $t0 (as the new min)
		MAXTEST:
			beq $t5, $t1, INCREMENT			#if $t5 is equal to the current max, skip to the increment step of the loop
			slt $t4, $t5, $t1				#store result of $t5 (*p) < $t1 (max) test in $t4
			bne $t4, $zero, INCREMENT		#if $t4 != 0 ($t4 = 1), $t5 < $t1, so skip to increment step
			add $t1, $t5, $zero				#otherwise, $t5 > $t1, so set it as the new max
		INCREMENT:
			add $t3, $t3, 4					#increment the address pointer to the next address in the array
			j LOOP							#and return to check the loop condition
	EXIT:
		sw  $t0, 0($a2)
		sw  $t1, 0($a3)
		jr $ra
	