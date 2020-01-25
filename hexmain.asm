  # hexmain.asm
  # Written 2015-09-04 by F Lundevall
  # Copyright abandonded - this file is in the public domain.

	.text
main:
	li	$a0,10		# change this to test different values

	jal	hexasc		# call hexasc
	nop			# delay slot filler (just in case)	

	move	$a0,$v0		# copy return value to argument register

	li	$v0,11		# syscall with v0 = 11 will print out
	syscall			# one byte from a0 to the Run I/O window
	
stop:	j	stop		# stop after one run
	nop			# delay slot filler (just in case)

.global hexasc
hexasc:
	slti	$t0,$a0,10 	# sets t0 to 1 if less then 10, else 0
	beq 	$t0,$zero,else  # branches to else if greater then nine
	addi	$v0,$a0,0x30	# adds 0x30 to get correct hex value for 0 to 9
	j	L1
else:
	addi	$v0,$a0,0x37	# adds 0x37 to get correct hex value for A to F
	
L1:
	andi	$v0,$v0,0x7f	# sets bit 8 to MSB to 0 to ensure result is an ASCII value
	jr	$ra
