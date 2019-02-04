.data
map_filename: .asciiz "map3.txt"
# num words for map: 45 = (num_rows * num_cols + 2) // 4 
# map is random garbage initially
.asciiz "Don't touch this region of memory"
map: .word 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 
.asciiz "Don't touch this"
# player struct is random garbage initially
player: .word 0x2912FECD
.asciiz "Don't touch this either"
# visited[][] bit vector will always be initialized with all zeroes
# num words for visited: 6 = (num_rows * num*cols) // 32 + 1
visited: .word 0 0 0 0 0 0 
.asciiz "Really, please don't mess with this string"

welcome_msg: .asciiz "Welcome to MipsHack! Prepare for adventure!\n"
pos_str: .asciiz "Pos=["
health_str: .asciiz "] Health=["
coins_str: .asciiz "] Coins=["
your_move_str: .asciiz " Your Move: "
you_won_str: .asciiz "Congratulations! You have defeated your enemies and escaped with great riches!\n"
you_died_str: .asciiz "You died!\n"
you_failed_str: .asciiz "You have failed in your quest!\n"

.text
print_map:
la $t0, map  # the function does not need to take arguments

addi $t0, $t0, 2
lbu $t1, ($t0)
lbu $t2, 1($t0)

li $t1, 7
li $t2, 25
li $t3, 0

mult $t1, $t2
mflo $t7 #175	
	loop:
	beq $t3, $t7, loop_end
	div $t3, $t2
	mfhi $t4
	beq $t4, 0, print_newline
	j reg
	print_newline:
	li $v0, 11
	li $a0, 10
	syscall
	reg:
	li $t5, 0
		loop2:
		beq $t5, $t2, loop2_end
		lbu $t4, ($t0)
		bgt $t4, 127, print_hidden
		j print_regular 
			print_hidden:
			li $v0, 11
			li $a0, 32
			addi $t4, $t4, -128
			move $a0, $t4
			syscall
			
			j loop2_e
			print_regular:
			li $v0, 11
			move $a0, $t4
			syscall
		loop2_e:
		
		addi $t0, $t0, 1
		addi $t3, $t3, 1
		addi $t5, $t5, 1
		j loop2
		loop2_end:
		
		j loop
	loop_end:

jr $ra

print_player_info:
# the idea: print something like "Pos=[3,14] Health=[4] Coins=[1]"
la $t0, player

li $a0, 10
li $v0, 11
syscall

la $a0, pos_str #Position
li $v0, 4
syscall

lbu $t1, ($t0) #row
lbu $t2, 1($t0)#col
lbu $t3, 2($t0)#hp
lbu $t4, 3($t0)#coin

li $v0, 1
move $a0, $t1
syscall
li $v0, 11
li $a0, 44
syscall
li $v0, 1
move $a0, $t2
syscall

la $a0, health_str
li $v0, 4
syscall

move $a0, $t3
li $v0, 1
syscall

la $a0, coins_str
li $v0, 4
syscall

move $a0, $t4
li $v0, 1
syscall


jr $ra


.globl main
main:
la $a0, welcome_msg
li $v0, 4
syscall

# fill in arguments
la $a0, map_filename
la $a1, map
la $a2, player
li $s0, 150
li $s1, 200
jal init_game

# fill in arguments

la $a0, map
li $a1, 3
li $a2, 2

jal reveal_area

jal print_map
jal print_player_info

la $a0, map
li $a1, 3
li $a2, 2
la $a3, visited
#jal flood_fill_reveal
#jal get_visited

#jal print_map
#jal print_player_info

li $s0, 0  # move = 0

game_loop:  # while player is not dead and move == 0:

jal print_map # takes no args

jal print_player_info # takes no args

#la $a0, map
#la $a1, player
#li $a2, 2
#li $a3, 2
#jal complete_attack

#jal print_map

# print prompt
la $a0, your_move_str
li $v0, 4
syscall

li $v0, 12  # read character from keyboard
syscall
move $s1, $v0  # $s1 has character entered

la $a0, map
la $a1, player
move $a2, $s1
jal player_turn

li $s0, 0  # move = 0

li $a0, '\n'
li $v0 11
syscall

# handle input: w, a, s or d
# map w, a, s, d  to  U, L, D, R and call player_turn()

# if move == 0, call reveal_area()  Otherwise, exit the loop.

j game_loop

game_over:
jal print_map
jal print_player_info
li $a0, '\n'
li $v0, 11
syscall

# choose between (1) player dead, (2) player escaped but lost, (3) player escaped and won

won:
la $a0, you_won_str
li $v0, 4
syscall
j exit

failed:
la $a0, you_failed_str
li $v0, 4
syscall
j exit

player_dead:
la $a0, you_died_str
li $v0, 4
syscall

exit:
li $v0, 10
syscall

.include "rpg.asm"
