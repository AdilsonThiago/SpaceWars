extends CharacterBody3D

@export var SPEED : float = 7.5
@export var defaultShootDelay : float = 0.4
@export var defaultDamage : float = 1.0
@export var shipID : int = 1
var bullet
var bullet2
var power
var power2
var explosion
var pkdShield
var shootDelay = defaultShootDelay
var shootCDelay = 0
var shootCDelay2 = 0
var mdamage = defaultDamage
var rotationAmont = 0.0
var powerUpLevel = 0
var life = 3
var superPowers = 3
var imune = 0
var shieldNode = null

@export var camPath : NodePath
var cam = null

func _ready():
	bullet = load("res://blueBullet.tscn")
	bullet2 = load("res://Targeted-Bullet.tscn")
	#this is special scenes used by itens or special powers
	power = load("res://xray.tscn")
	power2 = load("res://shieldBolt.tscn")
	explosion = load("res://Explosion.tscn")
	pkdShield = load("res://shield.tscn")
	Game.player = self
	
	shootDelay = defaultShootDelay
	mdamage = defaultDamage
	#powerUp(false, 4)
	pass

func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
	#transforming into a motion vector (vector 3)
	var direction = (transform.basis * Vector3(-input_dir.x, 0, input_dir.y)).normalized()
	#a directional button is pressed?
	if direction:
		#the player can move freely on the x-axis. on the z axis it has a limitation of between 0 and -10
		#the limitation of creation and movement of ship enemys is is made by our "game" singleton.
		#the metodh "Game.setLimitx" is right bellow and is responsible
		if direction.x < 0:
			velocity.x = direction.x * SPEED
			if rotationAmont < deg_to_rad(35):
				rotationAmont += delta * 5
			else:
				rotationAmont = deg_to_rad(40)
		elif direction.x > 0:
			velocity.x = direction.x * SPEED
			if rotationAmont > deg_to_rad(-35):
				rotationAmont -= delta * 5
			else:
				rotationAmont = deg_to_rad(-40)
		else:
			velocity.x = 0
		if direction.z > 0 and position.z < 0:
			velocity.z = direction.z * SPEED
		elif direction.z < 0 and position.z > -10:
			velocity.z = direction.z * SPEED
		else:
			velocity.z = 0
	else:
		velocity = Vector3(0, 0, 0)
	#rotation returns to normal
	if rotationAmont > 0:
		rotationAmont -= delta * 3
	if rotationAmont < 0:
		rotationAmont += delta * 3
	
	if is_imune():
		#if player is imune, no movement is allowed.
		velocity.x = 0
		imune -= delta
		#if the position is less than 10, it means that the ship was hit (see the end of the damage method) so we automatically return it to position
		if position.z < -10:
			velocity.z = 5
	#applying rotation and movement to ship
	$Ship.rotation.z = rotationAmont
	if move_and_slide():
		var obj = get_last_slide_collision().get_collider()
		damage(1)
		if obj.is_in_group("enemy"):
			obj.damage(5.0)
	#The player's movement on the x-axis is unlimited, so we need the creation and movement of enemy ships to be controlled.
	#here we send the player's current position to our singleton
	Game.setLimitx(position.x)
	Game.camera.position.x += (position.x - Game.camera.position.x) * delta * 5
	
	#auto count
	if shootCDelay > 0:
		shootCDelay -= delta
	if shootCDelay2 > 0:
		shootCDelay2 -= delta
	pass

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	if not is_imune():
		#when player is in imune status, the ship wont can do anything
		if event.is_action_pressed("ui_select") and shootCDelay <= 0:
			shootCDelay = shootDelay
			shoot(50)
		if event.is_action_pressed("ui_special"):
			special()
	pass

func shield():
	#if dont have shield
	if shieldNode == null:
		#then create it and put it as a child
		shieldNode = pkdShield.instantiate()
		add_child(shieldNode)
		Game.scored(150)
	else:
		#the player have shield. then just give a bonus score
		Game.scored(300)
	$Up.play()
	pass

func powerUp(relative = true, value = 1):
	#level up cannos. can see the var superPowers used in "shoot" method
	#the method can called relative and not relative.
	if relative:
		#if relative, we will add or subtract value
		powerUpLevel += value
		#and if we will add, why not give a score too?
		if value > 0:
			Game.scored(200 * value)
			$Up.play()
	else:
		#if not relative, the power level takes on new value
		powerUpLevel = value
	
	if powerUpLevel >= 6:
		#the power cant be more than 6
		powerUpLevel = 6
	elif powerUpLevel <= 0:
		#the power cant be less than 0
		powerUpLevel = 0
	
	#the level of the cannon will affect the damage and delay
	mdamage = defaultDamage + 0.2 * powerUpLevel
	shootDelay = defaultShootDelay - 0.07 * powerUpLevel
	pass

