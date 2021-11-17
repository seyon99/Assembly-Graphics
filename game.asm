#####################################################################
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 4
#
# Which approved features have been implemented for milestone 4?
# (See the assignment handout for the list of additional features)
# 1. Scoring system
# 2. Smooth graphics
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - https://www.youtube.com/watch?v=mbcBvRNETDQ
#
# Are you OK with us sharing the video with people outside course staff?
# - no
#
# Any additional information that the TA needs to know:
# - I used a python script to generate the code in lines 776 - 931, and they just load a color to a specific spot on the screen
#   and these lines of code form the letters on the end screen of the game. Writing comments for these lines would be tedious so I chose not to have any.
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
	textColor:	.word 0x6FF333
	scoreColor:	.word 0xFF0F1E
	colonColor:	.word 0x0FABFF
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

# function to color the screen black prior to start of game
makeScreen:
	beq $a0, $a2, initGame
	sw $a1, 0($a0) #store background color
	addiu $a0, $a0, 4 #increment counter
	j makeScreen

# function to store the initial coordinates of the ship	
initGame:
	li $t0, 3
	sw $t0, shipHeadX
	li $t0, 15
	sw $t0, shipHeadY
	li $t0, 32
	sw $t0, health

# function to draw the purple border and the full health bar
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

# the loop that iterates while the ship has full health
mainLoop:
	jal drawComet
	jal getInput
	changeHealthBar:
	jal updateHealth
	jal mainLoop

# function to draw the three obstacles/comets in the game and have them move across the screen
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
	li $a0, 10 # Wait one second (1000 milliseconds)
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

# function to get keyboard input from the user
getInput:

	#get the input from the keyboard
	li $t9, 0xffff0000 
	lw $t8, 0($t9)
	beq $t8, 1, keypress_happened # if the user pressed a key, jump to the keypress_happened function to produce an output

# function that determines what a keypress will do
keypress_happened:
	lw $t7, 4($t9)
	#check to see which direction to draw
	beq $t7, 119, drawUp # user clicked "w" -> ship moves up
	beq  $t7, 115, drawDown # user clicked "s" -> ship moves down
	beq  $t7, 97, drawLeft # user clicked "a" -> ship moves left
	beq  $t7, 100, drawRight # user clicked "d" -> ship moves right
	beq $t7, 112, restartGame # user clicked "p" during the game -> restart the game
	#jump back to get input if an unsupported key was pressed
	j getInput

# function to redraw the ship 1 pixel up
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
	j changeHealthBar

# function to redraw the ship 1 pixel down
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
	j changeHealthBar

# function to redraw the ship 1 pixel left	
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
	j changeHealthBar

# function to redraw the ship 1 pixel right	
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
	j changeHealthBar

# function to update the health bar and integer health value
updateHealth:
	
	lw $t0, health # get health value (global var)
	addiu $t0, $t0, -1 # decrement health
	beq $t0, -1, gameOver
	li $t1, 0
	add $a0, $zero, $t0
	addi $a1, $zero, 0
	jal pixelAddress # calculate the pixel in health bar we want to color red
	add $a0, $v0, $zero
	lw $a1, healthBarDmg
	sw $t0, health
	jal drawPixel
	jal mainLoop
	
# function to update the game score	
updateScore:
	lw $t5, score
	addi $t5, $t5, 2
	sw $t5, score
	jr $ra # jump back to the code that called us

# Restart the game (this function can be called at any time during the game if the user presses p)
restartGame:
	jal main
	
