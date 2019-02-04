# Daniel Goon
.text

# Part I
init_game:
addi $sp, $sp, -4
sw $s0, ($sp)
addi $sp, $sp, -4
sw $s1, ($sp)

move $s0, $a2
move $s1, $a1
#lw $s0, ($sp) #player pointer
#lw $s1, 4($sp)#map pointer

li $a1, 0
li $a2, 0
li $v0, 13
syscall

beq $v0, -1, init_error
move $a0, $v0
li $v0, 14
addi $sp, $sp, -4
move $a1, $sp
li $a2, 3
syscall

lbu $t1, ($sp)  #first bit
lbu $t2, 1($sp) #second
addi $sp, $sp, 4

li $t0, 10
addi $t1, $t1, -48
addi $t2, $t2, -48
mult $t0, $t1
mflo $t0
add $t0, $t0, $t2

li $v0, 14
addi $sp, $sp, -4
move $a1, $sp
li $a2, 3
syscall

lbu $t3, ($sp)  #first bit
lbu $t4, 1($sp) #second
addi $sp, $sp, 4

li $t1, 10
addi $t3, $t3, -48
addi $t4, $t4, -48
mult $t1, $t3
mflo $t1
add $t1, $t1, $t4

#t0 = 7, $t1 = 25

sb $t0, ($s1)
sb $t1, 1($s1)
addi $s1, $s1, 2

mult $t0, $t1
mflo $t7 #175

#t0 = 7, $t1 = 25
li $t2, 0
	init_loop:
	beq $t2, $t7, init_loop_end
	
	li $v0, 14
	move $a1, $s1
	li $a2, 1
	syscall
	
	lbu $t3, ($s1)#Test the new character copied
	beq $t3, 64, hero
	beq $t3, 10, new_line
	j regular
	hero:
	div $t2, $t1
	mflo $t4 #row
	mfhi $t5 #col
	
	sb $t4, ($s0)
	sb $t5, 1($s0)
	
	addi $s0, $s0, 2
	j regular
	new_line:
	
	j non_regular
	regular:
	addi $t3, $t3, 128
	sb $t3, ($s1)
	
	addi $s1, $s1, 1
	addi $t2, $t2, 1
	non_regular:
	j init_loop
	init_loop_end:
	
sub $s1, $s1, $t7
li $t6, 2
sub $s1, $s1, $t6

#lbu $t8, 79($s1)
#Still need to do player health
lbu $t0, 176($s1)
lbu $t1, 177($s1)

li $v0, 14
move $a1, $s0
li $a2, 1
syscall

lbu $t2, ($s0) #Skips the last /n

li $v0, 14
move $a1, $s0
li $a2, 1
syscall

lbu $t3, ($s0) 
addi $t3, $t3, -48

li $v0, 14
move $a1, $s0
li $a2, 1
syscall

lbu $t4, ($s0)
addi $t4, $t4, -48

li $t5, 10
mult $t3, $t5
mflo $t5
add $t5, $t5, $t4

sb $t5, ($s0)
li $t5, 0
sb $t5, 1($s0)
addi $s0, $s0, -2

li $v0, 16
syscall

li $v0, 0
init_error:

lw $s1, ($sp)
addi $sp, $sp, 4
lw $s0, ($sp)
addi $sp, $sp, 4

jr $ra


# Part II
is_valid_cell: #a0 = map_ptr, a1 = row idx, a2 = col idx
lbu $t0, ($a0) #num of rows
lbu $t1, 1($a0)#num of cols
li $v0, 0

blt $a1, 0, not_valid_cell
blt $a2, 0, not_valid_cell

bge $a1, $t0, not_valid_cell
bge $a2, $t1, not_valid_cell

jr $ra
not_valid_cell:
li $v0, -1
jr $ra


# Part III
get_cell: #map ptr, int row, int col

addi $sp, $sp, -4
sw $ra, ($sp)
jal is_valid_cell #has same args for is-valid
lw $ra, ($sp)
addi $sp, $sp, 4

beq $v0, -1, get_cell_error
lbu $t0, ($a0) #number of rows
lbu $t1, 1($a0) #number of columns

mult $t1, $a1
mflo $t2
add $t2, $t2, $a2

addi $a0, $a0, 2
add $a0, $a0, $t2
lbu $t0, ($a0)
move $v0, $t0
sub $a0, $a0, $t2
li $t0, 2
sub $a0, $a0, $t0

jr $ra
get_cell_error:
li $v0, -1
jr $ra


# Part IV
set_cell:
#a0 = map, a1 = row, a2 = col, a3 = ch
lbu $t0, ($a0) #row
lbu $t1, 1($a0)#col

