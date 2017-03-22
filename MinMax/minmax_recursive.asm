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
	
		jal MinMaxRec
	
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
	.asciiz "MinMaxRec = "
comma:
	.asciiz ", "						#used to seperate values in the output

# Function MinMaxIt - finds the value of the minimum and maximum elements in an array recursively
# Inputs:
#   int * A in $a0	 - pointer to first element of array
#	int n in $a1	 - size of array
#	int * min in $a2 - pointer to location the min will be stored
#	int * max in $a3 - pointer to location the max will be stored
# Output:
#   The locations pointed to by min and max will have the values of the min and max of the array
# Temporaries:
#	$t0, $t1, $t2 as needed - do not have to be saved, by convention
# registers $ra and $a0 through $a3 are affected by recursive calls, and they are saved on and restored
#	 from the stack as appropriate
# uses stack for storing "return" values of recursive calls
	.text
MinMaxRec:
		bne $a1, 1, TWO					#if there is not one element, jump to see if there are two
		lw  $t0, 0($a0)					#otherwise load the first/only array element
		sw  $t0, 0($a2)					#save it as the min value
		sw  $t0, 0($a3)					#and the max value
		jr  $ra							#and return to the caller
		TWO:
			bne $a1, 2, ELSE			#if there are not two elements, jump to the final case
			lw  $t0, 0($a0)				#otherwise, load the first array element
			lw  $t1, 4($a0)				#and the second/last array element
			slt $t2, $t0, $t1			#compare to see if $t0 < $t1
			bne $t2, 1, REVERSE			#if it isn't, the reverse ($t0 >= $t1) is true
			sw  $t0, 0($a2)				#otherwise, store $t0 as the min
			sw  $t1, 0($a3)				#and $t1 as the max
			jr $ra						#and return to the caller
			REVERSE:
				sw  $t1, 0($a2)			#if it is reversed, store $t1 as the min,
				sw  $t0, 0($a3)			#$t0 as the max,
				jr $ra					#and return to the caller
		ELSE:
		#####new function call coming, so save return address and function parameters
			sub $sp, $sp, 20			#create five places on stack
			sw  $ra, 16($sp)			#save the return address at the top of the stack
			sw  $a3, 12($sp)			#save fourth parameter on stack
			sw  $a2, 8($sp)				#save third
			sw  $a1, 4($sp)				#save second
			sw  $a0, 0($sp)				#save first
		##########
		
		#####set new parameters (first parameter is already set to A)
			div $a1, $a1, 2				#$a1 = $a1 / 2 = n /2
			
			sub $sp, $sp, 8				#create room for min1 and max1 on stack
			add $a2, $sp, 4				#store address of min1 in third parameter
			add $a3, $sp, 0				#store address of max1 in fourth parameter
		##########
		
		jal MinMaxRec					#make the first recursive call to the function
		
		#####set new parameters again
			mul $t0, $a1, 4				#$a1 still = n / 2, so multiply by 4
			add $a0, $a0, $t0			#and add to address of A to get address of A[n/2]
			
			lw  $t0, 12($sp)			#load the value of original $a1/n from stack
			sub $a1, $t0, $a1			#a1 still holds n/2, so do $t0 - $a1 to get n - n/2
			
			sub $sp, $sp, 8				#create room for min2 and max2 on stack
			add $a2, $sp, 4				#store address of min2 in third parameter
			add $a3, $sp, 0				#store address of max2 in fourth parameter
		##########
			
			jal MinMaxRec				#make second recursive call to function
			
		#####load the parameters back
			lw  $a0, 16($sp)
			lw  $a1, 20($sp)
			lw  $a2, 24($sp)
			lw  $a3, 28($sp)
		##########
		
		#####find the min element out of min1 and min2
			lw  $t0, 12($sp)			#load min1 into $t0
			lw  $t1, 4($sp)				#load min2 into $t1
			slt $t2, $t0, $t1			#store result of $t0 < $t1 in $t2
			beq $t2, 0, MINELSE			#if $t0 is not < $t1, then $t0 >= $t1
			sw  $t0, 0($a2)				#otherwise save the value in t0 at the address of $a2	
			j   MAX
		MINELSE:
				sw  $t1, 0($a2)			#if $t1 <= $t0, then save $t1 as min at address $a2
		##########
		
		#####find the max element out of max1 and max2
		MAX:
			lw  $t0, 0($sp)				#load max1 into $t0
			lw  $t1, 8($sp)				#load max2 into $t1
			beq $t0, $t1, MAXELSE		#if $t0 = $t1, $t0 not < $t1
			slt $t2, $t1, $t0			#check if $t1 < $t0 (i.e., $t0 > $t1)
			beq $t2, 0, MAXELSE			#if $t1 > $t0, go to else condition
			sw  $t0, 0($a3)				#otherwise, $t0 > $t1, so save at address indicated by $a3
			j   EXIT
		MAXELSE:
			sw $t1, 0($a3)				#if $t0 is not > $t1, save $t1 as max at address indicated by $a3
		##########
		
		EXIT:
			lw  $ra, 32($sp)			#restore the return address to $ra from the stack
			add $sp, $sp, 36			#restore the stack
			jr  $ra						#return to the calling function
			