#game over screen
gameOver:
	lw $a0, WIDTH
	lw $a1, backgroundColor
	mul $a2, $a0, $a0 #total number of pixels on screen
	mul $a2, $a2, 4 # align address
	add $a2, $a2, $gp #add address of the screen ($gp)
	add $a0, $gp, $zero #loop counter
	#the loop
	coverBackground:
	beq $a0, $a2, drawInfo
	sw $a1, 0($a0) #store color
	addiu $a0, $a0, 4 #increment counter
	j coverBackground
	
	lw $t6, colonColor
	lw $t7, scoreColor
	drawInfo:
	# display thw word "END" on bitmap display 
	lw $t5, textColor
	sw $t5, 140($gp)
	sw $t5, 144($gp)
	sw $t5, 148($gp)
	sw $t5, 268($gp)
	sw $t5, 396($gp)
	sw $t5, 400($gp)
	sw $t5, 404($gp)
	sw $t5, 524($gp)
	sw $t5, 652($gp)
	sw $t5, 656($gp)
	sw $t5, 660($gp)
	sw $t5, 156($gp)
	sw $t5, 160($gp)
	sw $t5, 284($gp)
	sw $t5, 292($gp)
	sw $t5, 412($gp)
	sw $t5, 420($gp)
	sw $t5, 540($gp)
	sw $t5, 548($gp)
	sw $t5, 668($gp)
	sw $t5, 676($gp)
	sw $t5, 172($gp)
	sw $t5, 176($gp)
	sw $t5, 300($gp)
	sw $t5, 308($gp)
	sw $t5, 428($gp)
	sw $t5, 436($gp)
	sw $t5, 556($gp)
	sw $t5, 564($gp)
	sw $t5, 684($gp)
	sw $t5, 688($gp)
	# display SCORE: X on bitmap display
	sw $t5, 908($gp)
	sw $t5, 912($gp) 
	sw $t5, 916($gp) 
	sw $t5, 924($gp) 
	sw $t5, 928($gp) 
	sw $t5, 932($gp) 
	sw $t5, 940($gp) 
	sw $t5, 944($gp) 
	sw $t5, 948($gp) 
	sw $t5, 956($gp) 
	sw $t5, 960($gp) 
	sw $t5, 964($gp) 
	sw $t5, 972($gp) 
	sw $t5, 976($gp) 
	sw $t5, 980($gp) 
	sw $t6, 988($gp) 
	sw $t7, 996($gp) 
	sw $t7, 1000($gp)
	sw $t7, 1008($gp)
	sw $t7, 1012($gp)
	sw $t5, 1036($gp)
	sw $t5, 1052($gp)
	sw $t5, 1068($gp)
	sw $t5, 1076($gp)
	sw $t5, 1084($gp)
	sw $t5, 1092($gp)
	sw $t5, 1100($gp)
	sw $t7, 1128($gp)
	sw $t7, 1140($gp)
	sw $t5, 1164($gp)
	sw $t5, 1168($gp)
	sw $t5, 1172($gp)
	sw $t5, 1180($gp)
	sw $t5, 1196($gp)
	sw $t5, 1204($gp)
	sw $t5, 1212($gp)
	sw $t5, 1216($gp)
	sw $t5, 1220($gp)	
	sw $t5, 1228($gp)
	sw $t5, 1232($gp)
	sw $t5, 1236($gp)
	sw $t7, 1252($gp)
	sw $t7, 1256($gp)
	sw $t7, 1268($gp)
	sw $t5, 1300($gp)
	sw $t5, 1308($gp)
	sw $t5, 1324($gp)
	sw $t5, 1332($gp)
	sw $t5, 1340($gp)
	sw $t5, 1344($gp)
	sw $t5, 1356($gp)
	sw $t7, 1384($gp)
	sw $t7, 1392($gp)
	sw $t5, 1420($gp)
	sw $t5, 1424($gp)
	sw $t5, 1428($gp)
	sw $t5, 1436($gp)
	sw $t5, 1440($gp)
	sw $t5, 1444($gp)
	sw $t5, 1452($gp)
	sw $t5, 1456($gp)
	sw $t5, 1460($gp)
	sw $t5, 1468($gp)
	sw $t5, 1476($gp)
	sw $t5, 1484($gp)
	sw $t5, 1488($gp)
	sw $t5, 1492($gp)
	sw $t6, 1500($gp)
	sw $t7, 1508($gp)
	sw $t7, 1512($gp)
	sw $t7, 1520($gp)
	sw $t7, 1524($gp)
	# Display "p - restart" on the bitmap display
	sw $t5, 1796($gp)
	sw $t5, 1800($gp)
	sw $t5, 1816($gp)
	sw $t5, 1820($gp)
	sw $t5, 1828($gp)
	sw $t5, 1832($gp)
	sw $t5, 1840($gp)
	sw $t5, 1844($gp)
	sw $t5, 1852($gp)
	sw $t5, 1856($gp)
	sw $t5, 1860($gp)
	sw $t5, 1872($gp)
	sw $t5, 1884($gp)
	sw $t5, 1888($gp)
	sw $t5, 1896($gp)
	sw $t5, 1900($gp)
	sw $t5, 1904($gp)
	sw $t5, 1924($gp)
	sw $t5, 1928($gp)
	sw $t5, 1936($gp)
	sw $t5, 1944($gp)
	sw $t5, 1956($gp)
	sw $t5, 1960($gp)
	sw $t5, 1968($gp)
	sw $t5, 1984($gp)
	sw $t5, 1996($gp)
	sw $t5, 2004($gp)
	sw $t5, 2012($gp)
	sw $t5, 2028($gp)
	sw $t5, 2052($gp)
	sw $t5, 2072($gp)
	sw $t5, 2084($gp)
	sw $t5, 2100($gp)
	sw $t5, 2112($gp)
	sw $t5, 2124($gp)
	sw $t5, 2128($gp)
	sw $t5, 2132($gp)
	sw $t5, 2140($gp)
	sw $t5, 2156($gp)
	sw $t5, 2180($gp)
	sw $t5, 2200($gp)
	sw $t5, 2212($gp)
	sw $t5, 2216($gp)
	sw $t5, 2224($gp)
	sw $t5, 2228($gp)
	sw $t5, 2240($gp)
	sw $t5, 2252($gp)
	sw $t5, 2260($gp)
	sw $t5, 2268($gp)
	sw $t5, 2284($gp)
	# get key input and jump to start of game only if p is clicked
	#li $v0, 10
	#syscall
	
	getRestartInput:
	li $t9, 0xffff0000 # check for a keypress so user can restart the game if they want
	lw $t8, 0($t9)
	beq $t8, 1, restart_keypress
	
	restart_keypress:
	lw $t2, 4($t9) 
	beq $t2, 112, doRestart
	j getRestartInput
	
	doRestart:
	jal main

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

# function to exit the program (used for testing purposes)
exit:
	li $v0, 10
	syscall