addi $sp, $sp, -4
sw $ra, ($sp)
jal is_valid_cell
lw $ra, ($sp)
addi $sp, $sp, 4

beq $v0, -1, set_cell_error
mult $t1, $a1
mflo $t1
add $t1, $t1, $a2

addi $a0, $a0, 2
add $a0, $a0, $t1
sb $a3, ($a0)
sub $a0, $a0, $t1
li $t0, 2
sub $a0, $a0, $t0
li $v0, 0

jr $ra
set_cell_error:
jr $ra


# Part V
reveal_area: #a0 = map, #a1 = row, #a2 = col
addi $sp, $sp, -4
sw $s0, ($sp)
addi $sp, $sp, -4
sw $s1, ($sp)
addi $sp, $sp, -4
sw $s2, ($sp)
addi $sp, $sp, -4
sw $s3, ($sp)
addi $sp, $sp, -4
sw $s4, ($sp)


move $s0, $a0
lbu $s1, ($a0) #row = 7
lbu $s2, 1($a0)#col = 25

addi $a1, $a1, -1
addi $a2, $a2, -1
li $s3, 0
li $s4, 0
	reveal_loop:
	beq $s3, 3, reveal_end
	li $s4, 0
		inner_reveal:
		beq $s4, 3, inner_reveal_end
		addi $sp, $sp, -4
		sw $ra, ($sp)
		jal is_valid_cell
		lw $ra, ($sp)
		addi $sp, $sp, 4
		
		beq $v0, -1, skip_invalid_cell
		j valid_cell
		skip_invalid_cell:
		
		j skip
		valid_cell:
		addi $sp, $sp, -4
		sw $ra, ($sp)
		jal get_cell
		lw $ra, ($sp)
		addi $sp, $sp, 4
		
		move $a3, $v0 #holds cell content
		bge $a3, 128, reveal_cell
		j not_needed
			reveal_cell:
			addi $a3, $a3, -128
			
			addi $sp, $sp, -4
			sw $ra, ($sp)
			jal set_cell
			lw $ra, ($sp)
			addi $sp, $sp, 4
			
			not_needed:
		
		skip:
		addi $a2, $a2, 1
		addi $s4, $s4, 1
		j inner_reveal
		inner_reveal_end:
		
		addi $a1, $a1, 1 #increase row
		addi $a2, $a2, -3#col goes back to 1st
		addi $s3, $s3, 1
		j reveal_loop
	reveal_end:
	

lw $s4, ($sp)
addi $sp, $sp, 4
lw $s3, ($sp)
addi $sp, $sp, 4
lw $s2, ($sp)
addi $sp, $sp, 4
lw $s1, ($sp)
addi $sp, $sp, 4
lw $s0, ($sp)
addi $sp, $sp, 4

jr $ra

# Part VI
get_attack_target: #a0 = map, a1 = player, a2 = char direction
#U = up, D = down, L = left, R = right
addi $sp, $sp, -4
sw $s0, ($sp)
addi $sp, $sp, -4
sw $s1, ($sp)

move $s0, $a1 #s0 = player

lbu $t0, ($s0) #row
lbu $t1, 1($s0)#col

beq $a2, 85, get_up
beq $a2, 68, get_down
beq $a2, 76, get_left
beq $a2, 82, get_right
j not_valid_attack
	get_up:
	addi $t0, $t0, -1
	blt $t0, 0, not_valid_attack
	
	move $a1, $t0
	move $a2, $t1
	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal get_cell
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	j check_enemy
	
	get_down:
	addi $t0, $t0, 1
	lbu $t2, ($a0)
	bge $t0, $t2, not_valid_attack #fix
	
	move $a1, $t0
	move $a2, $t1
	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal get_cell
	lw $ra, ($sp)
	addi $sp, $sp, 4
	j check_enemy
	
	get_left:
	addi $t1, $t1, -1
	blt $t1, 0, not_valid_attack
	
	move $a1, $t0
	move $a2, $t1
	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal get_cell
	lw $ra, ($sp)
	addi $sp, $sp, 4
	j check_enemy
	
	get_right:
	addi $t1, $t1, 1
	lbu $t2, 1($a0)
	bge $t0, $t2, not_valid_attack #fix
	
	move $a1, $t0
	move $a2, $t1
	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal get_cell
	lw $ra, ($sp)
	addi $sp, $sp, 4
	j check_enemy
check_enemy: #B = 66, m = 109, / = 47
beq $v0, 66, valid_target
beq $v0, 47, valid_target
beq $v0, 109, valid_target

j not_valid_attack
valid_target:

lw $s1, ($sp)
addi $sp, $sp, 4
lw $s0, ($sp)
addi $sp, $sp, 4
jr $ra

not_valid_attack:
li $v0, -1

lw $s1, ($sp)
addi $sp, $sp, 4
lw $s0, ($sp)
addi $sp, $sp, 4

jr $ra


# Part VII
complete_attack: #a0 =map, a1 = player, a2 = target row, a3 = target col
addi $sp, $sp, -4
sw $s0, ($sp)

move $s0, $a1 #player

move $a1, $a2
move $a2, $a3

addi $sp, $sp, -4
sw $ra, ($sp)
jal get_cell #gets minion or boss
lw $ra, ($sp)
addi $sp, $sp, 4

move $t0, $v0

beq $t0, 'B', attack_boss
beq $t0, '/', attack_door
attack_minion:
li $a3, '$'

addi $sp, $sp, -4
sw $ra, ($sp)
jal set_cell
lw $ra ($sp)
addi $sp, $sp, 4

lb $t0, 2($s0) #health
addi $t0, $t0, -1
sb $t0, 2($s0)
blez $t0, dead_player

j attack_done
attack_door:
li $a3, '.'

addi $sp, $sp, -4
sw $ra, ($sp)
jal set_cell
lw $ra ($sp)
addi $sp, $sp, 4

j attack_done
attack_boss:
li $a3, '*'

addi $sp, $sp, -4
sw $ra, ($sp)
jal set_cell
lw $ra ($sp)
addi $sp, $sp, 4

lb $t0, 2($s0) #health
addi $t0, $t0, -2
sb $t0, 2($s0)
blez $t0, dead_player
j attack_done
dead_player:
lbu $a1, ($s0)
lbu $a2, 1($s0)

li $a3, 'X'

addi $sp, $sp, -4
sw $ra, ($sp)
jal set_cell
lw $ra ($sp)
addi $sp, $sp, 4


attack_done:
lw $s0, ($sp)
addi $sp, $sp, 4
jr $ra


# Part VIII
monster_attacks: #a0 = map, a1 = player check for -1
addi $sp, $sp, -4
sw $s0, ($sp)
addi $sp, $sp, -4
sw $s1, ($sp)

move $s0, $a1 #player
lbu $a1, ($s0) #row
lbu $a2, 1($s0)#col

addi $a1, $a1, -1 #top

addi $sp, $sp, -4
sw $ra, ($sp)
jal get_cell
lw $ra ($sp)
addi $sp, $sp, 4
li $s1, 0

beq $v0, 'B', boss_top
beq $v0, 'm', minion_top
j top_done
boss_top:
addi $s1, $s1, 2
j top_done
minion_top:
addi $s1, $s1, 1
j top_done
top_done:

addi $a1, $a1, 2 #down

addi $sp, $sp, -4
sw $ra, ($sp)
jal get_cell
lw $ra ($sp)
addi $sp, $sp, 4

beq $v0, 'B', boss_down
beq $v0, 'm', minion_down
j down_done
boss_down:
addi $s1, $s1, 2
j down_done
minion_down:
addi $s1, $s1, 1
j down_done
down_done:

addi $a2, $a2, -1
addi $a1, $a1, -1 #left

addi $sp, $sp, -4
sw $ra, ($sp)
jal get_cell
lw $ra ($sp)
addi $sp, $sp, 4

beq $v0, 'B', boss_left
beq $v0, 'm', minion_left
j left_done
boss_left:
addi $s1, $s1, 2
j left_done
minion_left:
addi $s1, $s1, 1
j left_done
left_done:

addi $a2, $a2, 2 #right

addi $sp, $sp, -4
sw $ra, ($sp)
jal get_cell
lw $ra ($sp)
addi $sp, $sp, 4

beq $v0, 'B', boss_right
beq $v0, 'm', minion_right
j right_done
boss_right:
addi $s1, $s1, 2
j right_done
minion_right:
addi $s1, $s1, 1
j right_done
right_done:

move $v0, $s1

lw $s1, ($sp)
addi $sp, $sp, 4
lw $s0, ($sp)
addi $sp, $sp, 4
jr $ra
# Part IX
player_move:
#a0 = map, a1 = player, a2 = target row, a3 = target column
addi $sp, $sp, -4
sw $s0, ($sp)
addi $sp, $sp, -4
sw $s1, ($sp)
addi $sp, $sp, -4
sw $s2, ($sp)
addi $sp, $sp, -4
sw $s3, ($sp)

move $s0, $a1 #player
move $s1, $a2 #row
move $s2, $a3 #column

