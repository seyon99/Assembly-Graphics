#####################################################################
#
# CSCB58 Winter 2021 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Seyon Kuganesan, 1004260729, kugane22
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4 (choose the one the applies)
#
# Which approved features have been implemented for milestone 4?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes / no / yes, and please share this project github link as well!
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

.eqv SCREEN 0x10008000 # memory address of pixel (0,0)
.eqv ROW_SHIFT	7
.eqv TEXT 0xFF4DDBBD
#.eqv SCORE 0xFFFF6347

.data
	WIDTH:	.word 32 # 256/8 = 32
	HEIGHT:	.word 32
	shipHeadX: .word 0 
	shipHeadY: .word 0
	tempX1:	.word 0 # for collision function
	tempX2:	.word 0 # for collision function
	tempX3:	.word 0 # for collision function
	cometX1:  .word	31
	cometX2:  .word 30
	cometX3:	.word 29
	cometY1: .word	0
	cometY2: .word	0
	cometY3: .word	0
	health:	.word 32
	score:	.word 0
	backgroundColor: .word 0x000000
	borderColor:	.word 0x5A0AFF
	shipColor:	.word 0x1afffd
	cometColor:	.word 0x949494
	damageColor:	.word 0xf50010
	healthBarColor:	.word 0x05FF32
	healthBarDmg:	.word 0xFF0000
	comet_width:	 .word 3
	comet_height: .word 3


.globl main
.text

main:
	lw $a0, WIDTH
	lw $a1, backgroundColor
	mul $a2, $a0, $a0 #total number of pixels on screen
	mul $a2, $a2, 4 #align addresses
	add $a2, $a2, $gp #add base of gp
	add $a0, $gp, $zero #loop counter

FillLoop:
	beq $a0, $a2, initGame
	sw $a1, 0($a0) #store color
	addiu $a0, $a0, 4 #increment counter
	j FillLoop
	
initGame:
	li $t0, 3
	sw $t0, shipHeadX
	li $t0, 15
	sw $t0, shipHeadY

drawBorder:
	li $t1, 0 # X coordinate for top border line
	topLoop:
	move $a0, $t1
	li $a1, 1 # Y coordinate for top border line
	jal pixelAddress # get address of coord
	move $a0, $v0
	lw $a1, borderColor
	jal drawPixel
	add $t1, $t1, 1
	
	bne $t1, 32, topLoop
 
 	li $t1, 0 # X coordinate for top border line
	healthLoop:
	move $a0, $t1
	li $a1, 0 # Y coordinate for top border line
	jal pixelAddress # get address of coord
	move $a0, $v0
	lw $a1, healthBarColor
	jal drawPixel
	add $t1, $t1, 1
	
	bne $t1, 32, healthLoop


mainLoop:
	jal drawComet
	jal getInput
	j updateHealth

