extends Area3D

@export var itemid : int = 0
var dirx = 1
var diry = 1
var speed = 5
var lifeTime = 9.0

func start(bonus):
	itemid = bonus
	#random move vars
	if randi_range(0, 2) == 1:
		dirx = -1
	if randi_range(0, 2) == 1:
		diry = -1
	#setting image according to bonus id
	#note: this object is only created and this method is only called by "Stage" scrpt
	if itemid == Game.LIFE:
		$Sprite3D.frame = 0
	elif itemid == Game.POWERUP:
		$Sprite3D.frame = 2
	elif itemid == Game.SPECIAL:
		$Sprite3D.frame = 1
	elif itemid == Game.SHIELD:
		$Sprite3D.frame = 4
	pass

func _process(delta):
	#moving
	position += Vector3(dirx, 0, diry).normalized() * speed * delta
	#kepping inside battlefield
	if (dirx < 0 and position.x < Game.limitx -7) or (dirx > 0 and position.x > Game.limitx + 7):
		dirx = -dirx
	if (diry < 0 and position.z < -10) or (diry > 0 and position.z > 10):
		diry = -diry
	#the item is deleted after a time
	if lifeTime > 0:
		lifeTime -= delta
	else:
		queue_free()
	pass

func _on_body_entered(body):
	if body.is_in_group("player"):
		#applying item effects
		if itemid == Game.LIFE:
			body.lifeUp()
		elif itemid == Game.POWERUP:
			body.powerUp()
		elif itemid == Game.SPECIAL:
			body.specialUp()
		elif itemid == Game.SHIELD:
			body.shield()
		queue_free()
	pass
