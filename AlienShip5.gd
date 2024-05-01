extends "res://AlienShip.gd"

var limitZ = 9.0
var ammo = 2

func child_start():
	SPEED = 2.5
	life = 15.0
	shootDelay = 1.75
	shootCDelay = shootDelay
	probGenBonus = 80
	bullet = load("res://Bolt.tscn")
	pass

func child_process(delta):
	#normal alien ship process movement
	#reset axys movement
	vertical = 0
	verticaly = 0
	
	#the normal alien ship can spawn front or back player.
	#if spawn front, they move back. if spawn back, they move to front
	if moving == 1:
		horizontal = playerXRelative * SPEED
		if position.z < limitZ:
			vertical = SPEED * 2
		else:
			moving = 0
	else:
		if position.z < limitZ + 0.5 and position.z > limitZ - 0.5:
			vertical = 0
		elif position.z > limitZ:
			vertical = -SPEED * 2
		elif position.z < limitZ:
			vertical = SPEED * 2
	if moving == 2 and moveDelay <= 0:
		moving = 0
	if moving == 0:
		if moveDelay <= 0:
			moveDelay = 2.0
			limitZ -= 0.1
			horizontal = 0
			if randi_range(0, 4) == 1:
				horizontal = sign(player.position.x - position.x) * SPEED
			else:
				moving = 2
				if randi_range(0, 4) == 1:
					horizontal = randi_range(-1, 1) * SPEED
	if yaligned and shootCDelay <= 0:
		if ammo > 0:
			ammo -= 1
			shootCDelay = 1.0
			shoot(0, 12)
		else:
			ammo = 2
			shootCDelay = shootDelay
	pass

func shoot(type, speed):
	if type == 0:
		cannon_shoot(0, Vector2(- (player.position.x - position.x), player.position.z - position.z), speed, defaultDamage)
	$Shoot.play(0)
	pass