drawComet:
	#generate a random y-index for first comet, between 3 and 30
	li $v0, 42
	li $a0, 0
	li $a1, 27
	syscall
	addi $a0, $a0, 3 # $a0 = center y-coord of comet
	sw $a0, cometY1
	
	#generate a random y-index for second comet, between 3 and 30
	li $v0, 42
	li $a0, 0
	li $a1, 27
	syscall
	addi $a0, $a0, 3 # $a0 = center y-coord of comet
	sw $a0, cometY2
	
	#generate a random y-index for third comet, between 3 and 30
	li $v0, 42
	li $a0, 0
	li $a1, 27
	syscall
	addi $a0, $a0, 3 # $a0 = center y-coord of comet
	sw $a0, cometY3
	
	#initial x-values for loop
	li $t5, 31 #x coord for back pixel of comet
	sw $t5, cometX3
	li $t6, 30 #x coord for middle pixels of comet
	sw $t6, cometX2
	li $t7, 29 #x coord for front pixel of comet
	sw $t7, cometX1
	
	cometLoop:
	# front part of comet1
	add $a0, $zero, $t7 # starting X-coord
	add $t9, $zero, $t7 # starting X-coord (copy for calculating collison)
	sw $t9, tempX1
	lw $a1, cometY1
	jal pixelAddress
	move $a0, $v0
	lw $a1, cometColor
	jal drawPixel
	#front part of comet2
	add $a0, $zero, $t7 # starting X-coord
	add $t9, $zero, $t7 # starting X-coord (copy for calculating collison)
	sw $t9, tempX2
	lw $a1, cometY2
	jal pixelAddress
	move $a0, $v0
	lw $a1, cometColor
	jal drawPixel
	#front part of comet2
	add $a0, $zero, $t7 # starting X-coord
	add $t9, $zero, $t7 # starting X-coord (copy for calculating collison)
	sw $t9, tempX1
	lw $a1, cometY3
	jal pixelAddress
	move $a0, $v0
	lw $a1, cometColor
	jal drawPixel
	
	#back part of comet1
	add $a0, $zero, $t5 # starting X-coord
	lw $a1, cometY1
	jal pixelAddress
	move $a0, $v0
	lw $a1, cometColor
	jal drawPixel
	#back part of comet2
	add $a0, $zero, $t5 # starting X-coord
	lw $a1, cometY2
	jal pixelAddress
	move $a0, $v0
	lw $a1, cometColor
	jal drawPixel
	#back part of comet3
	add $a0, $zero, $t5 # starting X-coord
	lw $a1, cometY3
	jal pixelAddress
	move $a0, $v0
	lw $a1, cometColor
	jal drawPixel
	
	#top part of comet1
	add $a0, $zero, $t6 # starting X-coord
	lw $a1, cometY1
	addiu $a1, $a1, 1
	jal pixelAddress
	move $a0, $v0
	lw $a1, cometColor
	jal drawPixel
	#top part of comet2
	add $a0, $zero, $t6 # starting X-coord
	lw $a1, cometY2
	addiu $a1, $a1, 1
	jal pixelAddress
	move $a0, $v0
	lw $a1, cometColor
	jal drawPixel
	#top part of comet3
	add $a0, $zero, $t6 # starting X-coord
	lw $a1, cometY3
	addiu $a1, $a1, 1
	jal pixelAddress
	move $a0, $v0
	lw $a1, cometColor
	jal drawPixel
	
	#bottom part of comet1
	add $a0, $zero, $t6 # starting X-coord
	lw $a1, cometY1
	addiu $a1, $a1, -1
	jal pixelAddress
	move $a0, $v0
	lw $a1, cometColor
	jal drawPixel
	#bottom part of comet2
	add $a0, $zero, $t6 # starting X-coord
	lw $a1, cometY2
	addiu $a1, $a1, -1
	jal pixelAddress
	move $a0, $v0
	lw $a1, cometColor
	jal drawPixel
	#bottom part of comet1
	add $a0, $zero, $t6 # starting X-coord
	lw $a1, cometY3
	addiu $a1, $a1, -1
	jal pixelAddress
	move $a0, $v0
	lw $a1, cometColor
	jal drawPixel
	
	add $t2, $zero, $t7 # old x values stored in $t2-$t4 (save prior to decrementing for erasing purposes)
	add $t3, $zero, $t6
	add $t4, $zero, $t5
	
	li $v0, 32
	li $a0, 15 # Wait one second (1000 milliseconds)
	syscall
	
	addiu $t7, $t7, -1 #decredment one of the x values of comet
	#erase the front pixel of comet1
	add $a0, $zero, $t2 #old x position
	lw $a1, cometY1
	jal pixelAddress
	move $a0, $v0
	lw $a1, backgroundColor
	jal drawPixel
	#erase the front pixel of comet2
	add $a0, $zero, $t2 #old x position
	lw $a1, cometY2
	jal pixelAddress
	move $a0, $v0
	lw $a1, backgroundColor
	jal drawPixel
	#erase the front pixel of comet3
	add $a0, $zero, $t2 #old x position
	lw $a1, cometY3
	jal pixelAddress
	move $a0, $v0
	lw $a1, backgroundColor
	jal drawPixel
	
	addiu $t6, $t6, -1 # decrement one of the x values of the comet
	#erase the top pixel of comet1
	add $a0, $zero, $t3 #old x position
	lw $a1, cometY1
	addi $a1, $a1, 1
	jal pixelAddress
	move $a0, $v0
	lw $a1, backgroundColor
	jal drawPixel
	#erase the top pixel of comet2
	add $a0, $zero, $t3 #old x position
	lw $a1, cometY2
	addi $a1, $a1, 1
	jal pixelAddress
	move $a0, $v0
	lw $a1, backgroundColor
	jal drawPixel
	#erase the top pixel of comet3
	add $a0, $zero, $t3 #old x position
	lw $a1, cometY3
	addi $a1, $a1, 1
	jal pixelAddress
	move $a0, $v0
	lw $a1, backgroundColor
	jal drawPixel
	
	#erase the bottom pixel of comet1
	add $a0, $zero, $t3 # old x position
	lw $a1, cometY1
	addiu $a1, $a1, -1
	jal pixelAddress
	move $a0, $v0
	lw $a1, backgroundColor
	jal drawPixel
	#erase the bottom pixel of comet2
	add $a0, $zero, $t3 # old x position
	lw $a1, cometY2
	addiu $a1, $a1, -1
	jal pixelAddress
	move $a0, $v0
	lw $a1, backgroundColor
	jal drawPixel
	#erase the bottom pixel of comet3
	add $a0, $zero, $t3 # old x position
	lw $a1, cometY3
	addiu $a1, $a1, -1
	jal pixelAddress
	move $a0, $v0
	lw $a1, backgroundColor
	jal drawPixel
	
	addiu $t5, $t5, -1 # decrement one of the x values of the comet
	#erase the back pixel of comet1
	add $a0, $zero, $t4 #old x position
	lw $a1, cometY1
	jal pixelAddress
	move $a0, $v0
	lw $a1, backgroundColor
	jal drawPixel
	#erase the back pixel of comet2
	add $a0, $zero, $t4 #old x position
	lw $a1, cometY2
	jal pixelAddress
	move $a0, $v0
	lw $a1, backgroundColor
	jal drawPixel
	#erase the back pixel of comet3
	add $a0, $zero, $t4 #old x position
	lw $a1, cometY3
	jal pixelAddress
	move $a0, $v0
	lw $a1, backgroundColor
	jal drawPixel
	
	bne $t7, 0, cometLoop
	#maybe get the program to sleep at the end of every iteration to slow comet


