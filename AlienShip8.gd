extends "res://AlienShip.gd"

var limitZ = 5.0
var ammo = 3.0
var shoottype = randi_range(0, 1)

func child_start():
	SPEED = 2.0
	life = 60
	shootDelay = 4.0
	shootCDelay = shootDelay
	probGenBonus = 100
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
			vertical = -SPEED
		elif position.z < limitZ:
			vertical = SPEED
	if moving == 2 and moveDelay <= 0:
		moving = 0
	if moving == 0:
		if moveDelay <= 0:
			moveDelay = 1.5
			horizontal = 0
			if randi_range(0, 3) == 1:
				horizontal = sign(player.position.x - position.x) * SPEED
			else:
				moving = 2
				if randi_range(0, 4) == 1:
					horizontal = randi_range(-1, 1) * SPEED
	if yaligned and shootCDelay <= 0:
		if ammo > 0:
			ammo -= 1
			shootCDelay = 0.3
			shoot(shoottype, 6)
		else:
			ammo = 3
			shoottype = randi_range(0, 1)
			shootCDelay = shootDelay + randf_range(- 0.5, 0.5)
	pass

func shoot(type, speed):
	var shootGoal = Vector2(player.position.z - position.z, - (player.position.x - position.x))
	var angleGoal = Vector2.ZERO.angle_to_point(shootGoal)
	var finalAngle = angleGoal
	var addang = deg_to_rad(10)
	if type == 0:
		cannon_shoot(0, Vector2(sin(finalAngle), cos(finalAngle)), speed, defaultDamage)
		cannon_shoot(1, Vector2(sin(finalAngle), cos(finalAngle)), speed, defaultDamage)
	if type == 1:
		if Game.testProb(50):
			finalAngle = angleGoal + addang
		else:
			finalAngle = angleGoal - addang
		cannon_shoot(0, Vector2(sin(finalAngle), cos(finalAngle)), speed, defaultDamage)
		cannon_shoot(1, Vector2(sin(finalAngle), cos(finalAngle)), speed, defaultDamage)
	$Shoot.play(0)
	pass