func lifeUp():
	life += 1
	if life > 3:
		#no more 3 lifes... but why not give a special 2x score
		life = 3
		Game.scored(300)
	else:
		Game.scored(150)
	$Up.play()
	Game.interface.updateLifes(life)
	pass

func specialUp():
	superPowers += 1
	if superPowers > 3:
		#no more 3 powers... but why not give a special 2x score
		superPowers = 3
		Game.scored(300)
	else:
		Game.scored(150)
	$Up.play()
	Game.interface.updatePowers(superPowers)
	pass

func special():
	#if special button is pressed and have super powers, we need to do the special power
	if superPowers > 0:
		#...acorddling the player id, the player we choosen
		if shipID == Game.FALCON:
			var obj = power.instantiate()
			add_child(obj)
			obj.start(self)
		elif shipID == Game.ICECREAM:
			Game.globalDamage(20)
			Game.interface.displayFlash()
			imune = 0.5
		elif shipID == Game.DEMONSHIP:
			var obj = power2.instantiate()
			add_child(obj)
			obj.start(self)
		superPowers -= 1
		#all damage and other effects is executed by accordling script of scene of special power created
		#updating the interface
		Game.interface.updatePowers(superPowers)
	pass

func shoot(speed):
	#calling the method cannon_shoot
	cannon_shoot(0, Vector2(0, 1), speed)
	cannon_shoot(1, Vector2(0, 1), speed)
	
	#if the power of the cannons is greater than 0, then we add projectiles
	if powerUpLevel >= 1:
		cannon_shoot(0, Vector2(-0.1, 1), speed)
		cannon_shoot(1, Vector2(0.1, 1), speed)
	
	#...and more
	if powerUpLevel >= 2:
		cannon_shoot(0, Vector2(0.1, 1), speed)
		cannon_shoot(1, Vector2(-0.1, 1), speed)
	
	#...and diferent types of projetiles
	if powerUpLevel >= 3 and shootCDelay2 <= 0:
		cannon_shoot(0, Vector2(0, 1), 17, Game.TARGETED)
		shootCDelay2 = 0.5
		#...and why not more of then?
		if powerUpLevel >= 4:
			cannon_shoot(1, Vector2(0, 1), 17, Game.TARGETED)
	
	$Shoot.play(0)
	pass

func cannon_shoot(idcannon, dir, spd, projectile = Game.BULLET):
	#instancing the bullets according to projectile id
	var obj = null
	if projectile == Game.BULLET:
		obj = bullet.instantiate()
	elif projectile == Game.TARGETED:
		obj = bullet2.instantiate()
	get_parent().add_child(obj)
	#cannon id 0 is left, 1 is right
	if idcannon == 0:
		obj.position = $Shooter1.global_position
	elif idcannon == 1:
		obj.position = $Shooter2.global_position
	if projectile == Game.TARGETED:
		obj.shoot(dir, spd, mdamage, null)
	else:
		obj.shoot(dir, spd, mdamage)
	pass

func is_imune():
	return imune > 0
	pass

func damage(dmg):
	if not is_imune():
		#if shield exists, just remove it and skip so that no damage is caused
		if not shieldNode == null:
			shieldNode.queue_free()
			shieldNode = null
			imune = 0.5
		else:
			#dont have shield then reduce life
			life -= dmg
			#update UI script
			Game.interface.updateLifes(life)
			if life <= 0:
				#call game over in UI script
				Game.interface.gameOver()
			else:
				#the player hare more lives. create an effect of explosion on current location
				var obj = explosion.instantiate()
				get_parent().add_child(obj)
				obj.position = position
				#apply imunity
				imune = 2.0
				#If the player already has his shot at level 2 or higher, save him punishment by just reducing it to level 1.
				#Otherwise, level 0 again
				if powerUpLevel >= 2:
					powerUp(false, 1)
				else:
					powerUp(false, 0)
				#when life is subtracted, the special powers return and the interface is updated
				superPowers = 3
				Game.interface.updatePowers(superPowers)
				
				#the player comes with new life outside cam, z -20
				#no deletions or removals are made to the player.
				#If there is a game over, the UI script is responsible for the effects
				position.z = -20
	pass