getInput:

	#get the input from the keyboard
	li $t9, 0xffff0000 
	lw $t8, 0($t9)
	beq $t8, 1, keypress_happened

keypress_happened:
	lw $t7, 4($t9)
	#check to see which direction to draw
	beq $t7, 119, drawUp
	beq  $t7, 115, drawDown
	beq  $t7, 97, drawLeft
	beq  $t7, 100, drawRight
	#jump back to get input if an unsupported key was pressed
	j getInput

drawUp:
	# draw front part of ship
	lw $t0, shipHeadX
	lw $t1, shipHeadY
	add $t4, $zero, $t0 # old x coord of ship head
	add $t5, $zero, $t1 # old y coord of ship head
	addiu $t1, $t1, -1
	add $a0, $zero, $t0
	add $a1, $zero, $t1
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, shipColor
	jal drawPixel
	sw  $t1, shipHeadY # store the new Y value in .data
	#erase old pixel
	add $a0, $zero, $t4
	add $a1, $zero, $t5
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, backgroundColor
	jal drawPixel
	
	#draw middle part
	lw $t0, shipHeadX
	lw $t1, shipHeadY
	
	addiu $t4, $t0, -1 # original middle X coord
	addiu $t5, $t1, 1 #original middle Y coord
	addiu $t0, $t0, -1
	add $a0, $zero, $t0
	add $a1, $zero, $t1
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, shipColor
	jal drawPixel
	#erase old pixel
	add $a0, $zero, $t4
	add $a1, $zero, $t5
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, backgroundColor
	jal drawPixel
	
	#draw left thruster
	lw $t0, shipHeadX
	lw $t1, shipHeadY
	addiu $t4, $t0, -2
	add $t5, $zero, $t1
	addiu $t0, $t0, -2
	addiu $t1, $t1, -1
	add $a0, $zero, $t0
	add $a1, $zero, $t1
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, shipColor
	jal drawPixel
	#erase old pixel
	add $a0, $zero, $t4
	add $a1, $zero, $t5
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, backgroundColor
	jal drawPixel
	
	#draw right thruster
	lw $t0, shipHeadX
	lw $t1, shipHeadY
	addiu $t4, $t0, -2
	addiu $t5, $t1, 2
	addiu $t0, $t0, -2
	addiu $t1, $t1, 1
	add $a0, $zero, $t0
	add $a1, $zero, $t1
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, shipColor
	jal drawPixel
	#erase old pixel
	add $a0, $zero, $t4
	add $a1, $zero, $t5
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, backgroundColor
	jal drawPixel
	j mainLoop
	