addi $sp, $sp, -4
sw $ra, ($sp)
jal monster_attacks
lw $ra, ($sp)
addi $sp, $sp, 4

lb $t0, 2($s0)
sub $t0, $t0, $v0
sb $t0, 2($s0)

blez $t0, player_died

move $a1, $s1
move $a2, $s2

addi $sp, $sp, -4
sw $ra, ($sp)
jal get_cell
lw $ra, ($sp)
addi $sp, $sp, 4

li $a3, '@'
move $s3, $v0

addi $sp, $sp, -4
sw $ra, ($sp)
jal set_cell
lw $ra, ($sp)
addi $sp, $sp, 4

li $a3, '.'
lbu $a1, ($s0)
lbu $a2, 1($s0)


addi $sp, $sp, -4
sw $ra, ($sp)
jal set_cell
lw $ra, ($sp)
addi $sp, $sp, 4

sb $s1, ($s0)
sb $s2, 1($s0)

beq $s3, '.', move_empty
beq $s3, '$', move_coin
beq $s3, '*', move_gem
beq $s3, '>', move_exit
move_empty:
li $v0, 0
j player_move_done

move_coin:
lbu $t0, 3($s0)
addi $t0, $t0, 1
sb $t0, 3($s0)
li $v0, 0
j player_move_done

move_gem:
lbu $t0, 3($s0)
addi $t0, $t0, 5
sb $t0, 3($s0)
li $v0, 0
j player_move_done

move_exit:
li $v0, -1
j player_move_done

player_died:
lbu $t0, ($s0)
lbu $t1, 1($s0)

move $a1, $t0
move $a2, $t1
li $a3, 'X'

addi $sp, $sp, -4
sw $ra, ($sp)
jal set_cell
lw $ra, ($sp)
addi $sp, $sp, 4

player_move_done:
lw $s3, ($sp)
addi $sp, $sp, 4
lw $s2, ($sp)
addi $sp, $sp, 4
lw $s1, ($sp)
addi $sp, $sp, 4
lw $s0, ($sp)
addi $sp, $sp, 4
jr $ra

# Part X
player_turn:
#a0 = map, a1 = player, a2 = direction (Character)
addi $sp, $sp, -4
sw $s0, ($sp)
addi $sp, $sp, -4
sw $s1, ($sp)
addi $sp, $sp, -4
sw $s2, ($sp)
addi $sp, $sp, -4
sw $s3, ($sp)


move $s0, $a1
lbu $t0, ($a1)
lbu $t1, 1($a1)
move $s1, $a2

beq $a2, 'U', up_direction
beq $a2, 'w', up_direction
beq $a2, 'D', down_direction
beq $a2, 's', down_direction
beq $a2, 'L', left_direction
beq $a2, 'a', left_direction
beq $a2, 'R', right_direction
beq $a2, 'd', right_direction

j player_error
up_direction:
addi $t0, $t0, -1
j got_target
down_direction:
addi $t0, $t0, 1
j got_target
left_direction:
addi $t1, $t1, -1
j got_target
right_direction:
addi $t1, $t1, 1
j got_target
got_target:
move $a1, $t0
move $a2, $t1

move $s2, $t0
move $s3, $t1

addi $sp, $sp, -4
sw $ra, ($sp)
jal is_valid_cell
lw $ra, ($sp)
addi $sp, $sp, 4

beq $v0, -1, return_zero_index

addi $sp, $sp, -4
sw $ra, ($sp)
jal get_cell
lw $ra, ($sp)
addi $sp, $sp, 4

beq $v0, '#', return_zero_index
move $a1, $s0
move $a2, $s1

addi $sp, $sp, -4
sw $ra, ($sp)
jal get_attack_target
lw $ra, ($sp)
addi $sp, $sp, 4

beq $v0, -1, player_moving

move $a1, $s0
move $a2, $s2
move $a3, $s3

addi $sp, $sp, -4
sw $ra, ($sp)
jal complete_attack
lw $ra, ($sp)
addi $sp, $sp, 4

j return_zero_index

player_moving:
move $a1, $s0
move $a2, $s2
move $a3, $s3

addi $sp, $sp, -4
sw $ra, ($sp)
jal player_move
lw $ra, ($sp)
addi $sp, $sp, 4


lw $s3, ($sp)
addi $sp, $sp, 4
lw $s2, ($sp)
addi $sp, $sp, 4
lw $s1, ($sp)
addi $sp, $sp, 4
lw $s0, ($sp)
addi $sp, $sp, 4
jr $ra

return_zero_index:
li $v0, 0
lw $s3, ($sp)
addi $sp, $sp, 4
lw $s2, ($sp)
addi $sp, $sp, 4
lw $s1, ($sp)
addi $sp, $sp, 4
lw $s0, ($sp)
addi $sp, $sp, 4
jr $ra
player_error:

