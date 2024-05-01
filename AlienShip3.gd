extends "res://AlienShip.gd"

func child_start():
	SPEED = 5
	life = 2
	shootDelay = 2.5
	shootCDelay = shootDelay
	probGenBonus = 20
	pass

func shoot(type, speed):
	if type == 0:
		cannon_shoot(0, Vector2(-0.3, -1), 13, defaultDamage)
		cannon_shoot(0, Vector2(0.3, -1), 13, defaultDamage)
		cannon_shoot(0, Vector2(0, -1), 13, defaultDamage)
	$Shoot.play(0)
	pass