drawDown:
	lw $a0, shipHeadX
	lw $a1, shipHeadY
	# draw front part
	lw $t0, shipHeadX
	lw $t1, shipHeadY
	add $t4, $zero, $t0
	add $t5, $zero, $t1
	addiu $t1, $t1, 1
	add $a0, $zero, $t0
	add $a1, $zero, $t1
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, shipColor
	jal drawPixel
	sw  $t1, shipHeadY # store the new Y value in .data
	#erase old pixel
	add $a0, $zero, $t4
	add $a1, $zero, $t5
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, backgroundColor
	jal drawPixel
	
	#draw middle part
	lw $t0, shipHeadX
	lw $t1, shipHeadY
	
	addiu $t4, $t0, -1 # original middle X coord
	addiu $t5, $t1, -1 #original middle Y coord
	addiu $t0, $t0, -1
	add $a0, $zero, $t0
	add $a1, $zero, $t1
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, shipColor
	jal drawPixel
	#erase old pixel
	add $a0, $zero, $t4
	add $a1, $zero, $t5
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, backgroundColor
	jal drawPixel
	
	#draw left thruster
	lw $t0, shipHeadX
	lw $t1, shipHeadY
	addiu $t4, $t0, -2
	add $t5, $t1, -2
	addiu $t0, $t0, -2
	addiu $t1, $t1, -1
	add $a0, $zero, $t0
	add $a1, $zero, $t1
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, shipColor
	jal drawPixel
	#erase old pixel
	add $a0, $zero, $t4
	add $a1, $zero, $t5
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, backgroundColor
	jal drawPixel
	
	#draw right thruster
	lw $t0, shipHeadX
	lw $t1, shipHeadY
	addiu $t4, $t0, -2
	add $t5, $zero, $t1
	addiu $t0, $t0, -2
	addiu $t1, $t1, 1
	add $a0, $zero, $t0
	add $a1, $zero, $t1
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, shipColor
	jal drawPixel
	#erase old pixel
	add $a0, $zero, $t4
	add $a1, $zero, $t5
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, backgroundColor
	jal drawPixel
	j mainLoop
		
drawLeft:
	# draw front part
	lw $t0, shipHeadX
	lw $t1, shipHeadY
	add $t4, $zero, $t0 # original X
	add $t5, $zero, $t1 # original Y
	addiu $t0, $t0, -1
	sw  $t0, shipHeadX # new X coord stored in .data
	add $a0, $zero, $t0
	add $a1, $zero, $t1
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, shipColor
	jal drawPixel
	#erase old pixel
	add $a0, $zero, $t4
	add $a1, $zero, $t5
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, backgroundColor
	jal drawPixel
	
	#draw middle part
	lw $t0, shipHeadX
	lw $t1, shipHeadY # Y coord already stored
	add $t4, $zero, $t0
	add $t5, $zero, $t1
	addiu $t0, $t0, -1
	add $a0, $zero, $t0
	add $a1, $zero, $t1
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, shipColor
	jal drawPixel
	
	#draw left thruster
	lw $t0, shipHeadX
	lw $t1, shipHeadY
	addiu $t4, $t0, -1
	addiu $t5, $t1, -1
	addiu $t0, $t0, -2
	addiu $t1, $t1, -1
	add $a0, $zero, $t0
	add $a1, $zero, $t1
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, shipColor
	jal drawPixel
	#erase old pixel
	add $a0, $zero, $t4
	add $a1, $zero, $t5
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, backgroundColor
	jal drawPixel
	
	#draw right thruster
	lw $t0, shipHeadX
	lw $t1, shipHeadY
	addiu $t4, $t0, -1
	addiu $t5, $t1, 1
	addiu $t0, $t0, -2
	addiu $t1, $t1, 1
	add $a0, $zero, $t0
	add $a1, $zero, $t1
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, shipColor
	jal drawPixel
	#erase old pixel
	add $a0, $zero, $t4
	add $a1, $zero, $t5
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, backgroundColor
	jal drawPixel
	j mainLoop
	