li $v0, -1
lw $s3, ($sp)
addi $sp, $sp, 4
lw $s2, ($sp)
addi $sp, $sp, 4
lw $s1, ($sp)
addi $sp, $sp, 4
lw $s0, ($sp)
addi $sp, $sp, 4
jr $ra

# Part XI
flood_fill_reveal: #a0 = map, a1= row, a2 = col, a3 = bit visited
addi $sp, $sp, -4
sw $s0, ($sp)
addi $sp, $sp, -4
sw $s1, ($sp)

move $s1, $a3 #s1 = bit

blt $a1, 0, return_neg
blt $a2, 0, return_neg

lbu $t0, ($a0) #max row
lbu $t1, 1($a0)#max column
bge $a1, $t0, return_neg
bge $a2, $t0, return_neg

move $fp, $sp
addi $sp, $sp, -4
sw $a1, ($sp) #row
addi $sp, $sp, -4
sw $a2, ($sp) #column

#jal change_visited
flood_fill_loop:
	beq $sp, $fp, flood_fill_stop
	lw $a2, ($sp)
	addi $sp, $sp, 4
	lw $a1, ($sp)
	addi $sp, $sp, 4
	#a0 = map, a1 = row, a2 = col
	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal get_cell
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	bgt $v0, 127, reveal
	j check_surrounding 
	reveal: #reveals at (row, col)
	move $a3, $v0
	addi $a3, $a3, -128
	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal set_cell
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	move $a3, $s1
	
	check_surrounding:
	#a1 = row, a2 = col
	addi $a1, $a1, -1#up
	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal get_cell
	lw $ra, ($sp)
	addi $sp, $sp, 4
	#returns v0, should equal 174 or 46
	
	beq $v0, 174, floor_up 
	beq $v0, 46, floor_up
	j to_down
	
	floor_up:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal get_cell #a0 = map, a1 = row, a2 = col
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	#check_visit
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal get_visited #a0 = map, a1 = row, a2 = col, a3 = visit
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	beq $v0, 0, up_not
	j to_down
	
	up_not:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal change_visited
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	addi $sp, $sp, -4
	sw $a1, ($sp)
	addi $sp, $sp, -4
	sw $a2, ($sp)
	
	to_down:
	
	to_done:
	j flood_d
	flood_d:
	
	j flood_fill_loop
flood_fill_stop:

lw $s1, ($sp)
addi $sp, $sp, 4
lw $s0, ($sp)
addi $sp, $sp, 4
jr $ra
return_neg:
li $v0, -1
jr $ra

get_visited:#a0 = map, a1 = row, a2 = col, a3 = visit
addi $sp, $sp, -4
sw $s0, ($sp)

move $s0, $a3

lbu $t0, 1($a0)#25

mult $a1, $t0#1*25
mflo $t0 

add $t0, $t0, $a2 #25 + col = 27 

li $t1, 8
div $t0, $t1 #division 27/8. 3 remainder 3
mflo $t0 #quotient = 3
mfhi $t2 #remainder = 3

add $s0, $s0, $t0
lbu $t0, ($s0) #the 90

li $t3, 0
addi $t1, $t1, -1
sub $t3, $t1, $t2 #7-3=4
srlv $t4, $t0, $t3 #
andi $t4, $t4, 1 #sees if visited or not

move $v0, $t4

jr $ra
change_visited: #a0 = map, a1 = visited bit, a2= row, a3 = col previous
		#a0 = map, a1 = row , a2= col, a3 = visited changed
addi $sp, $sp, -4
sw $s0, ($sp)

move $s0, $a3

lbu $t0, 1($a0)#25

mult $a1, $t0#1*25
mflo $t0 

add $t0, $t0, $a2 #25 + col = 27 

li $t1, 8
div $t0, $t1 #division 27/8. 3 remainder 3
mflo $t0 #quotient = 3
mfhi $t2 #remainder = 3

add $s0, $s0, $t0
lbu $t0, ($s0) #the 90

li $t3, 0
addi $t1, $t1, -1
sub $t3, $t1, $t2 #7-3=4
srlv $t4, $t0, $t3 #
andi $t4, $t4, 1 #sees if visited or not

move $v0, $t4
beqz $t4, not_visited #tests to see if 0

j visit_done
not_visited:
li $t4, 1
sllv $t4, $t4, $t3
xor $t4, $t4, $t0 #122

sb $t4, ($s0)
visit_done:

lw $s0, ($sp)
addi $sp, $sp, 4
jr $ra
