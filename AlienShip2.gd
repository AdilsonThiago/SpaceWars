extends "res://AlienShip.gd"

var limitZ = 5.0
var ammo = 2

func child_start():
	SPEED = 2
	life = 12
	shootDelay = 5.5
	shootCDelay = shootDelay
	probGenBonus = 80
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
		if position.z > limitZ:
			vertical = -SPEED * 2
	if moving == 2 and moveDelay <= 0:
		moving = 0
	if moving == 0:
		if moveDelay <= 0:
			moveDelay = 1.5
			limitZ -= 0.3
			horizontal = 0
			if randi_range(0, 3) == 1:
				horizontal = sign(player.position.x - position.x) * SPEED
			else:
				moving = 2
				if randi_range(0, 1) == 1:
					horizontal = randi_range(-1, 1) * SPEED
	if yaligned and shootCDelay <= 0:
		if ammo > 0:
			ammo -= 1
			shootCDelay = 0.4
			shoot(0, 19)
		else:
			ammo = 2
			shootCDelay = shootDelay
	pass

func shoot(type, speed):
	if type == 0:
		cannon_shoot(0, Vector2(0, -1), speed, defaultDamage)
		cannon_shoot(1, Vector2(0, -1), speed, defaultDamage)
		
		cannon_shoot(0, Vector2(-1, -1), speed, defaultDamage)
		cannon_shoot(1, Vector2(1, -1), speed, defaultDamage)
		
		cannon_shoot(0, Vector2(-1, -0.1), speed, defaultDamage)
		cannon_shoot(1, Vector2(1, -0.1), speed, defaultDamage)
	
	$Shoot.play(0)
	pass