drawRight:
	lw $t8, shipHeadX
	lw $t9, shipHeadY
	# draw front part
	lw $t0, shipHeadX
	lw $t1, shipHeadY
	add $t8, $zero, $t0 # original X
	add $t9, $zero, $t1 # original Y
	addiu $t0, $t0, 1
	add $a0, $zero, $t0
	add $a1, $zero, $t1
	sw  $t0, shipHeadX # new X coord stored in .data
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, shipColor
	jal drawPixel
	#erase old pixel
	add $a0, $zero, $t4
	add $a1, $zero, $t5
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, backgroundColor
	jal drawPixel
	
	#draw middle part
	lw $t0, shipHeadX
	lw $t1, shipHeadY # Y coord already stored
	addiu $t4, $t0, -2
	add $t5, $zero, $t1
	addiu $t0, $t0, -1
	add $a0, $zero, $t0
	add $a1, $zero, $t1
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, shipColor
	jal drawPixel
	#erase old pixel
	add $a0, $zero, $t4
	add $a1, $zero, $t5
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, backgroundColor
	jal drawPixel
	
	#draw left thruster
	lw $t0, shipHeadX
	lw $t1, shipHeadY
	addiu $t4, $t0, -3
	addiu $t5, $t1, -1
	addiu $t0, $t0, -2
	addiu $t1, $t1, -1
	add $a0, $zero, $t0
	add $a1, $zero, $t1
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, shipColor
	jal drawPixel
	#erase old pixel
	add $a0, $zero, $t4
	add $a1, $zero, $t5
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, backgroundColor
	jal drawPixel
	
	#draw right thruster
	lw $t0, shipHeadX
	lw $t1, shipHeadY
	addiu $t4, $t0, -3
	addiu $t5, $t1, 1
	addiu $t0, $t0, -2
	addiu $t1, $t1, 1
	add $a0, $zero, $t0
	add $a1, $zero, $t1
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, shipColor
	jal drawPixel
	#erase old pixel
	add $a0, $zero, $t4
	add $a1, $zero, $t5
	jal pixelAddress
	add $a0, $v0, $zero
	lw $a1, backgroundColor
	jal drawPixel
	j mainLoop

# function to update the health bar and integer health value
updateHealth:
	# check if coords are equal
	lw $t2, tempX1
	lw $t3, tempX2
	lw $t4, tempX3
	lw $t8, shipHeadX
	beq $t2, $t8, checkY # tempX1 == shipHeadX
	beq $t3, $t8, checkY
	beq $t4, $t8, checkY
	j mainLoop # jump back to the main loop because there's no collision
	
	checkY:
	lw $t5, cometY1
	lw $t6, cometY2
	lw $t7, cometY3
	lw $t9, shipHeadY
	beq $t5, $t9, updateIt
	beq $t6, $t9, updateIt
	beq $t7, $t9, updateIt
	j mainLoop # jump back to the main loop because there's no collision
	
	updateIt:
	lw $t0, health # get health value (global var)
	addiu $t0, $t0, -1 # decrement health
	beq $t0, 0, gameOver
	li $t1, 0
	add $a0, $zero, $t0
	add $a1, $zero, $t1
	jal pixelAddress # calculate the pixel in health bar we want to color red
	add $a0, $v0, $zero
	lw $a1, healthBarDmg
	jal drawPixel
	j mainLoop
	
# update the game score	
updateScore:
	lw $t5, score
	addi $t5, $t5, 1
	sw $t5, score
	jr $ra # jump back to the code that called us
	
#game over screen
gameOver:
	#color whole screen black
	# write END
	# SCORE: 
	# restart - p

#function to convert coords to address of pixel
#$a0=x-coord, $a1=y-coord
#$v0 = address of (x,y) on bitmap
pixelAddress:
	lw $v0, WIDTH 	#Store screen width into $v0
	mul $v0, $v0, $a1	#y*WIDTH
	add $v0, $v0, $a0	#Y*width + x
	mul $v0, $v0, 4		#4(Y*width + x)
	add $v0, $v0, $gp	#add the adress of the bitmap display
	jr $ra			# return the memory address which is stored in $v0


#functon to draw pixel to bitmap display
#$a0 = address of pixel (x,y) where I want to draw a spefic color on
#$a1 = the color I want to draw
drawPixel:
	sw $a1, ($a0) 	#fill the coord (x,y) w/ the color stored in $a1
	jr $ra		

exit:
	li $v0, 10
	syscall