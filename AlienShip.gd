extends CharacterBody3D

#defining variables
@export var autoyalign : bool = true
@export var limitX : bool = true

#defining more variables
var SPEED = 3.0
var bullet
var bullet2
var rotationAmont = 0.0
var player = null
var shootDelay = 1.5
var shootCDelay = shootDelay
var defaultDamage = 1
var life = 1
var explosion = null
var moving = 0
var moveDelay = 0

#axys movement vars
var previouspos = position
var horizontal = 0
var vertical = 0
var verticaly = 0
var frontPlayerAligned = false
var yaligned = false
var playerXRelative = 0

#some variavels
var killed = false
var probGenBonus = 12

func start(player, commingtype):
	#loading scenes to instantiate
	bullet = load("res://Bullet.tscn")
	bullet2 = load("res://Targeted-Bullet.tscn")
	explosion = load("res://Explosion.tscn")
	#getting some information
	self.player = player
	moving = commingtype
	#registering the object in the list.
	Game.registerSpcShip(self)
	#starting childs with your owns configurations
	child_start()
	pass

func child_start():
	#only executed on childs of this class
	pass

func child_process(delta):
	#normal alien ship process movement
	#reset axys movement
	vertical = 0
	verticaly = 0
	
	#the variable "moving" is related to your current movement.
	#1, for example, is the state in which I force the ship to go forward, as it means that the ship has just been created behind the player
	#you can see te variable "shoottype" in children classes too. its related to tipe of attack to execute
	
	#aligning to player position.x
	if not moving == 2:
		horizontal = playerXRelative * SPEED
	
	#the normal alien ship can spawn front or back player.
	#if spawn front, they move back. if spawn back, they move to front
	if moving == 1:
		if position.z < 10:
			vertical = SPEED * 2
		else:
			moving = 0
	else:
		vertical = -1
	#motion processing. follow? to stop? walk randomly?
	if moving == 2 and moveDelay <= 0:
		moving = 0
	if moving == 0:
		if moveDelay <= 0:
			moveDelay = 0.4
			if randi_range(0, 3) <= 1:
				horizontal = playerXRelative * SPEED
			else:
				moveDelay = 0.8
				moving = 2
				horizontal = randi_range(-1, 1) * SPEED
	
	#calling the fire event, resetting the count
	if shootCDelay <= 0:
		shootCDelay = shootDelay
		shoot(0, 10)
	pass

func _physics_process(delta):
	#ship really moved?
	var shipMovedX = (abs(position.x - previouspos.x) / delta) > 0.5
	#ship aligned to the player?
	yaligned = abs(position.y) < 0.1
	frontPlayerAligned = (abs(player.position.x - position.x) / delta) < 0.5
	#storing whether the player is forward, left or right
	if frontPlayerAligned:
		playerXRelative = 0
	else:
		playerXRelative = sign(player.position.x - position.x)
	
	#player was hit?
	if player.is_imune():
		#if player was hit, stop movemente
		horizontal = 0
		vertical = 0
	else:
		#player not hited then call "child_process
		child_process(delta)
		#auto delay count
		if shootCDelay > 0:
			shootCDelay -= delta
		if moveDelay > 0:
			moveDelay -= delta
	
	#ship movement, part used by all enemy ships
	#auto position.y aligment
	if autoyalign and not yaligned:
		var zdist = position.y
		verticaly = -sign(zdist) * (zdist * 1.5)
		verticaly += -sign(zdist) * 0.6
		if zdist < 0:
			verticaly = 1
	
	#ship process rotation
	if horizontal < 0 and shipMovedX:
		if rotationAmont < deg_to_rad(35):
			rotationAmont += delta * 5
		else:
			rotationAmont = deg_to_rad(40)
	elif horizontal > 0 and shipMovedX:
		if rotationAmont > deg_to_rad(-35):
			rotationAmont -= delta * 5
		else:
			rotationAmont = deg_to_rad(-40)
	if rotationAmont > 0:
		rotationAmont -= delta * 3
	if rotationAmont < 0:
		rotationAmont += delta * 3
	
	previouspos = position
	
	#ship application rotation and movement
	if limitX and (position.x < Game.limitx - 7 or position.x > Game.limitx + 7):
		if position.x < Game.limitx - 7:
			horizontal =  8
		elif position.x > Game.limitx + 7:
			horizontal = -8
	$Ship.rotation.z = rotationAmont
	velocity = Vector3(horizontal, verticaly, vertical)
	move_and_slide()
	
	#if outside limits, kill. your processor will thank you
	if position.x < Game.limitx - 20 or position.x > Game.limitx + 20:
		damage(Game.INFINITE)
	elif position.z < - 20 or position.z > 20:
		damage(Game.INFINITE)
	pass

func shoot(type, speed):
	if type == 0:
		cannon_shoot(0, Vector2(0, -1), speed, defaultDamage)
		cannon_shoot(1, Vector2(0, -1), speed, defaultDamage)
	#playng audio and shooting two projectiles
	$Shoot.play(0)
	pass

func cannon_shoot(idcannon, dir, spd, dmg, projectile = Game.BULLET):
	var obj = null
	#instancing projectile
	if projectile == Game.BULLET:
		obj = bullet.instantiate()
	elif projectile == Game.TARGETED:
		obj = bullet2.instantiate()
	get_parent().add_child(obj)
	#cannon id 0 is left, 1 is right
	#applying position and movement
	if idcannon == 0:
		obj.position = $Shooter1.global_position
	elif idcannon == 1:
		obj.position = $Shooter2.global_position
	elif idcannon == 2:
		#some ships have more than 2 nodes called "Shooter"
		obj.position = $Shooter3.global_position
	elif idcannon == 3:
		obj.position = $Shooter4.global_position
	if projectile == Game.TARGETED:
		obj.shoot(dir, spd, dmg, player)
	else:
		obj.shoot(dir, spd, dmg)
	pass

func kill():
	#generating a random bonus item to player
	if Game.testProb(probGenBonus):
		var randItem = randi_range(0, 3)
		if randItem == 0:
			Game.inGameScript.spawnBonus(position, Game.POWERUP)
		elif randItem == 1:
			Game.inGameScript.spawnBonus(position, Game.LIFE)
		elif randItem == 2:
			Game.inGameScript.spawnBonus(position, Game.SPECIAL)
		elif randItem == 3:
			Game.inGameScript.spawnBonus(position, Game.SHIELD)
	pass

func damage(dmg):
	#reducing life, giving points to player
	life -= dmg
	Game.scored(25)
	#this enemy no have more life?
	if life <= 0 and not killed:
		#creating a explosion effect
		var obj = explosion.instantiate()
		get_parent().add_child(obj)
		obj.position = position
		#removing the object of register
		Game.removeSpcShip(self)
		kill()
		killed = true
		#deleting and giving more points
		queue_free()
		Game.scored(25)
	pass
