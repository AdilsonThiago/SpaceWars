extends Area3D

var speed = 50
var lifeTime = 3.0
var direction = Vector2(0, 0)
var damage = 1

func _process(delta):
	#moving
	position += Vector3(direction.x, 0, direction.y) * delta
	lifeTime -= delta
	#the bullets needs a lifetime. if we dont dele
	#If they are not deleted when they leave the battlefield, they will start to consume a lot of memory
	if lifeTime <= 0:
		queue_free()
	pass

func shoot(direction, speed, damage):
	#apliyng direction to the bullet, speed, damage, and rotating according to the direction
	self.direction = Vector2(- direction.x, direction.y).normalized() * speed
	self.speed = speed
	self.damage = damage
	rotation.y = -self.direction.angle_to_point(Vector2(0, 0)) - deg_to_rad(90)
	#all ships and bullets have a collision shape. to avoid bullets skipping damage because of the height, we have a tolerance
	if position.y > 0.4:
		position.y = 0.4
	pass

func _on_body_entered(body):
	#the damage is applied to enemy or to the player according to direction (direction is vector 2, in vector 3 is related to z. see on the "_process" method)
	if direction.y < 0 and body.is_in_group("player"):
		body.damage(damage)
		queue_free()
	elif direction.y > 0 and body.is_in_group("enemy"):
		body.damage(damage)
		queue_free()
	pass
