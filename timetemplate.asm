  # timetemplate.asm
  # Written 2015 by F Lundevall
  # Copyright abandonded - this file is in the public domain.

.macro	PUSH (%reg)
	addi	$sp,$sp,-4
	sw	%reg,0($sp)
.end_macro

.macro	POP (%reg)
	lw	%reg,0($sp)
	addi	$sp,$sp,4
.end_macro

	.data
	.align 2
mytime:	.word 0x5957
timstr:	.ascii "text more text lots of text\0"
	.text
main:
	# print timstr
	la	$a0,timstr
	li	$v0,4
	syscall
	nop
	# wait a little
	li	$a0,20
	jal	delay
	nop
	# call tick
	la	$a0,mytime
	jal	tick
	nop
	# call your function time2string
	la	$a0,timstr
	la	$t0,mytime
	lw	$a1,0($t0)
	jal	time2string
	nop
	# print a newline
	li	$a0,10
	li	$v0,11
	syscall
	nop
	# go back and do it all again
	j	main
	nop
# tick: update time pointed to by $a0
tick:	lw	$t0,0($a0)	# get time
	addiu	$t0,$t0,1	# increase
	andi	$t1,$t0,0xf	# check lowest digit
	sltiu	$t2,$t1,0xa	# if digit < a, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0x6	# adjust lowest digit
	andi	$t1,$t0,0xf0	# check next digit
	sltiu	$t2,$t1,0x60	# if digit < 6, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0xa0	# adjust digit
	andi	$t1,$t0,0xf00	# check minute digit
	sltiu	$t2,$t1,0xa00	# if digit < a, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0x600	# adjust digit
	andi	$t1,$t0,0xf000	# check last digit
	sltiu	$t2,$t1,0x6000	# if digit < 6, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0xa000	# adjust last digit
tiend:	sw	$t0,0($a0)	# save updated result
	jr	$ra		# return
	nop

  # you can write your code for subroutine "hexasc" below this line
  #
hexasc:
	slti	$t0,$a0,10 	# sets t0 to 1 if less then 10, else 0
	beq 	$t0,$zero,else  # branches to else if greater then nine
	addi	$v0,$a0,0x30	# adds 0x30 to get correct hex value for 0 to 9
	j	L1
	nop
else:
	addi	$v0,$a0,0x37	# adds 0x37 to get correct hex value for A to F
	
L1:
	andi	$v0,$v0,0x7f	# sets bit 8 to MSB to 0 to ensure result is an ASCII value
	jr	$ra
	nop
	
delay:
	ble	$a0,$0,delayd 	# while a0 > 0
	addi 	$a0,$a0,-1	# a0--
	
	add	$t1,$0,$0	# set t1 to 0
	li	$t0,1#4711	
dL:	ble	$t0,$t1,delay	# while t1 < t0
	addi	$t1,$t1,1	# t1++	
	nop
	j 	dL
	nop
delayd:	jr $ra
	nop

time2string:
	PUSH 	($ra)
	PUSH 	($s0)
	PUSH 	($a0)

	move	$s0,$a0		# Write to address
	
	and	$a0,$a1,0xf000	# mask
	srl 	$a0,$a0,12	# shift right for hexasc
	jal	hexasc		# convert ascii char
	nop
	sb	$v0,0($s0)	# store ascii char code to string
	
	and	$a0,$a1,0xf00	# mask
	srl 	$a0,$a0,8	# shift right for hexasc
	jal	hexasc		# convert ascii char
	nop
	sb	$v0,1($s0)	# store ascii char code to string
	
	addi	$v0,$0,0x3a	# set v0 to :
	sb	$v0,2($s0)	# store ascii char code to string
	
	and	$a0,$a1,0xf0	# mask
	srl 	$a0,$a0,4	# shift right for hexasc
	jal	hexasc		# convert ascii char
	nop
	sb	$v0,3($s0)	# store ascii char code to string
	
	and	$a0,$a1,0xf	# mask
	jal	hexasc		# convert ascii char
	nop
	sb	$v0,4($s0)	# store ascii char code to string
	
	sb	$0,5($s0)	# append null byte

	
	POP	($a0)
	POP	($s0)
	POP	($ra)
	jr	$ra
	nop
	
	
	
